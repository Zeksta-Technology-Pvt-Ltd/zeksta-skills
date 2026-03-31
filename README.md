# Agent Skills for Zeksta

**Curated internal agents skills for Zeksta Developers**

---

Have a problem? Feature reques? [Open an issue](https://github.com/Zeksta-Technology-Pvt-Ltd/zeksta-skills/issues).

Want to contribute? See our [Contributing Guide](CONTRIBUTING.md).

---

## What are agent skills?

**Agent skills** are **reusable, documented workflows** that instruct an AI agent how to perform a task in a consistent way (inputs → steps → outputs), with clear **guardrails** and **verification**.

## Why agent skills?

- **Consistency**: same review/QA standard across teams and projects
- **Speed**: repeatable workflows reduce time-to-PR and time-to-ship
- **Safety**: guardrails prevent destructive or out-of-scope actions
- **Quality**: verification steps make results easier to trust and reproduce
- **Portable**: Works across Github Copilot in VS Code, JetBranis and other compatible agents.

Learn more at [agentskills.io](https://agentskills.io/)

## Supported agents

This repo is designed to work with tools that discover skills from `.agents/skills/`, including:

- **Github Copilot**: Available in chat and agent mode


## How skills work

- **Skill definition**: each skill lives at `.agents/skills/zeksta/<skill-name>/SKILL.md`
- **Invocation**: run the skill by name (e.g. `/review`, `/qa`, `/qa-only`) in your agent host
- **Outcome**: the skill produces a structured output (report/checklist/commands) and stops when done
- **Optional scripts**: some skills include helper scripts next to them for repeatable reports

## Available skills

| Skill | Description | Files |
|------|-------------|-------|
| `/review` | Cross-stack code review for React, Node.js, React Native, and Flutter. Produces a structured set of findings and a merge recommendation. | [`.agents/skills/zeksta/review/SKILL.md`](.agents/skills/zeksta/review/SKILL.md) |
| `/qa` | Cross-stack QA with a structured test matrix and automated checks guidance. Intended to find regressions before merge/deploy. | [`.agents/skills/zeksta/qa/SKILL.md`](.agents/skills/zeksta/qa/SKILL.md) |
| `/qa-only` | QA report only (no code changes). Use when you want a pure defect report and recommended next steps. | [`.agents/skills/zeksta/qa-only/SKILL.md`](.agents/skills/zeksta/qa-only/SKILL.md) |

## Skills in this repo

Skills are stored under `.agents/skills/`.

- **Skill pack**: `.agents/skills/zeksta/`
- **Add a new skill**: `.agents/skills/zeksta/<skill-name>/SKILL.md`

## Install

### Installing Skills Locally

This installs to `~/.copilot/skills/zeksta`:

```bash
./setup --global
```

### Vendor into another repo (recommended for teams)

This installs to `<repo>/.agents/skills/zeksta`:

```bash
./setup --repo /path/to/your/repo
```

## Commands (in this skill pack)

### Generate a code review report

Create a Markdown report from a git range (useful to attach to PRs):

```bash
./.agents/skills/zeksta/review/review.sh --base origin/main --head HEAD --out review-report.md
./.agents/skills/zeksta/review/review.sh --run
```

### Run automated QA checks

Run stack-aware lint/tests and write a QA report:

```bash
./.agents/skills/zeksta/qa/qa.sh --base origin/main --head HEAD --out qa-report.md
```

### Prepare notes for `/qa-only`

Generate a lightweight QA-notes template:

```bash
./.agents/skills/zeksta/qa-only/qa-only.sh --base origin/main --head HEAD --out qa-only-report.md
```

## Learn More

If you are interested in learning more about skills, checkout the following resources:

Standard: 
- [Agent Skills Standard](https://agentskills.io/)

Reference Libraries: 
- [Anthropic's Agent Skills Library](https://github.com/anthropics/skills)

Agent-Specific Documentation: 
- [VS Code Agent Skills Documentation](https://code.visualstudio.com/docs/copilot/customization/agent-skills)
- [How to create custom skills](https://support.claude.com/en/articles/12512198-how-to-create-custom-skills)

Learning Resources:

- [The Complete Guide to Building Skills for Claude](https://resources.anthropic.com/hubfs/The-Complete-Guide-to-Building-Skill-for-Claude.pdf)