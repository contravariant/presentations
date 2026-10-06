# Part 1 — Git and GitHub: the concepts

Read this once. Part 2 tells you how to *do* everything through ChatGPT or the terminal; this part tells you what is happening when you do.

## 1. Two different things

- **Git** is a program on your computer that records the history of a folder. It works offline.
- **GitHub** is a website that hosts copies of Git folders, so they are backed up, shareable, and reviewable. It adds collaboration features (pull requests, issues) that Git itself does not have.

You use Git to record history locally; you use GitHub to share it.

## 2. The objects

| Term | Definition | Example |
|---|---|---|
| **Repository** ("repo") | A folder whose history Git tracks. The history lives in a hidden subfolder `.git/`. | `~/research/sizing-paper/` |
| **Commit** | A snapshot of the tracked files at one moment, plus a message, an author, a timestamp and a pointer to the previous commit. Identified by a hash (a 40-character ID, usually shown as its first 7 characters). | `a1b2c3d  "Add Kelly sizing section"` |
| **History** | The chain of commits, each pointing to its parent. Mathematically a directed acyclic graph; in solo work, usually a straight line. | `A ← B ← C` |
| **Branch** | A movable *name* that points to one commit. Committing on a branch moves the name forward to the new commit. Branches let you develop a variation without touching the main line. | `main`, `new-figures` |
| **`main`** | The conventional name of the default branch — the "official" version (older repos: `master`). | |
| **HEAD** | "Where you are now": the branch (hence the commit) your folder currently reflects. | |
| **Remote** | Another copy of the repo that you sync with, typically on GitHub. The default remote is named **`origin`**. | `origin = github.com/you/sizing-paper` |
| **Remote-tracking branch** | Your machine's last-known copy of a GitHub branch, named `origin/<branch>`. Your branch is *ahead* by the commits you have that it lacks (push them), *behind* by those it has that you lack (pull them). The GitHub branch yours pushes to and pulls from is its **upstream**. | `main` is 2 ahead of `origin/main` |
| **Tag** | A permanent label on one commit (unlike a branch, it never moves). | `v1.0`, `submitted-2026-10` |

A useful analogy: a repo is a **ledger**; a commit is a **journal entry**; a branch is a **bookmark** in the ledger.

## 3. The three places a file change lives

Every change passes through three areas on your machine, then optionally a fourth on GitHub:

```
 working directory  --add-->  staging area  --commit-->  local repo  --push-->  GitHub (remote)
   (your files)               ("the cart")               (history)              (shared copy)
```

- **Working directory**: the files as you see them in Finder/RStudio. Editing here records nothing. A new file is *untracked* — Git ignores it until you `git add` it the first time; after that it is *tracked*.
- **Staging area** (also "index"): the set of changes you have selected for the *next* commit. `git add` puts changes here. It exists so one commit can contain some edits and not others — e.g. commit the fixed regression in `model.R` but not the half-written `notes.md`.
- **Local repository**: commits you have made. Only on your machine until pushed.
- **Remote**: GitHub's copy. Updated only when you **push**.

Example:
```bash
git add model.R                         # stage one file
git commit -m "Fix sign error in beta"  # snapshot the staged changes
git push                                # upload new commits to GitHub
```

## 4. Moving commits between your machine and GitHub

| Operation | What it does |
|---|---|
| **Clone** | Download a full copy of a GitHub repo (all history) to your machine, with `origin` set up. Done once per repo per machine. |
| **Push** | Upload your new local commits to the remote branch. |
| **Fetch** | Download new remote commits, without changing your files. |
| **Pull** | Fetch, then merge those commits into your current branch. This is what you normally run. |

Rule: **pull before you start working, push when you stop.** If you work from two laptops, this alone prevents most trouble.

## 5. Combining work: merge and conflicts

- **Merge**: combine the history of one branch into another, producing a commit with two parents. Example: merge `new-figures` into `main` once the figures are done.
- **Merge conflict**: happens when both branches changed the *same lines* of the same file. Git cannot choose, so it writes both versions into the file between markers and asks you to edit it:
  ```
  <<<<<<< HEAD
  alpha <- 0.05
  =======
  alpha <- 0.10
  >>>>>>> new-figures
  ```
  Edit the block to what you want (either side, or a mix), delete the marker lines, then `git add` and `git commit`. Conflicts are normal and harmless; nothing is lost.
- **Rebase** (for recognition only): an alternative to merge that replays your commits on top of another branch, giving a straight-line history. It rewrites commits; avoid it until you need it.

## 6. Collaborating: fork and pull request

- **Fork**: your own GitHub copy of *someone else's* repo, under your account. You need it when you cannot push to the original. (A clone is a copy on your machine; a fork is a copy on GitHub.)
- **Diff**: the line-by-line difference between two versions (`+` added, `-` removed).
- **Pull request (PR)**: a request, made on GitHub, to merge one branch into another. It shows the diff, allows comments and review, and has a **Merge** button. Pushing more commits to the branch updates the PR. The branch can be in the same repo or in a fork.

Contributing to someone else's project: fork → clone your fork → branch → commit → push to your fork → open a PR to the original.

## 7. Undoing things

| Situation | Command | Effect | Safe after push? |
|---|---|---|---|
| Discard unsaved edits to a file | `git restore file.R` | File returns to last commit. **Edits are lost.** | n/a |
| Unstage a file (keep edits) | `git restore --staged file.R` | Removes from the cart only. | n/a |
| Fix the message/contents of the last commit | `git commit --amend` | Replaces the last commit. | **No** |
| Undo a commit, keeping history | `git revert a1b2c3d` | Adds a *new* commit that inverts `a1b2c3d`. | **Yes** |
| Move the branch back to an older commit | `git reset --hard a1b2c3d` | Later commits disappear from the branch. **Uncommitted edits are lost.** | **No** |

Ledger analogy: **revert** is a reversing journal entry (the audit trail survives); **reset** tears pages out of the ledger. Once others may have your commits (i.e. after pushing), only revert is safe.

Almost nothing committed is truly lost: `git reflog` lists every commit HEAD has pointed to for ~90 days, so a "lost" commit can usually be recovered.

## 8. Files Git should ignore

**`.gitignore`**: a file listing patterns Git should not track — generated files, data dumps, secrets. Example: `*.aux`, `.Rhistory`, `.env` (full template: [helpers/gitignore-template](helpers/gitignore-template)). It only affects untracked files; a file already committed must be untracked with `git rm --cached <file>`.
Never commit passwords or API keys: once pushed, assume they are public, even if deleted later.

Large binaries (PDFs, data): Git stores each version in full. Fine for papers; GitHub warns above 50 MB and rejects single files over 100 MB.

## 9. The workflow

**Solo (your own repo, one person):** committing directly on `main` is fine.
```
pull → edit → add → commit → push
```

**Branch + PR (collaboration, or any change you want reviewed or might abandon):**
```
pull main → create branch → edit/add/commit (repeat) → push branch
→ open PR → review → merge on GitHub → pull main → delete branch
```

Good commits: one logical change each; message in the imperative, ≤ 72 characters (`Add robustness table`, not `stuff`). Commit often; small commits are easy to revert.

## 10. Glossary (one line each)

**clone** copy repo to your machine · **fork** copy repo to your GitHub account · **stage/add** select changes for next commit · **commit** snapshot · **push** upload commits · **pull** download + merge · **fetch** download only · **branch** movable name for a line of work · **merge** combine branches · **conflict** same lines changed on both sides · **PR** proposal to merge, with review · **revert** undo by adding an inverse commit · **reset** move a branch pointer (rewrites history) · **HEAD** where you are · **origin** default remote · **diff** line differences · **tag** permanent label on a commit (e.g. `v1.0`, `submitted-2026-10`).
