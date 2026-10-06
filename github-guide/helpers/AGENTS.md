# AGENTS.md — copy into the root of a repository

Codex (CLI and cloud) reads this file before working in the repo. Edit the first section per project.

## Project
- What this repo is: <one line, e.g. "LaTeX paper on position sizing + R code for the figures">.
- Build/check: <e.g. "latexmk -pdf main.tex" / "Rscript run_all.R" / "pytest">. Run it before committing; report failures, don't commit over them.

## Git rules
- Follow the `git-workflow` skill if available. Otherwise: show `git status` and the diff before every commit.
- Commit messages: imperative, ≤ 72 chars, one logical change per commit.
- Branching: <choose one>
  - solo: commit directly to `main`; or
  - reviewed: never commit to `main`; work on a branch and open a pull request.
- Never force-push, rebase, or `reset --hard` without asking. Prefer `git revert` for pushed commits.
- Never commit secrets (`.env`, keys, tokens), files > 50 MB (GitHub rejects > 100 MB), or build output (`*.aux`, `*.log`, `__pycache__/`).
- Do not edit generated files (<e.g. PDFs in `output/`>) by hand; regenerate them.

## When working as Codex cloud
- One task = one branch = one pull request. Title the PR like a commit message; in the body, list what changed and how it was checked.
