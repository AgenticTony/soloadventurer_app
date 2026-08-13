#!/usr/bin/env python3
"""Compare the *deployed* project against the repo before a release.

Why this exists
---------------
Every gate this project already runs — ``flutter test``, ``flutter analyze``,
pgTAP, ``check-schema-refs.py`` — reads the **repository**. None of them can see
the deployed project, so a whole class of defect is invisible to CI by
construction. Two of these shipped and were only found by a manual audit on
2026-08-12:

  * ``verify-with-onfido`` was deleted from the repo in PR #29 and the removal
    was verified with a grep gate. Deleting a directory does not undeploy a
    function: it stayed ``ACTIVE`` in production, still reachable, still carrying
    a stubbed signature check that wrote ``profiles.gender_verified`` — the flag
    that admits users to women-only mode.
  * The Shufti schema was applied through the Management API query endpoint
    because ``db push`` wanted a password nobody had. The DDL landed; the ledger
    row did not. Prod was correct and its migration history was a liar, so the
    next ``db push`` from either repo would have replayed
    ``20260812000000_shufti_rebrand.sql``, hit a ``RENAME COLUMN`` on a column
    that no longer existed, and aborted mid-release.

Both were repo-invisible and both were one query away from obvious. This script
is that query, run as a gate.

Scope + limits
--------------
This checks *drift between live and repo*. It is not a substitute for the
repo-side gates, and it deliberately does not check application behaviour.

  * Requires the Supabase CLI, authenticated and linked (``supabase link``).
    Without it every check reports SKIP — a skipped check is **not** a pass, and
    the summary says so.
  * Secrets are checked for *presence*, never value. The CLI only exposes a
    digest, which is all this needs.
  * RLS and grant checks need a database connection string in ``SUPABASE_DB_URL``.
    They SKIP without one rather than guessing.

Usage
-----
    python3 scripts/preflight.py              # report; exit 1 on any FAIL
    python3 scripts/preflight.py --strict     # also exit 1 on any SKIP
    python3 scripts/preflight.py --json       # machine-readable

Exit codes: 0 all clear · 1 at least one FAIL (or SKIP under --strict) · 2 setup error
"""

from __future__ import annotations

import argparse
import json
import os
import re
import subprocess
import sys
from dataclasses import dataclass, field
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
FUNCTIONS_DIR = REPO_ROOT / "supabase" / "functions"
MIGRATIONS_DIR = REPO_ROOT / "supabase" / "migrations"

# Secrets the deployed edge functions read at request time. Missing ones fail
# closed at runtime, which is a 500 for the user rather than a build error.
REQUIRED_SECRETS = [
    "SHUFTIPRO_CLIENT_ID",
    "SHUFTIPRO_SECRET_KEY",
]

# Secrets that must NOT be present — retired vendors whose credentials would
# still authenticate a forgotten deployed function.
FORBIDDEN_SECRET_PREFIXES = ["ONFIDO_"]

PASS, FAIL, SKIP = "PASS", "FAIL", "SKIP"


@dataclass
class Check:
    name: str
    status: str
    detail: str = ""
    items: list[str] = field(default_factory=list)


def run(cmd: list[str], timeout: int = 90) -> tuple[int, str, str]:
    """Run a command, returning (returncode, stdout, stderr). Never raises."""
    try:
        p = subprocess.run(cmd, capture_output=True, text=True, timeout=timeout, cwd=REPO_ROOT)
        return p.returncode, p.stdout, p.stderr
    except FileNotFoundError:
        return 127, "", f"{cmd[0]} not found"
    except subprocess.TimeoutExpired:
        return 124, "", f"{' '.join(cmd)} timed out after {timeout}s"


def cli_available() -> bool:
    code, _, _ = run(["supabase", "--version"], timeout=20)
    return code == 0


def parse_cli_json(stdout: str) -> dict | None:
    """Pull the JSON object out of CLI stdout.

    The CLI emits JSON but prefixes progress chatter on some commands
    (``migration list`` announces "Connecting to remote database..."), so the
    payload starts partway through. Take everything from the first brace.
    """
    start = stdout.find("{")
    if start == -1:
        return None
    try:
        return json.loads(stdout[start:])
    except json.JSONDecodeError:
        return None


# ---------------------------------------------------------------------------
# 1. Deployed functions vs repo directories
# ---------------------------------------------------------------------------
def check_functions() -> Check:
    """Every deployed function must have a directory in the repo.

    The dangerous direction is deployed-but-absent: code running in production
    that nobody can review, because it is not in the tree. Repo-but-undeployed
    is reported too, but as part of the same detail rather than a failure — a
    function can legitimately be written before its release.
    """
    name = "Deployed edge functions match the repo"

    if not FUNCTIONS_DIR.is_dir():
        return Check(name, SKIP, "supabase/functions/ not found")

    repo_fns = {
        d.name for d in FUNCTIONS_DIR.iterdir() if d.is_dir() and not d.name.startswith("_")
    }

    code, out, err = run(["supabase", "functions", "list"])
    if code != 0:
        return Check(name, SKIP, f"supabase functions list failed: {err.strip() or out.strip()}")

    payload = parse_cli_json(out)
    if payload is None:
        return Check(name, SKIP, "could not parse JSON from `supabase functions list`")

    # Only ACTIVE functions are reachable; a removed one drops out of the list.
    deployed = {
        f["slug"]
        for f in payload.get("functions", [])
        if f.get("slug") and f.get("status") == "ACTIVE"
    }
    if not deployed:
        return Check(name, SKIP, "no ACTIVE functions reported by the CLI")

    orphaned = sorted(deployed - repo_fns)
    undeployed = sorted(repo_fns - deployed)

    if orphaned:
        return Check(
            name,
            FAIL,
            f"{len(orphaned)} function(s) deployed but absent from the repo — "
            f"unreviewable code is live. Undeploy with `supabase functions delete <slug>`.",
            [f"orphaned: {s}" for s in orphaned] + [f"not yet deployed: {s}" for s in undeployed],
        )

    detail = f"{len(deployed)} deployed, all present in repo"
    if undeployed:
        detail += f"; {len(undeployed)} in repo not yet deployed"
    return Check(name, PASS, detail, [f"not yet deployed: {s}" for s in undeployed])


# ---------------------------------------------------------------------------
# 2. Migration ledger vs repo migrations
# ---------------------------------------------------------------------------
def check_migrations() -> Check:
    """The remote ledger must list every migration file, and nothing else.

    A file applied out-of-band (via the dashboard or the Management API query
    endpoint) leaves the database correct and the ledger wrong. The next
    ``db push`` replays it and fails. Repair with:

        supabase migration repair --status applied <version>
    """
    name = "Migration ledger matches repo migrations"

    if not MIGRATIONS_DIR.is_dir():
        return Check(name, SKIP, "supabase/migrations/ not found")

    local_versions = {
        m.group(1)
        for f in MIGRATIONS_DIR.glob("*.sql")
        if (m := re.match(r"(\d{14})_", f.name))
    }
    if not local_versions:
        return Check(name, SKIP, "no timestamped migration files found")

    code, out, err = run(["supabase", "migration", "list", "--linked"], timeout=120)
    if code != 0:
        return Check(name, SKIP, f"supabase migration list failed: {err.strip() or out.strip()}")

    payload = parse_cli_json(out)
    if payload is None:
        return Check(name, SKIP, "could not parse JSON from `supabase migration list`")

    rows = payload.get("migrations", [])
    if not rows:
        return Check(name, SKIP, "no migrations reported by the CLI")

    # Each row carries `local` (file present) and `remote` (row in the ledger);
    # either can be empty, and the mismatch is exactly what we are looking for.
    applied = {r["remote"] for r in rows if r.get("remote")}

    unapplied = sorted(local_versions - applied)
    ghost = sorted(applied - local_versions)

    problems = []
    if ghost:
        problems.append(
            f"{len(ghost)} version(s) in the remote ledger with no file in the repo"
        )
    if unapplied:
        problems.append(
            f"{len(unapplied)} migration file(s) not applied to the linked project"
        )

    if problems:
        return Check(
            name,
            FAIL,
            "; ".join(problems)
            + ". A ledger that disagrees with the repo makes the next `db push` unsafe.",
            [f"ghost (in ledger, no file): {v}" for v in ghost]
            + [f"unapplied (file, not in ledger): {v}" for v in unapplied],
        )

    return Check(name, PASS, f"{len(applied)} migrations applied, ledger and repo agree")


# ---------------------------------------------------------------------------
# 3. Required secrets
# ---------------------------------------------------------------------------
def check_secrets() -> Check:
    """Required secrets present; retired-vendor secrets absent.

    Edge functions read these at request time, so a missing one is a 500 in
    production rather than anything a build would catch.
    """
    name = "Edge function secrets"

    code, out, err = run(["supabase", "secrets", "list"])
    if code != 0:
        return Check(name, SKIP, f"supabase secrets list failed: {err.strip() or out.strip()}")

    payload = parse_cli_json(out)
    if payload is None:
        return Check(name, SKIP, "could not parse JSON from `supabase secrets list`")

    # Names only. The CLI returns a digest in `value`, never the secret itself,
    # and this check has no reason to look at it.
    present = {s["name"] for s in payload.get("secrets", []) if s.get("name")}
    if not present:
        return Check(name, SKIP, "no secrets reported by the CLI")

    missing = [s for s in REQUIRED_SECRETS if s not in present]
    forbidden = sorted(
        s for s in present if any(s.startswith(p) for p in FORBIDDEN_SECRET_PREFIXES)
    )

    problems = []
    if missing:
        problems.append(f"missing: {', '.join(missing)}")
    if forbidden:
        problems.append(f"retired vendor still configured: {', '.join(forbidden)}")

    if problems:
        return Check(name, FAIL, "; ".join(problems), sorted(present))

    return Check(name, PASS, f"{len(REQUIRED_SECRETS)} required present, no retired-vendor secrets")


# ---------------------------------------------------------------------------
# 4 + 5. RLS and anon-executable SECURITY DEFINER functions
# ---------------------------------------------------------------------------
SQL_RLS = """
SELECT c.relname
FROM pg_class c
JOIN pg_namespace n ON n.oid = c.relnamespace
WHERE n.nspname = 'public' AND c.relkind = 'r' AND NOT c.relrowsecurity
  AND c.relname <> 'spatial_ref_sys'
ORDER BY 1;
"""

SQL_ANON_SECDEF = """
SELECT p.proname
FROM pg_proc p
JOIN pg_namespace n ON n.oid = p.pronamespace
WHERE n.nspname = 'public' AND p.prosecdef
  AND has_function_privilege('anon', p.oid, 'EXECUTE')
  AND p.proname NOT LIKE 'st\\_%' AND p.proname NOT LIKE '\\_st\\_%'
  AND p.proname NOT LIKE 'postgis%' AND p.proname NOT LIKE 'geometry%'
  AND p.proname NOT LIKE 'geography%'
ORDER BY 1;
"""


def _psql(sql: str) -> tuple[bool, list[str], str]:
    db_url = os.environ.get("SUPABASE_DB_URL", "").strip()
    if not db_url:
        return False, [], "SUPABASE_DB_URL not set"
    code, out, err = run(["psql", db_url, "-tAc", sql], timeout=60)
    if code != 0:
        return False, [], err.strip() or out.strip() or f"psql exited {code}"
    return True, [l.strip() for l in out.splitlines() if l.strip()], ""


def check_rls() -> Check:
    """Every public table must have RLS enabled.

    ``check_ins`` — a safety table — sat with RLS off in production, readable and
    writable by anyone holding the public anon key. An attacker could mark a
    missed check-in complete, defeating the escalation it exists to trigger.
    """
    name = "RLS enabled on all public tables"
    ok, rows, err = _psql(SQL_RLS)
    if not ok:
        return Check(name, SKIP, err)
    if rows:
        return Check(
            name,
            FAIL,
            f"{len(rows)} table(s) with RLS disabled — fully exposed to the anon key. "
            f"Enable RLS *and* add policies; enabling it bare blocks all access.",
            rows,
        )
    return Check(name, PASS, "all public tables have RLS enabled")


def check_anon_secdef() -> Check:
    """No application SECURITY DEFINER function should be anon-executable.

    These run as their owner and bypass RLS. PostGIS builtins are excluded —
    they are not ours to revoke.
    """
    name = "No anon-executable SECURITY DEFINER functions"
    ok, rows, err = _psql(SQL_ANON_SECDEF)
    if not ok:
        return Check(name, SKIP, err)
    if rows:
        return Check(
            name,
            FAIL,
            f"{len(rows)} SECURITY DEFINER function(s) executable by anon — "
            f"they bypass RLS. REVOKE EXECUTE FROM anon, public.",
            rows,
        )
    return Check(name, PASS, "no application SECDEF functions reachable by anon")


# ---------------------------------------------------------------------------
# Report
# ---------------------------------------------------------------------------
CHECKS = [check_functions, check_migrations, check_secrets, check_rls, check_anon_secdef]

GLYPH = {PASS: "PASS", FAIL: "FAIL", SKIP: "SKIP"}


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--json", action="store_true", help="machine-readable output")
    ap.add_argument("--strict", action="store_true", help="treat SKIP as failure")
    args = ap.parse_args()

    if not cli_available():
        msg = "Supabase CLI not found. Install it and run `supabase link` before releasing."
        if args.json:
            print(json.dumps({"error": msg}, indent=2))
        else:
            print(f"setup error: {msg}", file=sys.stderr)
        return 2

    results = [c() for c in CHECKS]

    if args.json:
        print(
            json.dumps(
                [
                    {"name": r.name, "status": r.status, "detail": r.detail, "items": r.items}
                    for r in results
                ],
                indent=2,
            )
        )
    else:
        print("\nRelease preflight — live project vs repo\n" + "=" * 46)
        for r in results:
            print(f"\n[{GLYPH[r.status]}] {r.name}")
            if r.detail:
                print(f"       {r.detail}")
            for item in r.items[:12]:
                print(f"         - {item}")
            if len(r.items) > 12:
                print(f"         … and {len(r.items) - 12} more")

        failed = [r for r in results if r.status == FAIL]
        skipped = [r for r in results if r.status == SKIP]
        print("\n" + "=" * 46)
        print(
            f"{len(results) - len(failed) - len(skipped)} passed, "
            f"{len(failed)} failed, {len(skipped)} skipped"
        )
        if skipped and not args.strict:
            print("A skipped check is not a passing check — see the reasons above.")

    if any(r.status == FAIL for r in results):
        return 1
    if args.strict and any(r.status == SKIP for r in results):
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
