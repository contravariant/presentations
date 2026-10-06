# Part 2 — Doing it through ChatGPT (and the terminal)

Part 1 explains the concepts. This part is operational: one-time setup, then a recipe for each task, giving **what to say** to ChatGPT/Codex and **what actually runs**. Read the commands even if an agent runs them: that is how you catch mistakes.

## 1. Which ChatGPT interface does what

| Interface | What it is | Can it change your repo? | Use it for |
|---|---|---|---|
| **ChatGPT chat** (+ GitHub connector) | Normal chat. The connector lets it *read* your GitHub repos. | No. It gives you commands; you run them. | Explanations, "what does this error mean", planning. |
| **Codex CLI** | OpenAI's agent running in your Mac terminal, inside a project folder. It runs `git`/`gh` itself, asking approval for risky steps. | Yes — your local files, then GitHub when it pushes. | Day-to-day work on your own folders. **Recommended default.** |
| **Codex (cloud, in the ChatGPT app)** | An agent that clones a GitHub repo into a remote sandbox, makes changes, and opens a pull request. | Yes, but only via a PR you then merge. | Changes from your phone/browser; no local copy needed. |
| **Plain terminal** | You type `git`/`gh` yourself. | Yes. | Quick, routine steps once you know them. |

The helper files in [`helpers/`](helpers/) make all four behave consistently (see §6).

## 2. One-time setup (Mac)

First, let the Mac shell (zsh) accept the `# comments` used in all code blocks below. Without this, pasting a line with a comment fails, and an apostrophe in a comment leaves you at a `quote>` prompt (Ctrl-C to escape):
```bash
echo 'setopt interactive_comments' >> ~/.zshrc && source ~/.zshrc
```
Then:
```bash
xcode-select --install          # installs git (skip if `git --version` works)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
                                # Homebrew, the Mac package installer (skip if `brew --version` works)
brew install gh                 # GitHub CLI: talks to github.com (PRs, forks, repos)
gh auth login                   # GitHub.com → HTTPS → answer Yes to "Authenticate Git" → browser
git config --global user.name  "Your Name"
git config --global user.email "you@example.com"   # same email as your GitHub account
git config --global init.defaultBranch main
git config --global pull.rebase false             # `git pull` merges (see Part 1 §5)
git config --global push.autoSetupRemote true     # first push of a new branch creates it on GitHub
git config --global core.editor nano              # editor git opens for messages (default is vim)
```
Then install Codex CLI (`brew install codex`), run `codex` once and sign in with your ChatGPT account. For Codex cloud: in ChatGPT open Codex → connect GitHub → choose which repos it may access. For the chat connector: Settings → Apps/Connectors → GitHub.

Finally get this guide onto your Mac and install the helpers (details in [helpers/README.md](helpers/README.md)):
```bash
gh repo clone contravariant/presentations ~/presentations
bash ~/presentations/github-guide/helpers/install.sh
```

Check: `gh auth status` should say "Logged in".

## 3. How to talk to the agent

Start Codex CLI **inside the project folder** (`cd ~/research/sizing-paper && codex`). Then speak in intents. The `git-workflow` *skill* (a Markdown file of instructions the agent loads when your request matches it; see §6) maps them to the recipes below. With the skill installed you can say just the verb — `save`, `sync`, `propose` — or invoke it explicitly as `$git-workflow save`.

Three habits:
1. **Ask before acting** when unsure: "What would you run to do X? Don't run it yet."
2. **Read the diff** before a commit: "Show me the diff first."
3. **Never approve** `push --force`, `reset --hard`, or `rebase` on `main` unless you understand why (the skill asks for confirmation before any of them).

In ChatGPT **chat**, paste the output of `git status` and of the error; it cannot see your machine.

## 4. Recipes

Each recipe: *say* → *runs*. `<…>` = fill in. Older repos call the default branch `master` instead of `main`; the skill and aliases detect this.

### 4.1 Put an existing folder on GitHub (`new-repo`)
Say: "Make this folder a private GitHub repo called sizing-paper."
```bash
git init
cp ~/.config/git/ignore .gitignore        # R/Python/LaTeX template (installed in §2)
git add -A && git commit -m "Initial commit"
gh repo create sizing-paper --private --source=. --push
```

### 4.2 Get a repo onto this machine (clone)
Say: "Clone contravariant/presentations into ~/research."
```bash
cd ~/research && gh repo clone contravariant/presentations
```

### 4.3 Where am I? (`status`)
Say: "status"
```bash
git status            # branch; staged, unstaged and untracked files; ahead/behind GitHub
git log --oneline -5  # last 5 commits
```

### 4.4 Save and upload work (`save`) — the daily loop
Say: "Save my work" or "save: added robustness table".
```bash
git status && git diff                    # review
git add <files>                           # or -A for everything not ignored
git commit -m "Add robustness table"
git pull                                  # merge in any new GitHub commits
git push
```
To commit only part of your changes: "Commit only model.R; leave notes.md uncommitted." Terminal shortcut: `git save "Add robustness table"`.

### 4.5 Get the latest from GitHub (`sync`)
Say: "sync"
```bash
git pull
```

### 4.6 Work on a branch and propose it (`start`, `propose`)
Say: "start a branch for the new figures", work, then "propose".
```bash
git switch main && git pull
git switch -c new-figures           # create + switch to branch
# … edit, then save as in 4.4 (commits go on new-figures) …
git push                            # creates new-figures on GitHub (thanks to autoSetupRemote)
gh pr create --fill                 # open PR; --fill uses commit messages as title/body
```
You get a PR link. Review the diff on GitHub (Files changed tab). To revise the PR (e.g. after review comments), keep saving on the same branch: each push updates the PR.

### 4.7 Merge the PR and clean up (`finish`)
Say: "finish" (or click **Merge** on GitHub, then say "finish").
```bash
gh pr merge --merge --delete-branch   # merge on GitHub; delete the branch on GitHub and
                                      # locally; switch you to main
git pull                              # bring merged main locally
```
If you already clicked **Merge** on GitHub, `finish` still works (it skips the merge). Terminal shortcut for all of 4.7: `git finish`.

### 4.8 Contribute to someone else's repo (`contribute`, i.e. fork)
Say: "I want to propose a fix to otheruser/somerepo."
```bash
gh repo fork otheruser/somerepo --clone   # fork on GitHub + clone your fork
cd somerepo && git switch -c fix-typo
# … edit, commit …
git push
gh pr create --fill                       # PR goes to the original repo
```
Before new work on a fork, bring it up to date with the original: "update my fork" → `gh repo sync <you>/somerepo && git switch main && git pull`.

### 4.9 Resolve a merge conflict
Say: "I have a merge conflict. Show me both versions of each conflict and recommend which to keep."
The agent shows the `<<<<<<< ======= >>>>>>>` blocks (Part 1 §5); you decide; then:
```bash
git add <file> && git commit --no-edit   # conclude the merge
git push                                 # upload it
```
Terminal shortcut: once the markers are gone, `git save` does all of this (it refuses while markers remain).
To give up and return to before the merge: `git merge --abort`.

### 4.10 Undo (`undo`)
Say what you want undone, in plain words; the agent picks the tool (Part 1 §7):

| Say | Runs |
|---|---|
| "Throw away my edits to model.R" | `git restore model.R` |
| "Unstage notes.md" | `git restore --staged notes.md` |
| "Undo the last commit, I haven't pushed" | `git reset --soft HEAD~1` (`HEAD~1` = the commit before the current one; commit gone, changes kept staged) |
| "Undo commit a1b2c3d, already pushed" | `git revert --no-edit a1b2c3d && git push` |
| "Stop tracking data.csv but keep the file" | `git rm --cached data.csv`, add it to `.gitignore`, save |
| "Make the repo look like it did on 1 Sept, keeping history" | `h=$(git rev-list -1 --before="2026-09-02 00:00" HEAD)`; `git restore --source=$h --staged --worktree .`; `git commit -m "Restore state of 1 Sept"` |
| "I lost a commit" | `git reflog`, then `git branch rescue <hash>` |

### 4.11 Look at history
| Say | Runs |
|---|---|
| "What changed since last week?" | `git log --since="1 week ago" --oneline --stat` |
| "Show the file as of commit a1b2c3d" | `git show a1b2c3d:model.R` |
| "What has my branch changed since it left main?" | `git diff main...HEAD` |

### 4.12 Mark a version (tag)
Say: "Tag this as submitted-2026-10 and push the tag."
```bash
git tag -a submitted-2026-10 -m "Submitted to journal" && git push origin submitted-2026-10
```

## 5. Codex cloud (no local machine)

In ChatGPT → Codex: pick the repo and branch, type the task — e.g. *"In sizing_best_practices.tex, add a subsection on volatility targeting after Section 3. Open a PR."* Codex works in a sandbox and returns a diff plus a **Create PR** button. Then on GitHub: review the PR → **Merge**. Locally, run `sync` before your next edit, or you will be behind (Part 1 §4).

Follow-ups in the same Codex task ("also fix the bibliography") produce a new diff that can be pushed to the same PR.

## 6. What the helpers add

| File | Used by | Effect |
|---|---|---|
| `helpers/skills/git-workflow/SKILL.md` | Codex CLI (also Claude Code) | Gives the agent the verbs `status save sync start propose finish undo new-repo contribute conflict`, each with fixed steps and safety rules. |
| `helpers/AGENTS.md` | Codex CLI and Codex cloud, when placed in a repo's root | Per-repo rules: commit-message style, what never to commit, branch/PR policy. |
| `helpers/chatgpt-instructions.md` | ChatGPT chat (Project instructions) | Makes chat answers consistent: exact commands, one-line explanation each, and a ⚠ flag on anything destructive. |
| `helpers/gitconfig-aliases` | Plain terminal | Short commands with safety checks: `git st`, `git lg`, `git save "msg"`, `git sync`, `git start <topic>`, `git propose`, `git finish`, `git uncommit`. Table in [helpers/README.md](helpers/README.md). |
| `helpers/gitignore-template` | all your repos (installed as global ignore list) | Ignores R/Python/LaTeX/macOS clutter. |

## 7. Troubleshooting

| Message | Meaning | Fix (say / run) |
|---|---|---|
| `rejected … (fetch first)` | GitHub has commits you lack. | "sync then push" → `git pull && git push` |
| `Your branch is ahead of 'origin/main' by N commits` | N commits made, not pushed. | `git push` |
| `has no upstream branch` | Branch not yet on GitHub. | `git push -u origin HEAD` (or set `push.autoSetupRemote`, §2) |
| `CONFLICT (content)` | See 4.9. | |
| `Please commit your changes or stash them` | Uncommitted edits block a pull/switch. | Commit them (4.4), or `git stash` → do the thing → `git stash pop` (stash = temporary shelf for uncommitted edits). |
| `detached HEAD` | You are viewing an old commit, not on any branch. | `git switch main` |
| `git@github.com: Permission denied (publickey)` | gh is set to the SSH protocol, but your Mac has no SSH key registered with GitHub. | `gh config set git_protocol https && gh auth setup-git`, then retry. |
| `Permission denied` / `403` | Not logged in, or no write access. | `gh auth login`; for others' repos, fork (4.8). |
| `file exceeds GitHub's 100 MB limit` | A huge file is in a commit. | Ask the agent to remove it from the unpushed commit and add it to `.gitignore`. |
| A file you added to `.gitignore` still shows up | It was committed before; `.gitignore` only affects untracked files. | `git rm --cached <file>`, then save. |
