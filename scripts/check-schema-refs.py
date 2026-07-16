#!/usr/bin/env python3
"""Fail when code references a Postgres table/view/RPC that the migrations never create.

Why this exists
---------------
Twice now a *safety* feature shipped wired to a backend that did not exist, and
nothing caught it:

  * Story 0.4 — the Emergency SOS screen called a GraphQL host that was never
    deployed. The SOS button always errored. Found by a manual audit in July,
    months after it landed.
  * Story 0.6 — web's block feature writes to ``blocked_users``. The table is
    called ``blocks``. Found by hand on 2026-07-16 while trying to write a pgTAP
    test for the gating it was supposed to enforce.

Both were invisible to CI because the tests **mock the Supabase client**. A mock
answers to any table name you invent, so a green suite proves the mock, not the
schema. This script is the missing check: it compares every ``.from('x')`` /
``.rpc('x')`` in the source against the tables, views and functions the
migrations actually create.

Scope + limits (read before trusting a green run)
-------------------------------------------------
This is a **string-level** check. It finds the class of bug above and nothing
cleverer:

  * It cannot see a table name built at runtime (``.from(tableName)``) — only
    string literals.
  * It does not check *columns*. ``notify-new-message`` also reads
    ``message.chat_id``, which does not exist; only its ``.from("chats")`` is
    caught here.
  * For web (TypeScript), the *better* fix is Story W.2's generated
    ``database.types.ts`` — a typed client turns this into a compile error and
    catches columns too. This script is the interim net and the permanent one
    for Dart and the edge functions, which have no equivalent.

Usage
-----
    python3 scripts/check-schema-refs.py            # report + exit 1 on unknowns
    python3 scripts/check-schema-refs.py --list     # print the parsed schema

Allowlist real exceptions in ``KNOWN_NON_TABLES`` with a reason. Do not silence
a finding by adding it there because it is noisy — that is how the SOS bug lived
for months.
"""
from __future__ import annotations

import os
import re
import sys

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MIGRATIONS = os.path.join(REPO, "supabase", "migrations")

# Scanned roots. Web (src/) lives in the sibling repo and is checked by its own
# CI via generated types (Story W.2); this repo can only gate what it contains.
SCAN_ROOTS = [
    (os.path.join(REPO, "lib"), (".dart",)),
    (os.path.join(REPO, "supabase", "functions"), (".ts",)),
]

# `.from()` is not exclusively PostgREST. Storage buckets use the same verb —
# `storage.from('avatars')` — and are NOT tables. Matching `.from(` blindly
# reports them as phantom; that false positive cost real review time on
# 2026-07-16, so it is filtered structurally rather than allowlisted.
#
# The receiver may sit on an earlier line — Dart chains like
#     _supabaseClient.storage
#         .from('avatars')
# are common — so this must be matched against the whole file, never line by
# line. A line-scoped version of this check missed exactly that case.
STORAGE_FROM = re.compile(r"""storage\s*\.\s*from\(\s*['"]""")

FROM_RE = re.compile(r"""\.from\(\s*['"]([A-Za-z_][A-Za-z0-9_]*)['"]\s*\)""")
RPC_RE = re.compile(r"""\.rpc\(\s*['"]([A-Za-z_][A-Za-z0-9_]*)['"]""")

CREATE_TABLE_RE = re.compile(
    r"""CREATE\s+TABLE\s+(?:IF\s+NOT\s+EXISTS\s+)?(?:public\.)?["']?([a-z_][a-z0-9_]*)""",
    re.IGNORECASE,
)
CREATE_VIEW_RE = re.compile(
    r"""CREATE\s+(?:OR\s+REPLACE\s+)?(?:MATERIALIZED\s+)?VIEW\s+(?:IF\s+NOT\s+EXISTS\s+)?(?:public\.)?["']?([a-z_][a-z0-9_]*)""",
    re.IGNORECASE,
)
CREATE_FUNC_RE = re.compile(
    r"""CREATE\s+(?:OR\s+REPLACE\s+)?FUNCTION\s+(?:public\.)?["']?([a-z_][a-z0-9_]*)""",
    re.IGNORECASE,
)

# Names that are legitimately not in our migrations. Each needs a reason.
KNOWN_NON_TABLES: dict[str, str] = {
    # Supabase-managed schemas we do not own migrations for.
    "users": "auth.users — managed by Supabase Auth, not our migrations",
    "objects": "storage.objects — managed by Supabase Storage",
    "buckets": "storage.buckets — managed by Supabase Storage",
}

# ---------------------------------------------------------------------------
# BASELINE — phantom references that already existed when this check was added
# (2026-07-16). This is a RATCHET, not an amnesty:
#
#   * a phantom NOT listed here fails the build (no new ones, ever);
#   * a name listed here that no longer resolves as phantom ALSO fails, forcing
#     the entry to be deleted rather than left to rot.
#
# The baseline exists only because the fixes are safety-sensitive and gated on
# human sign-off (Story 0.7) — without it the check could not be turned on at
# all, and the next phantom would land unseen like the last three did.
#
# Every entry names the story that removes it. Do not add to this dict to make
# CI green; that is precisely how Story 0.4 survived for months.
# ---------------------------------------------------------------------------
BASELINE: dict[str, str] = {
    "shared_meetups": "Story 0.7 — FOUNDATIONS §5 names this a KEEP (safety pillar, 'the differentiator'). Table never created.",
    "message_reports": "Story 0.7 — FOUNDATIONS §5 REFACTOR ('the incumbent-can't-do wedge'). Reporting a message writes nowhere.",
    "message_moderation": "Story 0.7 — as above; the moderation lookup reads a table that does not exist.",
    "chats": "Story 0.7 — notify-new-message is trigger-invoked on EVERY message insert and selects a phantom table (messages has connection_id, not chat_id).",
    "get_entries_near_location": "Story 0.7 — journal 'entries near location' RPC was never created.",
    "travel_preferences": "Story 0.7 — offline upload_sync writes to a table that does not exist.",
    "photos": "Story 0.7 — unwired duplicate of the sanctioned media_items path (FOUNDATIONS §7); scaffold fakes its own data. Likely deletion, pending a product call.",
}


def strip_comments(text: str, is_dart_or_ts: bool) -> str:
    """Blank out comments so a commented-out example is not reported as code.

    A ``// .from('feature_flags')`` inside a TODO block is documentation, not a
    call. Reporting it as a phantom table (which happened on 2026-07-16) burns
    review time and teaches people to distrust the check.
    """
    if not is_dart_or_ts:
        return text
    text = re.sub(r"/\*.*?\*/", "", text, flags=re.S)  # block comments
    out = []
    for line in text.split("\n"):
        # Naive but adequate: a // outside a string literal starts a comment.
        # Over-stripping only risks a false NEGATIVE on a pathological line,
        # which is the safe direction for a gate that blocks merges.
        idx = line.find("//")
        if idx != -1:
            quotes = line[:idx].count("'") + line[:idx].count('"')
            if quotes % 2 == 0:  # not inside a string
                line = line[:idx]
        out.append(line)
    return "\n".join(out)


def parse_schema() -> tuple[set[str], set[str]]:
    """Return (relations, functions) declared by the migrations."""
    rels: set[str] = set()
    funcs: set[str] = set()
    if not os.path.isdir(MIGRATIONS):
        print(f"error: no migrations dir at {MIGRATIONS}", file=sys.stderr)
        raise SystemExit(2)
    for f in sorted(os.listdir(MIGRATIONS)):
        if not f.endswith(".sql"):
            continue
        sql = open(os.path.join(MIGRATIONS, f), encoding="utf-8", errors="ignore").read()
        rels.update(m.group(1).lower() for m in CREATE_TABLE_RE.finditer(sql))
        rels.update(m.group(1).lower() for m in CREATE_VIEW_RE.finditer(sql))
        funcs.update(m.group(1).lower() for m in CREATE_FUNC_RE.finditer(sql))
    return rels, funcs


def scan() -> dict[tuple[str, str], list[str]]:
    hits: dict[tuple[str, str], list[str]] = {}
    for root, exts in SCAN_ROOTS:
        if not os.path.isdir(root):
            continue
        for dirpath, _, files in os.walk(root):
            for fn in files:
                if not fn.endswith(exts):
                    continue
                if fn.endswith((".g.dart", ".freezed.dart")):
                    continue  # generated
                path = os.path.join(dirpath, fn)
                try:
                    raw = open(path, encoding="utf-8", errors="ignore").read()
                except OSError:
                    continue
                text = strip_comments(raw, True)
                rel = os.path.relpath(path, REPO)

                def line_of(offset: int) -> int:
                    return text.count("\n", 0, offset) + 1

                # Offsets of every storage-bucket `.from(`, so the table scan can
                # skip them regardless of how the chain is wrapped across lines.
                storage_spans = {m.end() for m in STORAGE_FROM.finditer(text)}

                for m in FROM_RE.finditer(text):
                    # m.end() of STORAGE_FROM lands just past the opening quote;
                    # FROM_RE's group(1) starts there too when it is a bucket.
                    if m.start(1) in storage_spans:
                        continue
                    hits.setdefault(("table", m.group(1).lower()), []).append(
                        f"{rel}:{line_of(m.start())}"
                    )
                for m in RPC_RE.finditer(text):
                    hits.setdefault(("rpc", m.group(1).lower()), []).append(
                        f"{rel}:{line_of(m.start())}"
                    )
    return hits


def main() -> int:
    rels, funcs = parse_schema()

    if "--list" in sys.argv:
        print(f"relations ({len(rels)}):\n  " + "\n  ".join(sorted(rels)))
        print(f"\nfunctions ({len(funcs)}):\n  " + "\n  ".join(sorted(funcs)))
        return 0

    hits = scan()
    new: list[tuple[str, str, list[str]]] = []
    baselined: list[tuple[str, str, list[str]]] = []
    for (kind, name), locs in sorted(hits.items()):
        if name in KNOWN_NON_TABLES:
            continue
        known = rels if kind == "table" else funcs
        if name in known:
            continue
        (baselined if name in BASELINE else new).append((kind, name, locs))

    # A baseline entry that no longer appears means the phantom was fixed (or the
    # code deleted). Force the entry out so the baseline can only shrink.
    seen = {n for _, n, _ in baselined}
    stale = sorted(set(BASELINE) - seen)

    checked = len(hits)
    failed = False

    if new:
        failed = True
        print(f"❌ {len(new)} NEW phantom reference(s) — code targets a relation/function")
        print("   that no migration creates. Tests cannot catch this: they mock the")
        print("   Supabase client, and a mock answers to any name you invent.\n")
        for kind, name, locs in new:
            label = "table/view" if kind == "table" else "rpc"
            print(f"  {label} {name!r} — {len(locs)} call site(s)")
            for l in locs:
                print(f"      {l}")
            print()

    if stale:
        failed = True
        print(f"❌ {len(stale)} BASELINE entr(y/ies) no longer phantom — delete them from")
        print("   BASELINE in this script. The baseline only shrinks.\n")
        for name in stale:
            print(f"  {name!r} — resolves now; remove it")
        print()

    if baselined:
        print(f"⚠️  {len(baselined)} known phantom(s) outstanding — tracked, not forgotten:")
        for _, name, locs in baselined:
            print(f"  {name!r} ({len(locs)} site(s)) — {BASELINE[name]}")
        print()

    if failed:
        return 1

    print(f"✅ no new phantom references ({checked} checked against supabase/migrations/)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
