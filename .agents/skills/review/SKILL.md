# /review - Cross-stack Code Review

## Voice
Use the repo voice in `VOICE.MD`.

## Purpose
Act as a senior engineer reviewing a change set for React, Node.js, React Native, and Flutter projects.
Focus on correctness, security, performance, DX, and consistency with project conventions.
Apply only obvious, safe fixes; escalate anything risky.

## When to use
- Before opening a PR, or before requesting human review
- When you want a structured, stack-aware review across web/mobile/backend code

Do not use for:
- Large unscoped refactors without a clear goal
- Release/production incidents (use a release/incident workflow instead)

## Inputs
- Goal of the change (1–3 sentences)
- Constraints (deadlines, backwards-compat, performance, security, platform)
- PR link (optional) or branch name (optional)
- If known: stack(s) in scope: react, node, react-native, flutter (optional; infer if missing)

## Outputs
Provide a single review report:
- Summary (2–4 bullets)
- Detected stacks (what you reviewed)
- Findings grouped by stack
- Blocking issues (must-fix before merge)
- Non-blocking suggestions
- Applied safe fixes (if any)
- Suggested commands to validate (tests/lints/analyze)
- Merge recommendation: Recommend Merge / Recommend Changes / Insufficient Context

## Stack detection
If stacks are not provided, infer from the repo:
- React (web): `package.json` includes `react`; `.tsx/.jsx` in `src/` or `app/`
- React Native: `react-native` dependency; `android/` or `ios/` present; imports from `react-native`
- Node.js: server/api entrypoints; express/fastify/nest/koa; `server.ts`, `app.js`, `src/api`
- Flutter: `pubspec.yaml` with `flutter:`; `lib/main.dart`

State what you detected at the top of the report.

## Steps
1. Understand intent
   - Restate the goal and constraints.
   - Identify what “done” means and what should not change.

2. Inspect the change set
   - Review the diff (or described file list) and map changes to intent.
   - Identify API/contract boundaries (routes, DTOs, storage models, UI state).

3. Review by stack
   - React / React Native
     - Hooks correctness (dependencies, memoization, stale closures)
     - State flow and edge cases (loading/error/empty states)
     - Accessibility and UX regressions where applicable
     - Performance footguns (work in render, unnecessary rerenders)
   - Node.js
     - Input validation and error handling at boundaries
     - Authz/authn assumptions and privilege boundaries
     - Injection risks (SQL/NoSQL/template/command), SSRF, path traversal
     - Observability (logs, error surfaces) aligned with project patterns
   - Flutter
     - Async/state safety (dispose, setState timing, error propagation)
     - Layout correctness and performance (builders, list virtualization)
     - Navigation, state management, and platform concerns (iOS/Android)

4. Tests & validation
   - Suggest the correct commands based on stack:
     - JS/TS: project-standard test + lint commands (do not invent)
     - Flutter: `flutter test` and (if used) `flutter analyze`
   - If behavior changed and tests exist, flag missing/insufficient tests.

5. Safe auto-fixes (only if clearly correct)
   - Allowed: unused imports, obvious typos, trivial compilation failures.
   - Not allowed: sweeping refactors, dependency changes, formatting the whole repo.
   - If unsure, propose changes without applying them.

6. Report findings with severity
   - Label each finding: BLOCKER / SHOULD / NICE
   - Include precise locations (file + function/component/section).

## Guardrails
- Never run destructive commands or modify unrelated areas.
- Never add dependencies as part of review.
- Do not apply non-trivial behavioral changes; propose them and explain trade-offs.

## Verification
Before finalizing:
- Ensure findings map back to the stated goal and constraints.
- Ensure each BLOCKER has a clear rationale and a precise location.
- End with a merge recommendation and a short reviewer checklist.

