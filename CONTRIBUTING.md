# Contributing to Zeksta Agent Skills

Thanks for helping improve our internal agent skills. This repo is intended to be **shared and reused across projects**, so changes should stay **general**, **safe**, and **well-documented**.

## Where to create issues

- **Bugs / skill not working / unclear instructions**: create an issue at:
  - `https://github.com/Zeksta-Technology-Pvt-Ltd/zeksta-skills/issues`
- **Feature requests**: create an issue describing:
  - the problem it solves
  - who will use it
  - expected inputs/outputs
  - examples (good + bad)

## Types of contributions

- **New skills**
  - Add a new skill under `.agents/skills/zeksta/<skill-name>/SKILL.md`.
  - Prefer narrow, composable skills over “do everything” skills.
- **Improve existing skills**
  - Clarify steps, inputs/outputs, guardrails, and verification criteria.
  - Add better examples and edge cases.
- **Command scripts**
  - Put helper scripts next to the relevant skill:
    - `.agents/skills/zeksta/review/review.sh`
    - `.agents/skills/zeksta/qa/qa.sh`
    - `.agents/skills/zeksta/qa-only/qa-only.sh`
  - Scripts must be **read-only with respect to code** (no automatic edits).
- **Docs**
  - Keep `README.MD` current (skills list, install steps, command paths).

## How to submit contributions

1. **Create a branch**
   - Use a descriptive name, e.g. `skill/review-improvements` or `skill/add-security-review`.

2. **Make your changes**
   - For skills:
     - Ensure `SKILL.md` includes **Purpose**, **When to use**, **Inputs**, **Outputs**, **Steps**, **Guardrails**, and **Verification**.
   - For scripts:
     - Provide `--help` output and sensible defaults.
     - Avoid assumptions about package managers and project structure whenever possible.

3. **Self-check**
   - Confirm paths are correct and commands in docs match what exists.
   - Keep changes focused; avoid drive-by refactors.

4. **Open a Pull Request**
   - Include:
     - What changed and why
     - Which skill(s) are impacted
     - Any expected behavior changes
     - Example usage (prompt + expected output format)

## Conventions

- **Skill paths**: `.agents/skills/zeksta/<skill>/SKILL.md`
- **Naming**:
  - Use kebab-case for skill folders (e.g. `qa-only`, `security-review`).
- **Safety**:
  - Prefer “suggest” over “apply” for anything that could change behavior.
  - If a skill can be destructive in some contexts, it must clearly require explicit user approval.

