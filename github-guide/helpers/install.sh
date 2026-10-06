#!/usr/bin/env bash
# Installs the git-workflow helpers for the current user. Safe to re-run.
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"

# 1. Skill for Codex CLI (~/.agents/skills) and Claude Code (~/.claude/skills).
for dir in "$HOME/.agents/skills" "$HOME/.claude/skills"; do
  mkdir -p "$dir/git-workflow"
  cp "$here/skills/git-workflow/SKILL.md" "$dir/git-workflow/SKILL.md"
  echo "skill      -> $dir/git-workflow/SKILL.md"
done

# 2. Git aliases (git save, sync, start, propose, finish, uncommit, st, lg).
mkdir -p "$HOME/.config/git"
cp "$here/gitconfig-aliases" "$HOME/.config/git/aliases"
git config --global --get-all include.path | grep -qx "$HOME/.config/git/aliases" \
  || git config --global --add include.path "$HOME/.config/git/aliases"
echo "aliases    -> $HOME/.config/git/aliases"

# 3. Global ignore list (R/Python/LaTeX/macOS clutter), unless you already have one.
if [ -z "$(git config --global --get core.excludesFile || true)" ]; then
  cp "$here/gitignore-template" "$HOME/.config/git/ignore"
  git config --global core.excludesFile "$HOME/.config/git/ignore"
  echo "ignore     -> $HOME/.config/git/ignore"
else
  echo "ignore     -> kept existing core.excludesFile"
fi

echo "Done. Test: 'git st' in any repo; in Codex type \$git-workflow status."
