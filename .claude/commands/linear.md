---
description: Fetch a Linear issue and optionally start working on it
---

# /linear <issue-id>

Fetch a Linear issue by its identifier (e.g., `[TEAM_PREFIX]-786`) and prepare to work on it.

## Arguments

- `$ARGUMENTS` — the Linear issue identifier (e.g., `[TEAM_PREFIX]-786`)

## Steps

1. **Fetch the issue** using the linearis CLI:
   ```bash
   linearis issues read $ARGUMENTS
   ```
   Extract: title, description, status, priority, assignee, labels, acceptance criteria, branch name, relations

2. **Enrich with product context** via `brief ask`:
   - Call `brief ask` in advise mode with the issue context:
     ```bash
     brief ask --context "Preparing to work on [identifier]" \
       "What do I need to know to work on this? Issue: [title]. Description: [description summary]"
     ```
   - This surfaces relevant decisions, customer signals, and related work that pure Linear data won't show.

3. **Display the issue** with Brief context in a clear summary:
   ```
   ## <identifier>: <title>
   **Status:** <status> | **Priority:** <priority> | **Assignee:** <assignee>
   **Labels:** <labels>
   **Branch:** <branchName>

   ### Description
   <description>

   ### Acceptance Criteria
   <extracted from description if present>

   ### Brief Context
   <key insights from brief ask — relevant decisions, customer signals, related work>
   ```

4. **Ask the user** what they'd like to do:
   - "Start working on this" -> create the branch (if not already on it), enter plan mode
   - "Just viewing" -> done

## Notes

- If linearis is not configured, prompt the user to set up a Linear API token (Settings -> Security & Access -> Personal API keys) and save it to `~/.linear_api_token`
- The branch name comes from the Linear issue's `branchName` field — use it for `git checkout -b`
- If the issue has linked Brief documents, mention them so the user can load context with `/onboard`
