---
name: git-workflow
description: Everyday Git/GitHub workflow for a solo researcher (R, Python, LaTeX). Use when the user says status, save, sync, start, propose, finish, undo, new-repo, contribute, conflict, or otherwise asks to commit, push, pull, branch, open/update/merge a pull request, fork, resolve a merge conflict, or undo changes in a git repository.
---

# git-workflow

The user knows the concepts but not the commands. Translate intents into the recipes below. Use `git` for local operations and `gh` (GitHub CLI) for anything on github.com. `<default>` = the repo's default branch (`git symbolic-ref --short refs/remotes/origin/HEAD` minus `origin/`); usually `main`, sometimes `master`.

## Rules (always)

1. Start every verb with `git status -sb` and tell the user, in one line, the branch and what is uncommitted / unpushed.
2. Before any commit, show `git diff --stat` (plus the full diff if under ~60 lines) and the proposed message, then commit. The user approves or stops you at the tool-approval prompt; if they asked to see the diff first, wait for OK.
3. Commit messages: imperative, ≤ 72 chars, describe the change (`Add volatility-targeting subsection`). Never `update`, `wip`, `changes`.
4. Never stage: secrets (`.env`, `*.pem`, files containing `API_KEY`/`TOKEN`/`PASSWORD`), files > 50 MB (GitHub warns at 50 MB, rejects at 100 MB), build clutter (`*.aux`, `*.log`, `.Rhistory`, `__pycache__/`, `.DS_Store`). If found, add them to `.gitignore` (if already tracked, also `git rm --cached <file>`) and say so.
5. Destructive or history-rewriting commands — `push --force`, `reset --hard`, `rebase`, `commit --amend` of a pushed commit, `branch -D` of an unmerged branch, `clean -fd`, `restore` of uncommitted edits — need explicit confirmation: state in one sentence what will be lost, then wait. Never force-push `<default>`.
6. Prefer `revert` over `reset` for anything already pushed.
7. On any error, quote the key line, explain it in one sentence, propose the fix. Don't loop retrying.
8. End each verb with a one-line summary: what changed locally, what changed on GitHub, and the PR/repo URL if any.

## Verbs

**status** — `git fetch -q`; `git status -sb` (shows ahead/behind GitHub); `git log --oneline -5`.

**save [message]** — commit and upload.
```
git add -A                       # or only the files the user names
git commit -m "<message>"        # skip if nothing staged; write a message if none given (rule 3)
git pull --no-rebase --no-edit   # merge GitHub's new commits; skip if the branch isn't on GitHub yet
git push                         # first push of a branch: git push -u origin HEAD
```
If a merge is in progress (`git rev-parse -q --verify MERGE_HEAD` succeeds), first check no `<<<<<<<`/`>>>>>>>` markers remain, then `git commit --no-edit`. Commit before pulling: a pull with uncommitted edits can be refused. If the pull reports `CONFLICT`, go to **conflict**. If on `<default>` in a repo with collaborators or branch protection, suggest `start` + `propose` instead. On a branch with an open PR, each push updates the PR.

**sync** — `git pull --no-rebase --no-edit`. If uncommitted edits block it, offer: save first, or `git stash` / pull / `git stash pop`. In a fork, first `gh repo sync <user>/<repo>` (brings the original's new commits into the fork), then `git switch <default>` before pulling.

**start <topic>** — `git switch <default> && git pull --no-rebase --no-edit && git switch -c <kebab-case-topic>`.

**propose** — push branch and open a PR. Refuse on `<default>` (suggest `start`).
```
git push -u origin HEAD
gh pr create --fill              # add --draft if the user says "draft"
```
Print the PR URL. To revise a PR later: `save` on the same branch.

**finish** — merge the current branch's PR and clean up.
```
gh pr view --json state,url        # OPEN → merge; MERGED → skip merge; CLOSED → stop
gh pr merge --merge                # with pending checks gh may only enable auto-merge: re-check, stop unless MERGED
git switch <default> && git pull --no-rebase --no-edit
git branch -D <branch>             # safe: the PR is merged
git push origin --delete <branch>  # ignore "remote ref does not exist"
```

**undo** — ask which of these the user means if not obvious, then apply:
| Intent | Command |
|---|---|
| discard edits to a file | `git restore <file>` (confirm, rule 5) |
| unstage | `git restore --staged <file>` |
| undo last commit, not pushed (`git branch -r --contains HEAD` is empty) | `git reset --soft HEAD~1` |
| undo a pushed commit | `git revert --no-edit <hash>` then `git push` |
| return repo to state at date/commit, keep history | `git restore --source=<hash> --staged --worktree .` then commit "Restore state of <ref>" |
| stop tracking a file, keep it on disk | `git rm --cached <file>`, add to `.gitignore`, commit |
| recover a lost commit | `git reflog`, then `git branch rescue-<short> <hash>` |

**new-repo [name] [--public]** — put the current folder on GitHub (private by default).
```
git init                                   # if not already a repo
# create .gitignore from the template below if missing
git add -A && git commit -m "Initial commit"
gh repo create <name> --private --source=. --push
```

**contribute <owner/repo>** — `gh repo fork <owner/repo> --clone`, `cd` into it, then `start`; later `propose` (gh opens the PR against the original repo).

**conflict** (a merge reported `CONFLICT`) — list conflicted files (`git diff --name-only --diff-filter=U`); for each conflict show both sides and recommend one with a reason; apply the user's choice; `git add <file>`; `git commit --no-edit`; `git push`. Offer `git merge --abort` as the exit.

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
