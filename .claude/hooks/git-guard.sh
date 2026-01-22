#!/usr/bin/env bash

# Git Safety Guard for Claude Code
#
# PURPOSE: Block dangerous git operations BEFORE they execute
# HOW IT WORKS: CC's PreToolUse hook calls this script before any Bash command
# BLOCKING: Exit code 2 + JSON to stderr blocks execution
# ALLOWING: Exit code 0 allows execution
#
# MAINTENANCE: When adding patterns, also add to permissions.deny in settings.json

set -euo pipefail

# Parse command from CLAUDE_TOOL_INPUT JSON
# Format: {"command": "git checkout --ours file.txt", "description": "...", ...}
COMMAND=$(echo "${CLAUDE_TOOL_INPUT:-}" | jq -r '.command // empty')

if [[ -z "$COMMAND" ]]; then
  exit 0  # Not a command we can check, allow
fi

# Helper: Block with clear message telling CC what to do instead
block() {
  local reason="$1"
  local alternative="$2"
  cat >&2 <<EOF
{
  "decision": "block",
  "reason": "GIT SAFETY: $reason\n\nINSTEAD: $alternative"
}
EOF
  exit 2
}

# ============================================================
# PATTERN 1: Conflict resolution that destroys changes
# ============================================================
# --ours keeps our version, discards theirs entirely
# --theirs keeps their version, discards ours entirely
# Both lose one complete side of the merge
if [[ "$COMMAND" =~ --ours|--theirs ]]; then
  block "Using --ours/--theirs permanently discards one side of merge conflicts. This can lose significant work." \
        "Show the conflicts to the user with 'git diff' and ask which changes to keep. Manual conflict resolution preserves both sides where needed."
fi

# ============================================================
# PATTERN 2: Reset commands (can lose uncommitted work)
# ============================================================
# git reset --hard: Discards ALL uncommitted changes (staged + unstaged)
# git reset (soft): Moves HEAD but keeps changes - still risky
if [[ "$COMMAND" =~ ^git[[:space:]]+reset ]]; then
  if [[ "$COMMAND" =~ --hard ]]; then
    block "git reset --hard discards ALL uncommitted changes permanently. There is no recovery." \
          "First run 'git stash' to save current work, then explain to the user what you want to undo and get explicit approval."
  else
    block "git reset moves HEAD and can lose staged changes unexpectedly." \
          "First run 'git stash' to save work. Then explain to the user what commit state you want to return to."
  fi
fi

# ============================================================
# PATTERN 3: Checkout that discards working directory changes
# ============================================================
# git checkout . : Discards all unstaged changes in current directory
# git checkout -- . : Same thing, explicit syntax
# git checkout -- * : Discards changes in all files
if [[ "$COMMAND" =~ ^git[[:space:]]+checkout[[:space:]]+(--[[:space:]]+)?[.\*] ]] || \
   [[ "$COMMAND" =~ ^git[[:space:]]+checkout[[:space:]]+\.[[:space:]]*$ ]]; then
  block "git checkout . discards all uncommitted changes in the working directory." \
        "First run 'git stash' to save changes. If you need to discard specific files, ask the user which files to revert."
fi

# ============================================================
# PATTERN 4: Restore command (modern version of checkout --)
# ============================================================
# git restore: Discards working directory changes (Git 2.23+)
# git restore --staged: Only unstages, doesn't discard - this is safer
if [[ "$COMMAND" =~ ^git[[:space:]]+restore ]]; then
  if [[ "$COMMAND" =~ --staged ]] && [[ ! "$COMMAND" =~ --worktree ]]; then
    exit 0  # Unstaging is relatively safe, allow (but not with --worktree)
  fi
  block "git restore discards working directory changes." \
        "First run 'git stash' to save changes. Ask user to confirm which specific files should be restored to their committed state."
fi

# ============================================================
# PATTERN 5: Clean removes untracked files permanently
# ============================================================
# git clean -f: Force-deletes untracked files
# git clean -fd: Also removes untracked directories
# git clean -n: Dry run - this is safe and useful
if [[ "$COMMAND" =~ ^git[[:space:]]+clean ]]; then
  if [[ "$COMMAND" =~ -n|--dry-run ]]; then
    exit 0  # Dry run is safe, allow
  fi
  if [[ "$COMMAND" =~ -f|--force ]]; then
    block "git clean -f permanently deletes untracked files. These files are not in git history and cannot be recovered." \
          "First run 'git clean -n' (dry run) and show the user exactly what would be deleted. Get explicit approval before cleaning."
  fi
fi

# ============================================================
# PATTERN 6: Stash drop/clear loses stashed work
# ============================================================
# git stash drop: Deletes a specific stash
# git stash clear: Deletes ALL stashes
if [[ "$COMMAND" =~ ^git[[:space:]]+stash[[:space:]]+(drop|clear) ]]; then
  block "git stash drop/clear permanently deletes stashed work." \
        "First run 'git stash list' and 'git stash show -p' to review what's stashed. Ask user to confirm deletion of specific stashes."
fi

# ============================================================
# PATTERN 7: Push to protected branches
# ============================================================
# Pushing directly to main/master/production should go through PR
# Note: Requires "origin" to avoid false positives on branches like "feature/main"
if [[ "$COMMAND" =~ ^git[[:space:]]+push ]]; then
  if [[ "$COMMAND" =~ origin[[:space:]]+(main|master|production)[[:space:]]*$ ]] || \
     [[ "$COMMAND" =~ ^git[[:space:]]+push[[:space:]]+(main|master|production)[[:space:]]*$ ]] || \
     [[ "$COMMAND" =~ (origin[[:space:]]+)?(main|master|production): ]] || \
     [[ "$COMMAND" =~ :(main|master|production)([[:space:]]|$) ]]; then
    block "Pushing directly to main/master/production bypasses code review." \
          "Create a feature branch, push there, and open a PR. Use: git checkout -b feature/description && git push -u origin feature/description"
  fi
fi

# ============================================================
# PATTERN 8: Rebase rewrites history
# ============================================================
# git rebase -i: Interactive rebase requires user input CC can't provide
# git rebase --abort/--skip: Handled specially to give better message
# git rebase: Can lose work during conflict resolution
if [[ "$COMMAND" =~ ^git[[:space:]]+rebase ]]; then
  # Handle abort/skip first with specific message
  if [[ "$COMMAND" =~ --abort|--skip ]]; then
    block "Aborting or skipping rebase can lose partially resolved conflicts or applied commits." \
          "First show current state with 'git status' and 'git diff'. Explain the situation to the user and ask how to proceed."
  fi
  if [[ "$COMMAND" =~ -i|--interactive ]]; then
    block "Interactive rebase requires manual user input that Claude Code cannot provide." \
          "Describe what commits you want to modify (squash, reorder, edit messages) and ask the user to perform the interactive rebase."
  fi
  block "git rebase rewrites commit history and can lose work if conflicts occur during replay." \
        "Use 'git merge' instead for combining branches. If rebase is specifically needed, explain why and get explicit user approval."
fi

# ============================================================
# PATTERN 9: Abort/skip for merge/cherry-pick can lose partial work
# ============================================================
# Aborting a merge/cherry-pick discards progress (rebase handled in Pattern 8)
if [[ "$COMMAND" =~ ^git[[:space:]]+(cherry-pick|merge)[[:space:]]+--?(abort|skip) ]]; then
  block "Aborting or skipping can lose partially resolved conflicts or applied commits." \
        "First show current state with 'git status' and 'git diff'. Explain the situation to the user and ask how to proceed."
fi

# ============================================================
# PATTERN 10: Force delete branches
# ============================================================
# git branch -D: Force-deletes even if branch has unmerged commits
# git branch -d: Safe delete, fails if unmerged - this is fine
if [[ "$COMMAND" =~ ^git[[:space:]]+branch[[:space:]]+-D ]]; then
  block "git branch -D force-deletes branches even with unmerged commits. Those commits become orphaned and eventually garbage-collected." \
        "Use 'git branch -d' instead - it will fail safely if the branch has unmerged work, prompting you to merge first."
fi

# ============================================================
# PATTERN 11: Revert multiple commits can be confusing
# ============================================================
# git revert creates new commits that undo changes - generally safe
# But reverting multiple commits or revert-of-revert gets confusing
if [[ "$COMMAND" =~ ^git[[:space:]]+revert.*HEAD~[0-9]+ ]] || \
   [[ "$COMMAND" =~ ^git[[:space:]]+revert.*\.\. ]]; then
  block "Reverting multiple commits can create confusing history and may not achieve the intended result." \
        "First run 'git log --oneline -10' to show recent commits. Explain to the user which specific changes need to be undone and why."
fi

# If we reach here, command is allowed
exit 0
