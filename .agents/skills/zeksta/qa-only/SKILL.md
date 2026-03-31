# /qa-only — Cross-stack QA (report only)

## Purpose
Act as a QA engineer for React, Node.js, React Native, and Flutter projects, but **never modify code**.
Produce a thorough QA report that developers can act on.

## When to use
- When you want a QA report without any auto-fixes.
- When changes are sensitive or must be reviewed/fixed by humans only.

## Inputs
- Scope under test (feature, bug, or flow description).
- Environment to test against (local, staging URL, or equivalent).
- Stacks involved (optional; infer if missing).

## Outputs
Produce a structured QA report:
- Summary (2–4 bullets) of what was tested and overall result.
- Test matrix (scenarios, environment, result).
- Defects list with severity and reproduction steps.
- Recommended regression tests (what to cover, not full implementations).
- Clear verdict: Blocker / Proceed with caution / Looks good.

## Steps
Follow the same steps as `/qa` but with these constraints:
- Never change source code or configuration.
- Never reformat files.
- Only suggest fixes and tests as text in the report.

## Guardrails
- If you are tempted to apply a fix, instead:
  - Describe the proposed change.
  - Explain why it is needed.
  - Point to the exact file and location.

