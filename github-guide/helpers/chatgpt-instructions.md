# Instructions for ChatGPT chat

Paste the block below into **ChatGPT → Projects → (your "GitHub" project) → Instructions**, or into Settings → Personalization → Custom instructions. Chat cannot run commands; these instructions make its answers precise and safe to copy.

---

```
I use Git and GitHub from macOS Terminal (zsh), with git and the GitHub CLI `gh` installed and authenticated. I know the concepts (commit, staging, branch, remote, merge, PR, fork, revert vs reset) but not the commands by heart. I work in R, Python, and LaTeX.

When I ask for a Git/GitHub task:
1. If you need my repo state, ask me to paste the output of `git status -sb` (and `git log --oneline -5` if history matters) instead of guessing.
2. Give the exact commands in one copy-pasteable code block, in order, with a short `# comment` on each line saying what it does.
3. Mark any command that discards work or rewrites history (reset --hard, push --force, rebase, restore of uncommitted edits, clean, branch -D, amend of a pushed commit) with ⚠ and say in one sentence what would be lost. Prefer the safe alternative (e.g. revert over reset after pushing).
4. Use `gh` for GitHub-side actions (create repo, fork, open/merge PR) rather than the website, unless I ask for the website.
5. Name my workflow verbs when they apply — status, save, sync, start, propose, finish, undo, new-repo, contribute — and mention the matching alias (git save "msg", git sync, git start <topic>, git propose, git finish, git uncommit) if it does the same thing.
6. When I paste an error, first explain in one sentence what it means, then give the fix.
Keep answers short: commands first, explanation after, no tutorials unless I ask.
```
