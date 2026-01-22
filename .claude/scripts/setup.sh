#!/usr/bin/env bash

# Brief Wiggum - First-time Setup Script
#
# Run this after forking the repo to verify your environment is ready.

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║           Brief Wiggum - Environment Setup                   ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

ERRORS=0

# Check 1: Git hooks are executable
echo -e "${BLUE}Checking git hooks...${NC}"
if [[ -x ".claude/hooks/git-guard.sh" ]] && [[ -x ".claude/hooks/verify-complete.sh" ]]; then
  echo -e "  ${GREEN}✓${NC} Git hooks are executable"
else
  echo -e "  ${RED}✗${NC} Git hooks need to be made executable"
  echo -e "    Fix: chmod +x .claude/hooks/*.sh"
  ERRORS=$((ERRORS + 1))
fi

# Check 2: Scripts are executable
echo -e "${BLUE}Checking scripts...${NC}"
if [[ -x ".claude/scripts/ralph.sh" ]] && [[ -x ".claude/scripts/ralph-prompts.sh" ]]; then
  echo -e "  ${GREEN}✓${NC} Scripts are executable"
else
  echo -e "  ${RED}✗${NC} Scripts need to be made executable"
  echo -e "    Fix: chmod +x .claude/scripts/*.sh"
  ERRORS=$((ERRORS + 1))
fi

# Check 3: CLAUDE.md exists
echo -e "${BLUE}Checking CLAUDE.md...${NC}"
if [[ -f "CLAUDE.md" ]]; then
  echo -e "  ${GREEN}✓${NC} CLAUDE.md exists"
else
  echo -e "  ${YELLOW}!${NC} CLAUDE.md not found"
  echo -e "    Action: Copy CLAUDE.md.template to CLAUDE.md and customize"
fi

# Check 4: Claude Code or Cursor available
echo -e "${BLUE}Checking AI editor...${NC}"
if command -v claude &> /dev/null; then
  echo -e "  ${GREEN}✓${NC} Claude Code is installed"
elif [[ -d "/Applications/Cursor.app" ]] || command -v cursor &> /dev/null; then
  echo -e "  ${GREEN}✓${NC} Cursor is installed"
else
  echo -e "  ${YELLOW}!${NC} Neither Claude Code nor Cursor detected"
  echo -e "    Install: https://claude.ai/claude-code or https://cursor.com"
fi

# Check 5: Package manager
echo -e "${BLUE}Checking package manager...${NC}"
if command -v pnpm &> /dev/null; then
  echo -e "  ${GREEN}✓${NC} pnpm is installed ($(pnpm --version))"
elif command -v npm &> /dev/null; then
  echo -e "  ${GREEN}✓${NC} npm is installed ($(npm --version))"
elif command -v yarn &> /dev/null; then
  echo -e "  ${GREEN}✓${NC} yarn is installed ($(yarn --version))"
else
  echo -e "  ${RED}✗${NC} No package manager found (pnpm/npm/yarn)"
  ERRORS=$((ERRORS + 1))
fi

# Check 6: jq for Ralph loop
echo -e "${BLUE}Checking jq (required for Ralph loop)...${NC}"
if command -v jq &> /dev/null; then
  echo -e "  ${GREEN}✓${NC} jq is installed"
else
  echo -e "  ${YELLOW}!${NC} jq not found (required for Ralph loop)"
  echo -e "    Install: brew install jq (macOS) or apt install jq (Linux)"
fi

echo ""

# Summary
if [[ $ERRORS -eq 0 ]]; then
  echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
  echo -e "${GREEN}║                    Setup Complete!                           ║${NC}"
  echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
  echo ""
  echo -e "${BLUE}Next steps:${NC}"
  echo "  1. Copy CLAUDE.md.template to CLAUDE.md"
  echo "  2. Customize the Architecture section for your project"
  echo "  3. Connect Brief MCP (see docs/brief-mcp-setup.md)"
  echo "  4. Run: claude (or open in Cursor)"
  echo "  5. Type: /onboard"
  echo ""
else
  echo -e "${RED}╔══════════════════════════════════════════════════════════════╗${NC}"
  echo -e "${RED}║            Setup incomplete - $ERRORS issue(s) found             ║${NC}"
  echo -e "${RED}╚══════════════════════════════════════════════════════════════╝${NC}"
  echo ""
  echo "Fix the issues above and run this script again."
  exit 1
fi
