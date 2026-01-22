#!/usr/bin/env bash

# Ralph Wiggum Loop - Stop Hook
#
# Intercepts agent stop attempts and blocks if verification fails.
# Opt-in via RALPH_VERIFY=1 environment variable.
#
# USAGE:
#   export RALPH_VERIFY=1
#   export RALPH_VERIFY_TYPE=all  # or: tests, lint, typecheck, quick
#   claude
#
# The agent will not be able to stop until verification passes.

set -uo pipefail

# Check if Ralph verification is enabled
if [[ -z "${RALPH_VERIFY:-}" ]]; then
  # Normal mode: allow stop
  exit 0
fi

VERIFY_TYPE="${RALPH_VERIFY_TYPE:-all}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# Run verification
run_verification() {
  local result="pass"

  case $VERIFY_TYPE in
    tests)
      if ! pnpm test >/dev/null 2>&1; then
        result="fail"
      fi
      ;;
    lint)
      if ! pnpm lint >/dev/null 2>&1; then
        result="fail"
      fi
      ;;
    typecheck)
      if ! pnpm typecheck >/dev/null 2>&1; then
        result="fail"
      fi
      ;;
    build)
      if ! pnpm build >/dev/null 2>&1; then
        result="fail"
      fi
      ;;
    quick)
      # Lint + typecheck
      if ! pnpm lint >/dev/null 2>&1; then
        result="fail"
      fi
      if ! pnpm typecheck >/dev/null 2>&1; then
        result="fail"
      fi
      ;;
    all|*)
      if ! pnpm test >/dev/null 2>&1; then
        result="fail"
      fi
      if ! pnpm lint >/dev/null 2>&1; then
        result="fail"
      fi
      if ! pnpm typecheck >/dev/null 2>&1; then
        result="fail"
      fi
      ;;
  esac

  echo "$result"
}

# Run the verification
result=$(run_verification)

if [[ "$result" == "pass" ]]; then
  echo -e "${GREEN}✓ Ralph verification passed - stop allowed${NC}"
  exit 0
else
  echo -e "${RED}✗ Ralph verification failed - stop blocked${NC}"
  echo "Verification type: $VERIFY_TYPE"
  echo "Fix the issues and try again."
  # Exit code 2 blocks the stop
  exit 2
fi
