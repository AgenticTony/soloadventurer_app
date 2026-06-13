# SoloAdventurer standing sprint loop

Scope: works ONLY the active sprint named in
`.claude/state/sprint-progress.json` → `active_sprint`. Never touches
`docs/sprints/SPRINT_*.md` files — those are read-only intent. Never advances to
the next sprint on its own.

**Provenance guard:** the first time this loop runs, `active_sprint` is
`SPRINT_7_POLISH` (a low-stakes sprint) — NOT `SPRINT_6.7`. `SPRINT_6.7`
(Safety / Guardian) is `DEFERRED` and must stay deferred until the
implementer → simplifier → verifier chain has proven trustworthy on boring work.
Never auto-promote a `DEFERRED` sprint to active. That is a human decision.

**Before starting:** read `.claude/state/session-handoff.md` for context from
the last session.

**Checkpoint rule:** after EVERY numbered step below (not just story
completion), update `.claude/state/session-handoff.md` with:
- Which story/task you're on and which step you just completed
- Any branches, worktrees, or PRs in flight
- CI status if applicable
- What the next step is

This ensures that if the context window fills and the user has to `/clear`, the
handoff file has enough state to resume without losing progress.

Each iteration:

1. Read `.claude/state/sprint-progress.json`.
   - If `active_sprint` is `DEFERRED`, stop — do not run it. Report and wait for
     a human to re-point.
   - If `active_sprint` has no stories with `done: false` → output
     "SPRINT COMPLETE — human decision needed to advance" and stop. Do not pick
     the next sprint yourself.
   **Checkpoint:** write "Selected task <id>, starting pre-flight" to handoff.

2. Select the FIRST task in the active sprint with `done: false` that is not
   `needs_human`. One task per iteration, no batching.

3. Pre-flight docs grounding:
   - Read the task's section in its `docs/sprints/SPRINT_*.md` file.
   - If it touches a third-party API or framework feature, WebFetch the CURRENT
     official documentation (Supabase, Riverpod, go_router, Freezed, Drift,
     Google Maps — per CLAUDE.md) BEFORE writing any code. Note the URLs — they
     go in the PR description under "Sources".
   **Checkpoint:** write "Docs grounded, spawning implementer for <id>".

4. Run the `implementer` subagent on the task (worktree isolation). It must:
   implement to the sprint file's acceptance criteria, add a test proving it,
   run the suite green (count ≥ `test_baseline`), and include doc citations.
   **Checkpoint:** write "Implementer done for <id>, <N> files changed, tests
   pass".

5. Run the `code-simplifier` subagent on the implementer's branch.
   - Reviews only the files changed by this task (`git diff origin/main`).
   - Removes dead code, flattens abstractions, improves naming.
   - Does NOT add features or refactor unrelated code.
   - Runs `flutter test` after any change to confirm nothing broke.
   **Checkpoint:** write "Code-simplifier done for <id>".

6. Run the `verifier` subagent on the branch (AFTER simplifier — it is always
   LAST before shipping). The verifier checks the code in its final state.
   - The verifier MUST diff against `origin/main` to catch unintended removals
     or additions. If a file/import/package was removed, flag it unless the task
     explicitly called for removal.
   - FAIL → feed the numbered findings back to the implementer. Max 3 attempts
     total. Still failing → set `needs_human: true` on the task with a one-line
     reason, leave `done: false`, move on.
   - PASS → continue.
   **Checkpoint:** write "Verifier verdict: PASS/FAIL for <id>".

7. **Local build gate.** Before pushing, run:
   - `flutter test` — all pass, count ≥ `test_baseline`
   - `flutter analyze` — 0 errors
   - If the task touches UI: `flutter build apk --debug` — clean build
   This catches lock-file issues and SDK drift before burning a CI run.
   **Checkpoint:** write "Local build gate passed for <id>".

8. Open a PR via `gh pr create`:
   - Title: "[<task-id>] <summary>"
   - Body MUST include:
     - What changed and why
     - Test evidence (test count vs baseline, analyzer result)
     - "Sources" list of doc URLs used during pre-flight
     - The verifier's verdict block verbatim — including any
       "REQUIRES HUMAN SIGN-OFF" or "REQUIRES CI VALIDATION" line
     - Any new dependencies flagged prominently
   **Checkpoint:** write "PR opened: <url>, watching CI".

9. **Watch CI pass.** Push the branch, then monitor `gh pr checks` until all
   jobs report pass/fail. If CI fails:
   - Pull the failing logs: `gh run view <run-id> --log-failed`
   - Diagnose: code issue or environment issue?
   - Fix on the same branch, push, watch again.
   - After ANY fix, the local build gate (step 7) MUST pass before pushing.
   - A task is NOT done until CI is green on the PR.
   ONLY after CI green → update the state file: `done: true`, `verified: true`,
   `pr: <url>`.
   **Checkpoint:** write "CI green for <id>, task DONE".

10. Never merge anything. Never push to main. PRs wait for human review.

**Sub-agent chain (the correct order):**
```
implementer → code-simplifier → verifier → commit-push-pr → CI
```
The verifier is always LAST before shipping. Nobody checks after it. The
code-simplifier runs BETWEEN implementer and verifier so the verifier catches
any mistake the simplifier might introduce.

**Critical rule — verifier re-runs are mandatory:**
After ANY fix cycle (verifier FAIL → implementer fixes), the full chain re-runs:
fix → code-simplifier → verifier. The verifier MUST be re-run on the updated
branch. The verifier's PASS on the FIXED code is the gate — not the loop
runner's judgment.

**Critical rule — verifier checks for unintended removals:**
The verifier MUST diff against `origin/main` and flag any packages, imports, or
files removed without the task explicitly requiring removal. "Not present
locally" is NOT a reason to delete — only "not imported anywhere" is.

**Safety rule:** any task touching auth, payments/paywall, ID verification, or
the Guardian check-in system is implemented and PR'd as normal, but the PR
ALWAYS carries the `REQUIRES HUMAN SIGN-OFF` warning and is never considered
production-ready from this loop alone.

Stop conditions for this run (whichever comes first):
- 2 tasks fully processed (PASS + PR opened)
- 1 task marked `needs_human`
- No eligible tasks remain

Hard rules:
- If the state file looks malformed or contradicts the sprint `.md` files, stop
  immediately and report — do not "repair" it.
- Stay inside the repo. No new dependencies without flagging them prominently in
  the PR body.
- If test count drops below `test_baseline`, STOP — do not ship a regression.
