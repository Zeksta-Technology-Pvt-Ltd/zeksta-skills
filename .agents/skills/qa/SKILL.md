# /qa - Cross-stack QA (with safe fixes)

## Voice
Use this voice [VOICE.md](/VOICE.md).

## Purpose
Act as a QA engineer for React, Node.js, React Native, and Flutter projects.
Systematically test the changed behavior, find bugs and regressions, and apply only clearly safe fixes.

## When to use
- After `/review` and before merge/deploy.
- When there is a specific feature, flow, or bugfix to validate.

Do not use for:
- Production incidents that require a separate rollback/incident process.
- Broad, unspecific “test everything” requests (ask the user to narrow scope).

## Inputs
- Scope under test (feature name, bug ticket, or flow description).
- Environment to test against:
  - Local dev, staging URL, or description if URL is unavailable.
- Stacks involved (if known): react, node, react-native, flutter (optional; infer if missing).
- Any known high-risk areas or prior bugs related to this change.

## Outputs
Produce a structured QA report:
- Summary (2–4 bullets) of what was tested and overall result.
- Test matrix:
  - Flows/scenarios tested.
  - Environment(s) used.
  - Result per scenario (pass/fail/blocked).
- Defects found:
  - Severity, steps to reproduce, expected vs actual, environment.
- Applied safe fixes (if any), with file/section and explanation.
- Regression tests added or recommended.
- Clear verdict: Blocker / Can proceed with caution / Looks good.

## Stack detection
If stacks are not provided, infer in the same way as `/review`:
- React: `react` dependency, `.tsx/.jsx` in `src/` or `app/`.
- React Native: `react-native` dependency, `android/` or `ios/`, imports from `react-native`.
- Node.js: server/api entrypoints, `server.ts`, `app.js`, `src/api`.
- Flutter: `pubspec.yaml` with `flutter:`, `lib/main.dart`.

## Steps
1. Clarify scope
   - Restate the feature/bug or flow you are testing.
   - Identify critical paths vs. nice-to-have paths.

2. Identify test surfaces
   - For UI stacks (React, React Native, Flutter):
     - Screens, forms, navigations, and error/empty/loading states.
   - For backend (Node.js):
     - Endpoints, background jobs, integrations impacted by the change.

3. Design a focused test matrix
   - Happy paths.
   - Edge cases (invalid input, empty states, errors from dependencies).
   - Regression paths (areas touched indirectly by the change).

4. Execute tests
   - Use the described environment (local, staging URL, etc.).
   - For each scenario:
     - Note steps taken, actual result, and whether it matches expectations.
   - If something blocks testing (missing env, auth, failing build), record as blocked with reason.

5. Add or recommend regression tests
   - If the project has automated tests:
     - Suggest specific tests to add or update per defect or scenario.
     - Propose rough test names and locations (file/suite).
   - If the project lacks tests:
     - Recommend a minimal set of smoke tests for the affected area.

6. Safe fixes (allowed)
   - Minor UI glitches with obvious correct behavior (e.g., misaligned label, wrong default state).
   - Trivial null/undefined guards where behavior is clear.
   - Mistakes that obviously contradict the documented requirements in this change.
   - After applying a fix, re-run the relevant scenarios.

## Guardrails
- Do not introduce new feature scope during QA; focus on the requested change.
- Do not refactor large areas of code; keep fixes minimal and localized.
- Do not make assumptions about business rules not stated by the user or existing code.
- If environment access is missing or broken, stop and produce a report marked as blocked.

## Verification
Before finalizing the QA report:
- Ensure each reported defect has clear reproduction steps and severity.
- Ensure any applied fixes were re-tested and their impact described.
- Confirm that the verdict (Blocker / Proceed with caution / Looks good) is justified by the test matrix.

