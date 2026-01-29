#!/usr/bin/env bash

# Ralph Wiggum Loop - File-Based Prompt Templates
#
# Uses plan.md and activity.md to carry context between iterations.
# Each iteration is a fresh context window with a SHORT prompt.
#
# FILES:
#   - plan.md: JSON tasks with passes: true/false status
#   - activity.md: Log of what happened each iteration
#
# CONTEXT LOADING:
#   - Brief MCP: Product context, decisions (first iteration only)
#   - Linear: Issue details, acceptance criteria (first iteration only)
#
# Skills are invoked by reference, not embedded in prompt.

# Directory for Ralph working files
RALPH_WORK_DIR=".ralph"

# Visual check instructions (included when VISUAL_CHECK=true)
get_visual_check_instructions() {
  if [[ "${VISUAL_CHECK:-false}" == "true" ]]; then
    cat <<'VISUAL'

## Visual Verification (Playwright)

You have access to Playwright MCP for visual testing. After implementing UI changes:

1. **Start dev server** if not running: `pnpm dev` (background)
2. **Navigate** to the relevant page: `mcp__playwright__browser_navigate`
3. **Interact** with the UI to test the flow:
   - Click buttons: `mcp__playwright__browser_click`
   - Fill forms: `mcp__playwright__browser_type`
   - Select options: `mcp__playwright__browser_select_option`
4. **Screenshot** key states: `mcp__playwright__browser_screenshot`
5. **Verify** the UI looks correct and functions properly

Test user flows, not just static pages. For example:
- Edit a document → verify SaveStatus shows "Saving..." then "Saved"
- Navigate away → verify changes persisted
- Submit a form → verify success/error states

Include visual verification results in .ralph/activity.md.
VISUAL
  fi
}

# Initialize Ralph working directory and files
init_ralph_files() {
  local linear_issue="$1"
  local brief_doc="$2"
  local task="$3"
  local linear_project="${LINEAR_PROJECT:-}"

  mkdir -p "$RALPH_WORK_DIR"

  # Create empty activity.md if it doesn't exist
  if [[ ! -f "$RALPH_WORK_DIR/activity.md" ]]; then
    if [[ -n "$linear_project" ]]; then
      cat > "$RALPH_WORK_DIR/activity.md" <<EOF
# Ralph Activity Log

Started: $(date -Iseconds)
Task: $task
Linear Project: $linear_project
Brief Doc: ${brief_doc:-none}
Mode: Multi-issue project

---

EOF
    else
      cat > "$RALPH_WORK_DIR/activity.md" <<EOF
# Ralph Activity Log

Started: $(date -Iseconds)
Task: $task
Linear: ${linear_issue:-none}
Brief Doc: ${brief_doc:-none}

---

EOF
    fi
  fi
}

# First iteration prompt for LINEAR PROJECT - Creates plan.md from all project issues
build_first_iteration_prompt_project() {
  local task="$1"
  local linear_project="$2"
  local verify_type="$3"
  local brief_doc="$4"

  # Build verification criteria
  local verify_criteria=""
  case $verify_type in
    tests) verify_criteria="pnpm test";;
    lint) verify_criteria="pnpm lint";;
    typecheck) verify_criteria="pnpm typecheck";;
    build) verify_criteria="pnpm build";;
    quick) verify_criteria="pnpm lint && pnpm typecheck";;
    all|*) verify_criteria="pnpm test && pnpm lint && pnpm typecheck";;
  esac

  cat <<PROMPT
# Ralph Wiggum Loop - Iteration 1 (Project Setup)

## Task
$task

## Step 1: Load Project Context

This is a **multi-issue project**. Load all context:

1. **Load Brief product context** using mcp__brief__brief_get_onboarding_context
2. **Load the PRD** "${brief_doc}" from Brief using mcp__brief__brief_prepare_context with preparation_type="search"
3. **Load all project issues** using mcp__linear-server__list_issues with project="$linear_project"
   - This will return all issues in dependency order
   - Note each issue's ID, title, description, and priority

## Step 2: Create Project Plan

After loading context, create .ralph/plan.md with this JSON format:

\`\`\`json
{
  "goal": "Brief description from PRD",
  "project": "$linear_project",
  "tasks": [
    {
      "id": 1,
      "linear_id": "BRI-XXX",
      "linear_issue_id": "uuid-here",
      "title": "Issue title from Linear",
      "category": "backend|frontend|integration|test",
      "description": "What needs to be done (from issue description)",
      "acceptance_criteria": ["From the issue"],
      "passes": false
    }
  ]
}
\`\`\`

**IMPORTANT**: Create ONE task per Linear issue. Order tasks by:
1. Blocking relationships (do blockers first)
2. Priority (High before Medium before Low)
3. Issue number (lower numbers first for same priority)

## Step 3: Start First Task

Pick the first task where passes=false. Work on it following Brief patterns:
- API routes: Zod validation, withV1Auth middleware, V1_ERRORS
- Database: Drizzle ORM, migrations, proper typing
- UI: TailStack components from @/components/ui/*
- Tests: Write test first (TDD), 80% coverage

When done with the task:
1. Update .ralph/plan.md to set passes=true
2. Update Linear issue status to "In Progress" → "Done" using mcp__linear-server__update_issue
3. Git commit with message referencing the issue (e.g., "feat(BRI-XXX): ...")

## Step 4: Log Progress

Append to .ralph/activity.md:
- Which Linear issue you completed
- What files you changed
- Any decisions made

## Verification
$verify_criteria
$(get_visual_check_instructions)

Output "RALPH_COMPLETE" when ALL tasks in plan.md have passes=true.
PROMPT
}

# First iteration prompt - Creates plan.md from context
build_first_iteration_prompt() {
  local task="$1"
  local linear_issue="$2"
  local verify_type="$3"
  local brief_doc="$4"

  # Build context loading instructions
  local context_steps=""

  if [[ -n "$linear_issue" ]]; then
    context_steps="1. Load Linear issue $linear_issue using mcp__linear-server__get_issue"
  fi

  if [[ -n "$brief_doc" ]]; then
    context_steps="$context_steps
2. Search Brief for document \"$brief_doc\" using mcp__brief__brief_prepare_context"
  fi

  # Build verification criteria
  local verify_criteria=""
  case $verify_type in
    tests) verify_criteria="pnpm test";;
    lint) verify_criteria="pnpm lint";;
    typecheck) verify_criteria="pnpm typecheck";;
    build) verify_criteria="pnpm build";;
    quick) verify_criteria="pnpm lint && pnpm typecheck";;
    all|*) verify_criteria="pnpm test && pnpm lint && pnpm typecheck";;
  esac

  cat <<PROMPT
# Ralph Wiggum Loop - Iteration 1 (Setup)

## Task
$task

## Step 1: Load Context
$context_steps

Also load Brief product context using mcp__brief__brief_get_onboarding_context to understand the product.

## Step 2: Create Plan

After loading context, create .ralph/plan.md with this JSON format:

\`\`\`json
{
  "goal": "Brief description of the goal",
  "tasks": [
    {
      "id": 1,
      "category": "setup|backend|frontend|test|docs",
      "description": "What needs to be done",
      "steps": ["Step 1", "Step 2"],
      "test_type": "integration|specification",
      "passes": false
    }
  ]
}
\`\`\`

**Task fields:**
- \`category\`: Type of work (setup, backend, frontend, test, docs)
- \`test_type\`: REQUIRED for test tasks. Use "integration" for tests that call actual code/verify mocks, "specification" for behavioral documentation tests
- \`passes\`: Set to true when task is complete and verified

Break the work into small, testable tasks. Each task should be completable in one iteration.

## Step 3: Start First Task

Pick the first task where passes=false. Work on it following Brief patterns:
- API routes: Zod validation, withV1Auth middleware
- UI: TailStack components from @/components/ui/*
- Tests: Follow regression testing rules below

### Regression Testing Rules (CRITICAL)

When writing tests for bug fixes:

1. **Tests must exercise the actual code path** - Don't write simulation tests that just demonstrate expected behavior with plain JavaScript. Tests should call the actual function or verify mock calls.

2. **Verify mock completeness** - If your fix adds new method calls (e.g., changing .insert() to .upsert()), update the test mocks to include the new methods. Before marking a test task complete:
   - Search the test file for mock definitions (e.g., \`mockSupabaseClient\`)
   - Verify ALL methods called in your implementation have corresponding mock definitions
   - Add missing mock methods before running tests

3. **Revert check for bug fixes** - After writing a regression test:
   - Temporarily revert your fix (comment out the change)
   - Run the test - it MUST FAIL
   - Restore the fix - test MUST PASS
   - This proves the test actually catches the bug

4. **Regression test structure**:
   - Import or mock the actual function being fixed
   - Set up mocks to simulate the error condition
   - Verify the fix handles the condition correctly
   - If testing Supabase methods, verify the mock was called with correct options

5. **Test types** - Specify in plan.md which type each test is:
   - **integration**: Calls actual function, verifies behavior through mocks (PREFERRED for bug fixes)
   - **specification**: Documents expected behavior only (mark with "spec" in test name)

When done with the task, update .ralph/plan.md to set passes=true.

## Step 4: Log Progress

Append to .ralph/activity.md what you accomplished this iteration.

## Verification
$verify_criteria
$(get_visual_check_instructions)

Output "RALPH_COMPLETE" when ALL tasks in plan.md have passes=true.
PROMPT
}

# Subsequent iteration prompt - Reads files, works on ONE task
build_iteration_prompt() {
  local task="$1"
  local iteration="$2"
  local max_iterations="$3"
  local verify_type="$4"
  local failures="$5"

  # Build verification criteria
  local verify_criteria=""
  case $verify_type in
    tests) verify_criteria="pnpm test";;
    lint) verify_criteria="pnpm lint";;
    typecheck) verify_criteria="pnpm typecheck";;
    build) verify_criteria="pnpm build";;
    quick) verify_criteria="pnpm lint && pnpm typecheck";;
    all|*) verify_criteria="pnpm test && pnpm lint && pnpm typecheck";;
  esac

  cat <<PROMPT
# Ralph Wiggum Loop - Iteration $iteration of $max_iterations

## Task
$task

## Step 1: Check Progress

Read .ralph/activity.md to see what was accomplished in previous iterations.
Read .ralph/plan.md to see the task list and status.

## Step 2: Pick ONE Task

Find the highest priority task in plan.md where passes=false.
Work on EXACTLY ONE task this iteration.

$(if [[ -n "$failures" && "$failures" != "none" ]]; then
cat <<FAIL_BLOCK
## Previous Failures
The last iteration failed verification: $failures

Investigate and fix the issue before continuing with new work.
FAIL_BLOCK
fi)

## Step 3: Implement

Follow Brief patterns:
- Search existing code first (Glob, Grep) before creating new files
- API routes: Zod validation, withV1Auth middleware, V1_ERRORS
- UI: TailStack components, semantic color tokens
- Tests: Write test first, 80% coverage

**Bug fix testing checklist:**
- Tests MUST exercise actual code, not just simulate behavior
- Update mocks if adding new method calls (e.g., .upsert(), .delete())
- **Revert check**: Temporarily undo fix → test should FAIL → restore fix → test should PASS
- Specify test_type in plan.md: "integration" (preferred) or "specification"

## Step 4: Update Files

When the task is complete:
1. Update .ralph/plan.md - set the task's passes=true
2. If task has a linear_id, update Linear issue status using mcp__linear-server__update_issue
3. Append to .ralph/activity.md - describe what you changed
4. Git commit with clear message referencing issue ID (if changes were made)

## Verification
$verify_criteria
$(get_visual_check_instructions)

Output "RALPH_COMPLETE" when ALL tasks in plan.md have passes=true.
PROMPT
}

# Retry prompt after verification failure
build_retry_prompt() {
  local task="$1"
  local iteration="$2"
  local max_iterations="$3"
  local failures="$4"
  local previous_output="$5"
  local verify_type="$6"

  # Build verification criteria
  local verify_criteria=""
  case $verify_type in
    tests) verify_criteria="pnpm test";;
    lint) verify_criteria="pnpm lint";;
    typecheck) verify_criteria="pnpm typecheck";;
    build) verify_criteria="pnpm build";;
    quick) verify_criteria="pnpm lint && pnpm typecheck";;
    all|*) verify_criteria="pnpm test && pnpm lint && pnpm typecheck";;
  esac

  cat <<PROMPT
# Ralph Wiggum Loop - Iteration $iteration of $max_iterations (Fixing Failures)

## Task
$task

## What Failed
$failures

## Previous Output (last 30 lines)
$previous_output

## Instructions

1. Read .ralph/activity.md and .ralph/plan.md
2. Investigate the failure - read the actual error messages
3. Fix the specific issue (don't make random changes)
4. Update .ralph/activity.md with what you fixed
5. Run verification: $verify_criteria

$(if [[ $iteration -ge 3 ]]; then
cat <<ESCALATION

## Warning: Iteration $iteration

You've had $((iteration - 1)) failed attempts. Consider:
- Is the approach fundamentally wrong?
- Is the task too big? Break it down further.
- Is there a conflicting Brief decision? Check with guard_approach.
ESCALATION
fi)
$(get_visual_check_instructions)

Output "RALPH_COMPLETE" when ALL tasks in plan.md have passes=true.
PROMPT
}

# Check if all tasks in plan.md are complete
check_plan_complete() {
  local plan_file="$RALPH_WORK_DIR/plan.md"

  if [[ ! -f "$plan_file" ]]; then
    echo "no_plan"
    return
  fi

  # Extract JSON from plan.md (between ```json and ```)
  local json_content
  json_content=$(sed -n '/```json/,/```/p' "$plan_file" | grep -v '```')

  if [[ -z "$json_content" ]]; then
    echo "no_json"
    return
  fi

  # Check if any task has passes=false
  if echo "$json_content" | jq -e '.tasks[] | select(.passes == false)' > /dev/null 2>&1; then
    echo "incomplete"
  else
    echo "complete"
  fi
}

# Enhanced skill detection (kept for logging purposes)
# Consolidated skills: development (tdd+debugging+testing), patterns (api+security), extensions (chrome+mcp)
# Separate skills: brief-design, visual-testing
detect_task_skills() {
  local task="$1"
  local skills=""

  # API/backend work
  if echo "$task" | grep -qiE "api|route|endpoint|backend|database|query|drizzle|supabase"; then
    skills="$skills patterns"
  fi

  # Frontend/UI work
  if echo "$task" | grep -qiE "component|ui|frontend|page|button|form|modal|design|panel|card|dialog|table|list"; then
    skills="$skills brief-design"
  fi

  # Bug fixes, new features, tests -> development skill (TDD + debugging + testing-strategy)
  if echo "$task" | grep -qiE "bug|fix|error|broken|failing|issue|debug|add|implement|create|new|feature|build|test|coverage|spec|vitest"; then
    skills="$skills development"
  fi

  # Extension/MCP work
  if echo "$task" | grep -qiE "extension|chrome|mcp|tool"; then
    skills="$skills extensions"
  fi

  # Visual testing (when --visual-check is enabled)
  if [[ "${VISUAL_CHECK:-false}" == "true" ]]; then
    skills="$skills visual-testing"
  fi

  echo "$skills"
}
