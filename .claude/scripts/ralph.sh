#!/usr/bin/env bash

# Ralph Wiggum Loop - Intelligent Iterative Agent Execution
#
# A while loop that feeds an AI agent a prompt until verification passes.
# This version leverages the FULL Brief infrastructure:
# - Skills: tdd, debugging, brief-patterns, security-patterns, testing-strategy
# - Commands: /onboard, /prep, /todo-all
# - Agents: context-loader, task-planner, implementation
# - Guards: decision-guard (guard_approach), git-guard
#
# USAGE:
#   ./ralph.sh "Implement feature X with tests"
#   ./ralph.sh --linear BRI-123 "Fix the bug described in the issue"
#   ./ralph.sh --max-iterations 5 --verify-only tests "Add unit tests"
#
# OPTIONS:
#   --max-iterations N    Maximum attempts before giving up (default: 10)
#   --verify-only TYPE    Verification: tests|lint|typecheck|build|quick|all (default: all)
#   --linear BRI-XXX      Load Linear issue for context
#   --budget USD          Max dollar spend per iteration (default: 10.00)
#   --no-resume           Start fresh each iteration
#   --full-prep           Run full /prep checklist on success
#   --visual-check        Enable Playwright visual verification (agent navigates & screenshots)
#   --verbose             Show full claude output
#   --dry-run             Preview without executing

set -euo pipefail

# Get script directory for sourcing prompts
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source intelligent prompt templates
source "$SCRIPT_DIR/ralph-prompts.sh"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Defaults
MAX_ITERATIONS=10
VERIFY_TYPE="all"
LINEAR_ISSUE=""
LINEAR_PROJECT=""
BRIEF_DOC=""
BUDGET="10.00"
FULL_PREP=false
VISUAL_CHECK=false
VERBOSE=false
DRY_RUN=false
TASK=""

# State
STATE_DIR="${HOME}/.claude/ralph-state"
mkdir -p "$STATE_DIR"

# Validate flag has required argument
require_arg() {
  local flag="$1"
  local value="${2:-}"
  if [[ -z "$value" || "$value" == --* ]]; then
    echo -e "${RED}Error: $flag requires a value${NC}"
    exit 1
  fi
}

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --max-iterations)
      require_arg "$1" "${2:-}"
      MAX_ITERATIONS="$2"
      shift 2
      ;;
    --verify-only)
      require_arg "$1" "${2:-}"
      VERIFY_TYPE="$2"
      shift 2
      ;;
    --linear)
      require_arg "$1" "${2:-}"
      LINEAR_ISSUE="$2"
      shift 2
      ;;
    --linear-project)
      require_arg "$1" "${2:-}"
      LINEAR_PROJECT="$2"
      shift 2
      ;;
    --brief)
      require_arg "$1" "${2:-}"
      BRIEF_DOC="$2"
      shift 2
      ;;
    --budget)
      require_arg "$1" "${2:-}"
      BUDGET="$2"
      shift 2
      ;;
    --no-resume)
      # RESUME flag reserved for future session continuation feature
      shift
      ;;
    --full-prep)
      FULL_PREP=true
      shift
      ;;
    --visual-check)
      VISUAL_CHECK=true
      shift
      ;;
    --verbose)
      VERBOSE=true
      shift
      ;;
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --help|-h)
      cat <<'HELPEOF'
Ralph Wiggum Loop - Intelligent Iterative Agent Execution

Uses the FULL Brief infrastructure: skills, commands, agents, and guards.
The agent will follow TDD, use debugging methodology, check decisions, etc.

USAGE:
  ./ralph.sh "Implement feature X with tests"
  ./ralph.sh --linear BRI-123 "Fix the bug described in the issue"
  ./ralph.sh --brief "PRD: Feature Name" "Implement the feature per the PRD"
  ./ralph.sh --max-iterations 5 --verify-only tests "Add unit tests"

OPTIONS:
  --max-iterations N    Max attempts before giving up (default: 10)
  --verify-only TYPE    Verification type (default: all)
                        tests|lint|typecheck|build|quick|all
  --linear ID           Load Linear issue for context (single issue)
  --linear-project NAME Load Linear project (multi-issue, works through all)
  --brief TITLE         Load Brief document (PRD, spec, etc.) for context
  --budget USD          Max spend per iteration (default: 10.00)
  --no-resume           Start fresh each iteration
  --full-prep           Run full /prep checklist on success
  --visual-check        Enable Playwright visual verification
                        (agent navigates app & takes screenshots)
  --verbose             Show full claude output
  --dry-run             Preview without executing

SKILLS LOADED AUTOMATICALLY:
  - tdd: RED-GREEN-REFACTOR methodology
  - debugging: Systematic root cause analysis
  - brief-patterns: API routes, database, components
  - security-patterns: HIPAA/SOC-2 compliance
  - testing-strategy: 80% coverage requirement

EXAMPLES:
  # Bug fix with Linear issue context
  ./ralph.sh --linear BRI-456 "Fix the auth middleware bug"

  # Feature from PRD in Brief
  ./ralph.sh --brief "PRD: Search Feature" "Implement the search feature per the PRD"

  # Multi-issue project with PRD (works through all tasks in order)
  ./ralph.sh --linear-project "Pending Decisions" --brief "pending decisions prd.md" "Implement pending decisions"

  # Feature implementation with full prep
  ./ralph.sh --full-prep "Add pagination to GET /api/v1/documents"

  # Quick iteration for refactoring
  ./ralph.sh --verify-only quick --max-iterations 3 "Refactor session types"
HELPEOF
      exit 0
      ;;
    *)
      TASK="$1"
      shift
      ;;
  esac
done

if [[ -z "$TASK" ]]; then
  echo -e "${RED}Error: No task provided${NC}"
  echo "Usage: ralph.sh [options] \"Your task description\""
  exit 1
fi

# Generate run ID
RUN_ID=$(date +%s)-$$
STATE_FILE="$STATE_DIR/$RUN_ID.json"
LOG_FILE="$STATE_DIR/$RUN_ID.log"

log() {
  echo -e "$1" | tee -a "$LOG_FILE"
}

# Initialize state with skill detection
init_state() {
  local detected_skills
  detected_skills=$(detect_task_skills "$TASK")

  cat > "$STATE_FILE" <<EOF
{
  "run_id": "$RUN_ID",
  "task": $(echo "$TASK" | jq -Rs .),
  "linear_issue": "$LINEAR_ISSUE",
  "linear_project": "$LINEAR_PROJECT",
  "brief_doc": "$BRIEF_DOC",
  "max_iterations": $MAX_ITERATIONS,
  "verify_type": "$VERIFY_TYPE",
  "detected_skills": "$detected_skills",
  "iterations": [],
  "status": "running",
  "started_at": "$(date -Iseconds)"
}
EOF
}

update_state() {
  local iteration=$1
  local exit_code=$2
  local verification_result=$3
  local output_summary=$4

  local temp_file
  temp_file=$(mktemp)
  jq --arg iter "$iteration" \
     --arg exit "$exit_code" \
     --arg verify "$verification_result" \
     --arg summary "$output_summary" \
     --arg ts "$(date -Iseconds)" \
     '.iterations += [{
       "number": ($iter | tonumber),
       "exit_code": ($exit | tonumber),
       "verification": $verify,
       "summary": $summary,
       "timestamp": $ts
     }]' "$STATE_FILE" > "$temp_file"
  mv "$temp_file" "$STATE_FILE"
}

finalize_state() {
  local status=$1
  local temp_file
  temp_file=$(mktemp)
  jq --arg status "$status" \
     --arg ts "$(date -Iseconds)" \
     '.status = $status | .completed_at = $ts' "$STATE_FILE" > "$temp_file"
  mv "$temp_file" "$STATE_FILE"
}

# Run verification with detailed output capture
# NOTE: All log calls in this function go to stderr so they don't pollute
# the result string captured by the caller
run_verification() {
  local result="pass"
  local failures=""
  local details=""

  log "${BLUE}Running verification ($VERIFY_TYPE)...${NC}" >&2

  case $VERIFY_TYPE in
    tests)
      local output
      if output=$(pnpm test 2>&1); then
        : # Tests passed
      else
        result="fail"
        failures="tests"
        details=$(echo "$output" | grep -E "(FAIL|Error|failed)" | cat | head -10)
      fi
      echo "$output" >> "$LOG_FILE"
      ;;
    lint)
      local output
      if output=$(pnpm lint 2>&1); then
        : # Lint passed
      else
        result="fail"
        failures="lint"
        details=$(echo "$output" | grep -E "error" | cat | head -10)
      fi
      echo "$output" >> "$LOG_FILE"
      ;;
    typecheck)
      local output
      if output=$(pnpm typecheck 2>&1); then
        : # Typecheck passed
      else
        result="fail"
        failures="typecheck"
        details=$(echo "$output" | grep -E "error TS" | cat | head -10)
      fi
      echo "$output" >> "$LOG_FILE"
      ;;
    build)
      local output
      if output=$(pnpm build 2>&1); then
        : # Build passed
      else
        result="fail"
        failures="build"
        details=$(echo "$output" | grep -E "Error|error|FAIL" | cat | head -10)
      fi
      echo "$output" >> "$LOG_FILE"
      ;;
    quick)
      # Lint + typecheck only (faster)
      local lint_out ts_out
      if lint_out=$(pnpm lint 2>&1); then
        : # Lint passed
      else
        result="fail"
        failures="lint"
        details=$(echo "$lint_out" | grep -E "error" | cat | head -5)
      fi
      if ts_out=$(pnpm typecheck 2>&1); then
        : # Typecheck passed
      else
        result="fail"
        failures="${failures:+$failures,}typecheck"
        details="$details"$'\n'$(echo "$ts_out" | grep -E "error TS" | cat | head -5)
      fi
      echo "$lint_out" >> "$LOG_FILE"
      echo "$ts_out" >> "$LOG_FILE"
      ;;
    all|*)
      local test_out lint_out ts_out
      if test_out=$(pnpm test 2>&1); then
        : # Tests passed
      else
        result="fail"
        failures="tests"
        details=$(echo "$test_out" | grep -E "(FAIL|failed|Error)" | cat | head -5)
      fi
      if lint_out=$(pnpm lint 2>&1); then
        : # Lint passed
      else
        result="fail"
        failures="${failures:+$failures,}lint"
        details="$details"$'\n'$(echo "$lint_out" | grep -E "error" | cat | head -5)
      fi
      if ts_out=$(pnpm typecheck 2>&1); then
        : # Typecheck passed
      else
        result="fail"
        failures="${failures:+$failures,}typecheck"
        details="$details"$'\n'$(echo "$ts_out" | grep -E "error TS" | cat | head -5)
      fi

      echo "$test_out" >> "$LOG_FILE"
      echo "$lint_out" >> "$LOG_FILE"
      echo "$ts_out" >> "$LOG_FILE"
      ;;
  esac

  if [[ "$result" == "pass" ]]; then
    log "${GREEN}✓ Verification passed${NC}" >&2
  else
    log "${RED}✗ Verification failed: $failures${NC}" >&2
    if [[ -n "$details" ]]; then
      log "${YELLOW}Details:${NC}" >&2
      echo "$details" | head -10 >&2
    fi
  fi

  # Return result and details for prompt building (stdout only)
  echo "$result:$failures:$details"
}

# Build intelligent prompt using templates
build_intelligent_prompt() {
  local iteration=$1
  local previous_failures=$2
  local previous_output=$3

  if [[ $iteration -eq 1 ]]; then
    # First iteration: load context and create plan
    if [[ -n "$LINEAR_PROJECT" ]]; then
      # Project mode: load all issues and create project plan
      build_first_iteration_prompt_project "$TASK" "$LINEAR_PROJECT" "$VERIFY_TYPE" "$BRIEF_DOC"
    else
      # Single issue mode
      build_first_iteration_prompt "$TASK" "$LINEAR_ISSUE" "$VERIFY_TYPE" "$BRIEF_DOC"
    fi
  elif [[ -n "$previous_failures" && "$previous_failures" != "none" ]]; then
    # Retry after failure
    build_retry_prompt "$TASK" "$iteration" "$MAX_ITERATIONS" "$previous_failures" "$previous_output" "$VERIFY_TYPE"
  else
    # Normal iteration: pick next task from plan
    build_iteration_prompt "$TASK" "$iteration" "$MAX_ITERATIONS" "$VERIFY_TYPE" "$previous_failures"
  fi
}

# Main loop
main() {
  init_state

  # Initialize .ralph/ working directory
  init_ralph_files "$LINEAR_ISSUE" "$BRIEF_DOC" "$TASK"

  local detected_skills
  detected_skills=$(detect_task_skills "$TASK")

  log ""
  log "${CYAN}╔══════════════════════════════════════════════════════════════╗${NC}"
  log "${CYAN}║     Ralph Wiggum Loop - File-Based Iteration Mode            ║${NC}"
  log "${CYAN}╚══════════════════════════════════════════════════════════════╝${NC}"
  log ""
  log "${BLUE}Task:${NC} $TASK"
  log "${BLUE}Max iterations:${NC} $MAX_ITERATIONS"
  log "${BLUE}Verification:${NC} $VERIFY_TYPE"
  [[ -n "$LINEAR_ISSUE" ]] && log "${BLUE}Linear issue:${NC} $LINEAR_ISSUE"
  [[ -n "$LINEAR_PROJECT" ]] && log "${BLUE}Linear project:${NC} $LINEAR_PROJECT"
  [[ -n "$BRIEF_DOC" ]] && log "${BLUE}Brief doc:${NC} $BRIEF_DOC"
  [[ "$VISUAL_CHECK" == "true" ]] && log "${BLUE}Visual check:${NC} enabled (Playwright)"
  log "${BLUE}Detected skills:${NC} $detected_skills"
  log "${BLUE}Run ID:${NC} $RUN_ID"
  log "${BLUE}Working dir:${NC} .ralph/"
  log ""
  log "${YELLOW}Files:${NC}"
  log "  • .ralph/plan.md - Task list with pass/fail status"
  log "  • .ralph/activity.md - Progress log between iterations"
  log ""

  local iteration=0
  local previous_failures=""
  local previous_output=""

  while [[ $iteration -lt $MAX_ITERATIONS ]]; do
    iteration=$((iteration + 1))

    log "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    log "${YELLOW}Iteration $iteration of $MAX_ITERATIONS${NC}"
    log "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    # Build intelligent prompt
    local prompt
    prompt=$(build_intelligent_prompt $iteration "$previous_failures" "$previous_output")

    if [[ "$DRY_RUN" == "true" ]]; then
      log "${BLUE}[DRY RUN] Prompt that would be sent:${NC}"
      echo "$prompt" | head -50
      log "..."
      log "${BLUE}[DRY RUN] Would execute: claude -p --permission-mode acceptEdits --max-budget-usd $BUDGET --allowedTools ...${NC}"
      # In dry-run, simulate success path (no failures)
      previous_failures="none"
      log ""
      log "${BLUE}[DRY RUN] Simulating successful iteration...${NC}"
      continue
    fi

    # Build claude command args as array for proper quoting
    # Note: Each iteration is a FRESH context window (no -c flag)
    # This is intentional - context is carried via .ralph/plan.md and .ralph/activity.md
    # --permission-mode acceptEdits allows file edits without prompting
    # --allowedTools: MUST use explicit tool names, NOT wildcards (wildcards cause silent failures)
    local allowed_tools="mcp__brief__brief_get_onboarding_context,mcp__brief__brief_prepare_context,mcp__brief__brief_execute_operation,mcp__linear-server__get_issue,mcp__linear-server__list_issues,mcp__linear-server__get_project,mcp__linear-server__update_issue,Read,Edit,Write,Glob,Grep,TodoWrite,Bash"

    # Add Playwright tools if visual check is enabled
    if [[ "$VISUAL_CHECK" == "true" ]]; then
      allowed_tools="$allowed_tools,mcp__playwright__browser_navigate,mcp__playwright__browser_screenshot,mcp__playwright__browser_click,mcp__playwright__browser_type,mcp__playwright__browser_select_option,mcp__playwright__browser_hover,mcp__playwright__browser_evaluate,mcp__playwright__browser_close"
    fi

    local -a claude_args=(
      -p
      --permission-mode acceptEdits
      --max-budget-usd "$BUDGET"
      --allowedTools "$allowed_tools"
      --
    )

    # Run claude
    log "${BLUE}Running claude (budget: \$$BUDGET)...${NC}"
    local output_file
    output_file=$(mktemp)
    local claude_exit=0

    if [[ "$VERBOSE" == "true" ]]; then
      # Use script command for unbuffered output on macOS
      # script -q runs quietly and flushes output immediately
      if [[ "$(uname)" == "Darwin" ]]; then
        # macOS: use script for unbuffered output
        script -q "$output_file" claude "${claude_args[@]}" "$prompt" 2>&1 || claude_exit=$?
        cat "$output_file" >> "$LOG_FILE"
      elif command -v stdbuf &>/dev/null; then
        # Linux: use stdbuf
        stdbuf -oL claude "${claude_args[@]}" "$prompt" 2>&1 | stdbuf -oL tee "$output_file" | tee -a "$LOG_FILE" || claude_exit=$?
      else
        # Fallback without unbuffering
        claude "${claude_args[@]}" "$prompt" 2>&1 | tee "$output_file" | tee -a "$LOG_FILE" || claude_exit=$?
      fi
    else
      claude "${claude_args[@]}" "$prompt" > "$output_file" 2>&1 || claude_exit=$?
      # Show summary
      log "${BLUE}Agent output summary:${NC}"
      tail -30 "$output_file" | tee -a "$LOG_FILE"
    fi

    # Run verification
    local verify_status=""
    local verify_failures=""
    local verify_details=""
    if [[ $claude_exit -ne 0 ]]; then
      verify_status="fail"
      verify_failures="claude"
      verify_details="claude exited with code $claude_exit"
      log "${RED}✗ Claude failed (exit $claude_exit). Skipping verification.${NC}"
    else
      local verify_result
      verify_result=$(run_verification)
      verify_status="${verify_result%%:*}"
      local verify_rest="${verify_result#*:}"
      verify_failures="${verify_rest%%:*}"
      # verify_details available for future detailed error reporting
      # verify_details="${verify_rest#*:}"
    fi

    # Capture output for next iteration
    previous_output=$(tail -50 "$output_file")

    # Check for RALPH_COMPLETE signal in output (before removing file)
    local ralph_complete=false
    if grep -q "RALPH_COMPLETE" "$output_file" 2>/dev/null; then
      ralph_complete=true
      log "${GREEN}✓ Agent signaled RALPH_COMPLETE${NC}"
    fi

    # Update state
    local output_summary
    output_summary=$(head -5 "$output_file" && echo "..." && tail -5 "$output_file")
    update_state "$iteration" "$claude_exit" "$verify_status" "$output_summary"

    rm -f "$output_file"

    # Check plan.md completion
    local plan_status
    plan_status=$(check_plan_complete)
    if [[ "$plan_status" == "complete" ]]; then
      log "${GREEN}✓ All tasks in plan.md are passing${NC}"
    fi

    # Success conditions: verification passes AND (ralph_complete OR plan complete)
    if [[ "$verify_status" == "pass" && ("$ralph_complete" == "true" || "$plan_status" == "complete") ]]; then
      log ""
      log "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
      log "${GREEN}║                    SUCCESS!                                   ║${NC}"
      log "${GREEN}║              Completed in $iteration iteration(s)                      ║${NC}"
      log "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"

      # Run full prep if requested
      if [[ "$FULL_PREP" == "true" ]]; then
        log ""
        log "${BLUE}Running full /prep checklist...${NC}"
        if pnpm build 2>&1 | tee -a "$LOG_FILE"; then
          log "${GREEN}✓ Full prep passed${NC}"
        else
          log "${YELLOW}⚠ Build had warnings - review recommended${NC}"
        fi
      fi

      finalize_state "success"
      exit 0
    fi

    # Continue to next iteration
    if [[ "$verify_status" == "pass" ]]; then
      # Verification passed but tasks remain - continue normally
      previous_failures="none"
      log ""
      log "${BLUE}Verification passed. Continuing to next task...${NC}"
    else
      # Verification failed - store failure for retry prompt
      previous_failures="$verify_failures"
      log ""
      log "${YELLOW}Verification failed. Continuing to iteration $((iteration + 1))...${NC}"
    fi

    # Escalation warning at iteration 3
    if [[ $iteration -eq 3 ]]; then
      log ""
      log "${RED}⚠ ESCALATION WARNING: 3 iterations without full completion${NC}"
      log "${RED}  Check .ralph/plan.md and .ralph/activity.md for progress.${NC}"
    fi
  done

  # Max iterations reached
  log ""
  log "${RED}╔══════════════════════════════════════════════════════════════╗${NC}"
  log "${RED}║                    FAILED                                    ║${NC}"
  log "${RED}║         Max iterations ($MAX_ITERATIONS) reached                        ║${NC}"
  log "${RED}╚══════════════════════════════════════════════════════════════╝${NC}"
  log ""
  log "State file: $STATE_FILE"
  log "Log file: $LOG_FILE"
  log ""
  log "Review the log for patterns in failures."
  log "Consider breaking the task into smaller pieces."

  finalize_state "max_iterations_reached"
  exit 1
}

# Run
main
