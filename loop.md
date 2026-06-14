# SoloAdventurer standing sprint loop

`/loop` is the **autonomous recurring backlog-walker** — a **PR-production
engine, not a PR-merging engine.** It reads state, picks the next eligible
story, runs the full chain on it, opens a PR, **stops** (the PR waits for human
merge), then loops to the next story. It never merges; never pushes to main.
You merge in batches when you sit down. The autonomy is in the grind (it never
idles waiting for you to start the next task), not in the merge.

## Scope
- Works ONLY the `active_sprint` in `.claude/state/sprint-progress.json`. Never
  edits `docs/sprints/SPRINT_*.md` (read-only intent). Never advances to the
  next sprint on its own — on sprint completion it outputs "SPRINT COMPLETE —
  human decision needed to advance" and stops.
- **Before starting:** read `.claude/state/session-handoff.md` for context.

## Two modes
- **grind** (default): walk the active sprint's backlog → one reviewed-ready PR per story.
- **babysit**: scan open PRs for failing CI → diagnose → fix → push → re-watch.

## grind — each tick
1. **Unreviewed-PR-depth check.** Count this loop's open (unmerged) PRs
   (`gh pr list --state open`). If **≥ 3**, PAUSE — report "N unreviewed PRs
   queued; pausing for human merge before producing more" and stop. Do not open
   a 4th. (Caps comprehension debt: no stack of unreviewed PRs.)
2. Read `sprint-progress.json`. If `active_sprint` is `DEFERRED` → stop, report.
   If no task has `done: false` → "SPRINT COMPLETE", stop.
3. Select the FIRST task with `done: false` and not `needs_human`.
   - **If the task is `safety: true`** (auth/payments/paywall/ID-verification/
     Guardian) → STOP and flag: "REQUIRES HUMAN SIGN-OFF — safety story; the
     loop does not autonomously implement or merge safety work." Do not pick it.
4. **Pre-flight docs grounding.** Read the task's section in its
   `docs/sprints/SPRINT_*.md`. If it touches a third-party API/framework feature,
     WebFetch the CURRENT official docs (Supabase, Riverpod, go_router, Freezed,
     Drift, Google Maps — per CLAUDE.md) BEFORE writing code. Note URLs for the
     PR's "Sources".
5. **`implementer` subagent** (worktree isolation): implement to the sprint
   file's acceptance criteria, add a test proving it, run the suite green
   (count ≥ `test_baseline`), include doc citations.
6. **`code-simplifier` subagent** on the implementer's branch — runs BEFORE the
   verifier. Reviews only files changed by this task (`git diff origin/main`);
   removes dead code, flattens abstraction, improves naming; re-runs
   `flutter test`. Does not add features or touch unrelated code.
7. **`verifier` subagent** (always LAST before the PR). PASS gate.
   - FAIL → feed numbered findings to the implementer; re-run simplify → verify
     on the fixed branch. **Max 3 attempts.** Still failing → set
     `needs_human: true` (one-line reason), leave `done: false`, move on.
   - PASS → continue.
8. **Local build gate** (before pushing): `flutter test` (count ≥ `test_baseline`),
   `flutter analyze` (0 errors), and for UI tasks `flutter build apk --debug`.
9. **Open a PR** (`gh pr create`). Title: "[<task-id>] <summary>". Body MUST
   include: what changed and why; test evidence (count vs baseline, analyzer);
   "Sources" doc URLs from pre-flight; the verifier's verdict block **verbatim**
   (including any REQUIRES HUMAN SIGN-OFF / REQUIRES CI VALIDATION line); any
   new dependencies flagged prominently.
10. **Watch CI pass.** Push, monitor `gh pr checks` until all jobs pass/fail.
    If CI fails: pull logs (`gh run view <run-id> --log-failed`), diagnose (code
    vs environment), fix on the same branch, re-run the local build gate (step 8),
    push, re-watch. After 3 CI-fail cycles on the same task → `needs_human`,
    move on. A task is NOT done until CI is green on the PR.
    ONLY then → state file: `done: true`, `verified: true`, `pr: <url>`.
11. **NEVER merge. NEVER push to main.** The PR waits for human review/merge.
12. **Loop to step 1** for the next tick (next story).

## babysit — each tick
1. `gh pr list --state open`. For each PR with failing CI:
2. Pull failing logs, diagnose (code issue or environment).
3. Fix on the PR's branch → re-run local build gate (grind step 8) → push →
   re-watch CI.
4. Repeat until green, or after 3 failed cycles → flag the PR for human.
5. **NEVER merge.** Babysit pushes fixes only; merge stays human.

## Stop conditions (either mode — first one hit)
- **≥ 3 unreviewed (open, unmerged) PRs** from this loop (grind) → pause for queue clearance.
- A `needs_human` or `safety: true` task is the next eligible (grind) → stop, flag.
- `active_sprint` is DEFERRED, or the sprint is complete (no eligible tasks).
- Test count drops below `test_baseline` → STOP (never ship a regression).
- Repeated failure on one task: verifier FAIL 3×, or CI fail 3× → `needs_human`, move on / flag.

## Hard rules
- **Never merge. Never push to main. PRs wait for human review.** (This is the
  gate that has caught every real problem in this project — audit-after-merge is
  strictly worse than PR-waits-for-merge, so it stays. The loop produces
  reviewed-ready PRs; you merge.)
- Safety stories (`safety: true`): never autonomously implemented or merged.
- `SPRINT_6.7` (Safety/Guardian): DEFERRED — never auto-touched, never
  auto-promoted to active. Advancing it is a human decision.
- If the state file looks malformed or contradicts the sprint `.md` files → stop
  immediately and report; do not "repair" it.
- No new dependencies without flagging them prominently in the PR body.
- Test count never below `test_baseline`.

## Sub-agent chain (order matters)
```
implementer → code-simplifier → verifier → commit-push-pr → CI green → [HUMAN MERGE]
```
The verifier is always LAST before the PR; nobody checks after it. The
code-simplifier runs BETWEEN implementer and verifier so the verifier inspects
the final code (including whatever the simplifier changed). After ANY fix cycle
(verifier FAIL → implementer fixes), re-run simplify → verify on the updated
branch — the verifier's PASS on the FIXED code is the gate, not the loop
runner's judgment.

## Critical — verifier checks for unintended removals
The verifier MUST diff against `origin/main` and flag any packages, imports, or
files removed without the task explicitly requiring removal. "Not present
locally" is NOT a reason to delete — only "not imported anywhere" is.

## Checkpoint rule
After EVERY numbered step above, update `.claude/state/session-handoff.md`:
which task/step you're on, branches/worktrees/PRs in flight, CI status, and the
next step. (So a `/clear` resumes without losing progress.)
