# Helpers

| File | What it is | Install |
|---|---|---|
| `skills/git-workflow/SKILL.md` | A *skill*: a Markdown file of instructions an agent loads when your request matches its description. Teaches Codex the verbs `status save sync start propose finish undo new-repo contribute conflict` and the safety rules. Same file works in Claude Code. | `install.sh` (copies to `~/.agents/skills/` and `~/.claude/skills/`) |
| `AGENTS.md` | Per-repo instructions Codex reads automatically when working in that repo. | Copy to a repo's root, fill in the `<…>` lines, commit it. |
| `chatgpt-instructions.md` | Text for ChatGPT chat's Project/Custom instructions. | Paste manually. |
| `gitconfig-aliases` | Terminal shortcuts (below). | `install.sh` |
| `gitignore-template` | Patterns for files Git should never track (R/Python/LaTeX/macOS clutter). | `install.sh` sets it as your global ignore list; also used by `new-repo`. |

```bash
bash install.sh      # run from this folder; safe to re-run
```
In Codex, type `/skills` to check that `git-workflow` is listed. If not, also copy the folder to `~/.codex/skills/`.

## Terminal aliases

| Alias | Equivalent | Notes |
|---|---|---|
| `git st` | `git status -sb` | compact status |
| `git lg` | `git log --oneline --graph --decorate -20` | last 20 commits as a graph |
| `git save "msg"` | `add -A`, `commit`, `pull`, `push` | message required; first push of a branch sets upstream |
| `git sync` | `git pull --no-rebase --no-edit` | |
| `git start <topic>` | `switch main`, `pull`, `switch -c <topic>` | new branch from fresh main |
| `git propose` | `push -u origin HEAD`, `gh pr create --fill` | opens PR, prints URL |
| `git finish` | `gh pr merge --merge --delete-branch`, `switch main`, `pull` | run on the PR's branch |
| `git uncommit` | `reset --soft HEAD~1` | only for unpushed commits; changes stay staged |
