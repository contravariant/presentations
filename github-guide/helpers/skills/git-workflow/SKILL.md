---
name: git-workflow
description: Everyday Git/GitHub workflow for a solo researcher (R, Python, LaTeX). Use when the user says status, save, sync, start, propose, finish, undo, new-repo, contribute, or otherwise asks to commit, push, pull, branch, open/merge a pull request, fork, or undo changes in a git repository.
---

# git-workflow

The user knows the concepts but not the commands. Translate intents into the recipes below. Use `git` for local operations and `gh` (GitHub CLI) for anything on github.com.

## Rules (always)

1. Start every verb with `git status -sb` and tell the user, in one line, the branch and what is uncommitted / unpushed.
2. Before any commit, show `git diff --stat` (and the full diff if under ~60 lines) and the proposed message. Proceed unless the user objects.
3. Commit messages: imperative, ≤ 72 chars, describe the change (`Add volatility-targeting subsection`). Never `update`, `wip`, `changes`.
4. Never stage: secrets (`.env`, `*.pem`, files containing `API_KEY`/`TOKEN`/`PASSWORD`), files > 50 MB, build clutter (`*.aux`, `*.log`, `.Rhistory`, `__pycache__/`, `.DS_Store`). If found, add them to `.gitignore` and say so.
5. Destructive or history-rewriting commands — `push --force`, `reset --hard`, `rebase`, `commit --amend` of a pushed commit, `branch -D`, `clean -fd`, `restore` of uncommitted edits — need explicit confirmation: state in one sentence what will be lost, then wait. Never force-push `main`.
6. Prefer `revert` over `reset` for anything already pushed.
7. On any error, quote the key line, explain it in one sentence, propose the fix. Don't loop retrying.
8. End each verb with a one-line summary: what changed locally, what changed on GitHub, and the PR/repo URL if any.

## Verbs

**status** — `git status -sb`; `git log --oneline -5`; `git fetch -q` then report ahead/behind vs `origin`.

**save [message]** — commit and upload.
```
git add -A                    # or only the files the user names
git commit -m "<message>"     # write one if not given (rule 3)
git pull --no-rebase --no-edit          # merge GitHub's new commits, if any; skip if branch has no upstream
git push                      # branch's first push: git push -u origin HEAD
```
Commit before pulling: a pull with uncommitted edits can be refused. If the pull reports `CONFLICT`, go to **conflict**.
If on `main` in a repo with collaborators or branch protection, suggest `start` + `propose` instead.

**sync** — `git pull --no-rebase --no-edit`. If uncommitted edits block it, offer: save first, or `git stash` / pull / `git stash pop`.

**start <topic>** — `git switch main && git pull --no-rebase --no-edit && git switch -c <kebab-case-topic>`.

**propose** — push branch and open a PR.
```
git push -u origin HEAD
gh pr create --fill           # base = default branch; add --draft if user says "draft"
```
Print the PR URL.

**finish** — merge the current branch's PR and clean up.
```
gh pr view --json state,mergeable,url
gh pr merge --merge --delete-branch     # skip if already merged on github.com
git switch main && git pull --no-rebase --no-edit
git branch -d <branch>
```

**undo** — ask which of these the user means if not obvious, then apply:
| Intent | Command |
|---|---|
| discard edits to a file | `git restore <file>` (confirm, rule 5) |
| unstage | `git restore --staged <file>` |
| undo last commit, not pushed | `git reset --soft HEAD~1` |
| undo a pushed commit | `git revert --no-edit <hash>` then `git push` |
| return repo to state at date/commit, keep history | `git restore --source=<hash> --staged --worktree .` then commit "Restore state of <ref>" |
| recover a lost commit | `git reflog`, then `git branch rescue-<short> <hash>` |

**new-repo [name] [--public]** — put the current folder on GitHub (private by default).
```
git init                                   # if not already a repo
# create .gitignore from the R/Python/LaTeX/macOS template if missing (see below)
git add -A && git commit -m "Initial commit"
gh repo create <name> --private --source=. --push
```

**contribute <owner/repo>** — `gh repo fork <owner/repo> --clone`, then `start`; later `propose` (gh targets the upstream repo).

**conflict** (when a merge reports `CONFLICT`) — list conflicted files (`git diff --name-only --diff-filter=U`); for each conflict show both sides and recommend one with a reason; apply the user's choice; `git add <file>`; `git commit --no-edit`. Offer `git merge --abort` as the exit.

## .gitignore template
```
.DS_Store
.Rhistory
.RData
.Rproj.user/
__pycache__/
*.pyc
.ipynb_checkpoints/
.venv/
*.aux
*.log
*.out
*.toc
*.bbl
*.blg
*.fls
*.fdb_latexmk
*.synctex.gz
*.nav
*.snm
.env
```
