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
if git config --global --get-regexp '^alias\.(st|lg|sync|default|save|start|propose|finish|uncommit)$' >/dev/null; then
  echo "warning: you already have global aliases with these names; they may conflict:"
  git config --global --get-regexp '^alias\.(st|lg|sync|default|save|start|propose|finish|uncommit)$' | sed 's/^/  /'
fi
mkdir -p "$HOME/.config/git"
cp "$here/gitconfig-aliases" "$HOME/.config/git/aliases"
git config --global --get-all include.path | grep -qx "$HOME/.config/git/aliases" \
  || git config --global --add include.path "$HOME/.config/git/aliases"
echo "aliases    -> $HOME/.config/git/aliases"

# 3. Global ignore list (R/Python/LaTeX/macOS clutter), unless you already have one.
#    Applies to every repo on this Mac.
if [ -z "$(git config --global --get core.excludesFile || true)" ] && [ ! -e "$HOME/.config/git/ignore" ]; then
  cp "$here/gitignore-template" "$HOME/.config/git/ignore"
  git config --global core.excludesFile "$HOME/.config/git/ignore"
  echo "ignore     -> $HOME/.config/git/ignore"
else
  echo "ignore     -> kept your existing global ignore file"
fi

# 4. Settings the guide assumes.
git config --global push.autoSetupRemote true   # first push of a new branch creates it on GitHub
git config --global pull.rebase false           # git pull merges
echo "settings   -> push.autoSetupRemote=true, pull.rebase=false"

echo "Done. Test: 'git st' in any repo; in Codex type \$git-workflow status."
