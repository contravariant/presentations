# Git & GitHub via ChatGPT — a short guide

For a reader who is technical (math/finance, R, Python) but new to Git, and who will drive Git mostly through ChatGPT/Codex, sometimes through the terminal.

1. **[Part 1 — Concepts](01-concepts.md)** (15 min). What a commit, branch, remote, staging area, merge, fork, PR, revert are, and the standard workflow.
2. **[Part 2 — Doing it via ChatGPT and the CLI](02-using-with-chatgpt-and-cli.md)**. Setup on a Mac, which ChatGPT interface to use, and a recipe per task: what to say → what runs.
3. **[Helpers](helpers/)**. A Codex/Claude skill, an `AGENTS.md` template, ChatGPT instructions, git aliases, a `.gitignore`. Install with `bash helpers/install.sh`.
4. **[Figures](figures/)**. `github-workflow-slides.html` (the animated deck: open in Safari/Chrome, works offline; ← → to step, F full screen, N notes), `github-workflow-slides.pdf` (same slides, one per page) and `github-workflow-poster.png` / `.pdf` (everything on one large page).

The whole workflow in one picture (the verbs are defined in Part 2 and work both as things you say to Codex and as `git` aliases):
```
          solo:  sync → edit → save
 collaborative:  start <topic> → edit → save (repeat) → propose → [review on GitHub] → finish
          oops:  undo
```
