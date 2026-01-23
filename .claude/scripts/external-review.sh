#!/bin/bash
# external-review.sh - Get code review from external AI models
# Usage: ./external-review.sh [model] [file_or_diff]
# Models:
#   codex (default) - OpenAI gpt-5.2-codex (code-optimized)
#   5.2, gpt-5.2    - OpenAI GPT-5.2 (frontier model)
#   gemini          - Google Gemini 2.0 Flash
#   gemini3         - Google Gemini 3.0 Pro (frontier)
#   council, all    - Run all available models and combine findings

set -e

MODEL="${1:-codex}"
TARGET="${2:-}"

# Load environment from .env.local in project root
ENV_FILE="$(git rev-parse --show-toplevel 2>/dev/null)/.env.local"
if [ -f "$ENV_FILE" ]; then
  export $(grep -E "^(OPENAI_API_KEY|GEMINI_API_KEY)=" "$ENV_FILE" | xargs)
fi

# Get code to review
if [ -n "$TARGET" ] && [ -f "$TARGET" ]; then
  CODE=$(cat "$TARGET")
  CONTEXT="File: $TARGET"
elif [ -n "$TARGET" ]; then
  CODE="$TARGET"
  CONTEXT="Code snippet"
elif [ ! -t 0 ]; then
  # Read from stdin if piped
  CODE=$(cat)
  CONTEXT="Piped input"
else
  # Default to staged diff
  CODE=$(git diff --cached 2>/dev/null || git diff)
  CONTEXT="Git diff (staged or working changes)"
fi

if [ -z "$CODE" ]; then
  echo "Error: No code to review. Stage changes or specify a file." >&2
  exit 1
fi

REVIEW_PROMPT="You are a senior engineer reviewing code for a production SaaS application.

Review this code and identify:
1. **Bugs** - Logic errors, edge cases, potential crashes
2. **Security** - Auth issues, injection risks, data exposure
3. **Performance** - Unnecessary operations, N+1 queries, memory leaks
4. **Code Quality** - Unclear logic, missing error handling, poor naming

Be specific. Include file:line references where possible.
Keep findings concise - one line per issue.

Format:
### Bugs
- [file:line] Description

### Security
- [file:line] Description

### Performance
- [file:line] Description

### Code Quality
- [file:line] Description

### Summary
X critical, Y warnings, Z suggestions

---
$CONTEXT

\`\`\`
$CODE
\`\`\`"

case "$MODEL" in
  codex|openai)
    if [ -z "$OPENAI_API_KEY" ]; then
      echo "Error: OPENAI_API_KEY not set" >&2
      exit 1
    fi

    # Escape for JSON
    ESCAPED_PROMPT=$(echo "$REVIEW_PROMPT" | jq -Rs .)

    # gpt-5.2-codex - OpenAI's code-optimized 5.2 variant (uses responses API, no temperature)
    RESPONSE=$(curl -s https://api.openai.com/v1/responses \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $OPENAI_API_KEY" \
      -d "{
        \"model\": \"gpt-5.2-codex\",
        \"input\": $ESCAPED_PROMPT,
        \"max_output_tokens\": 4000
      }")

    # Extract content from responses API (output array, find message type)
    CONTENT=$(echo "$RESPONSE" | jq -r '
      if .error then .error.message
      elif .output then ([.output[] | select(.type == "message") | .content[0].text] | first) // "No content in response"
      else "Error: Unknown response format"
      end
    ')
    echo "$CONTENT"
    ;;

  5.2|gpt-5.2)
    if [ -z "$OPENAI_API_KEY" ]; then
      echo "Error: OPENAI_API_KEY not set" >&2
      exit 1
    fi

    ESCAPED_PROMPT=$(echo "$REVIEW_PROMPT" | jq -Rs .)

    # gpt-5.2 - OpenAI's frontier model
    RESPONSE=$(curl -s https://api.openai.com/v1/chat/completions \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $OPENAI_API_KEY" \
      -d "{
        \"model\": \"gpt-5.2\",
        \"messages\": [{\"role\": \"user\", \"content\": $ESCAPED_PROMPT}],
        \"temperature\": 0.3
      }")

    # Extract content
    echo "$RESPONSE" | jq -r '.choices[0].message.content // .error.message // "Error: Unknown response"'
    ;;

  gemini|google)
    if [ -z "$GEMINI_API_KEY" ]; then
      echo "Error: GEMINI_API_KEY not set" >&2
      exit 1
    fi

    ESCAPED_PROMPT=$(echo "$REVIEW_PROMPT" | jq -Rs .)

    # Gemini 2.0 Flash - fast and capable
    RESPONSE=$(curl -s "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$GEMINI_API_KEY" \
      -H "Content-Type: application/json" \
      -d "{
        \"contents\": [{\"parts\": [{\"text\": $ESCAPED_PROMPT}]}],
        \"generationConfig\": {\"temperature\": 0.3}
      }")

    echo "$RESPONSE" | jq -r '.candidates[0].content.parts[0].text // .error.message // "Error: Unknown response"'
    ;;

  gemini3|gemini-3)
    if [ -z "$GEMINI_API_KEY" ]; then
      echo "Error: GEMINI_API_KEY not set" >&2
      exit 1
    fi

    ESCAPED_PROMPT=$(echo "$REVIEW_PROMPT" | jq -Rs .)

    # Gemini 3 - Google's frontier model
    RESPONSE=$(curl -s "https://generativelanguage.googleapis.com/v1beta/models/gemini-3.0-pro:generateContent?key=$GEMINI_API_KEY" \
      -H "Content-Type: application/json" \
      -d "{
        \"contents\": [{\"parts\": [{\"text\": $ESCAPED_PROMPT}]}],
        \"generationConfig\": {\"temperature\": 0.3}
      }")

    echo "$RESPONSE" | jq -r '.candidates[0].content.parts[0].text // .error.message // "Error: Unknown response"'
    ;;

  council|all)
    # Run all available models and combine findings
    echo "=== Council of Agents Code Review ==="
    echo ""

    if [ -n "$OPENAI_API_KEY" ]; then
      echo "### OpenAI Codex (gpt-5.2-codex)"
      echo ""
      # Run codex
      ESCAPED_PROMPT=$(echo "$REVIEW_PROMPT" | jq -Rs .)
      RESPONSE=$(curl -s https://api.openai.com/v1/responses \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $OPENAI_API_KEY" \
        -d "{
          \"model\": \"gpt-5.2-codex\",
          \"input\": $ESCAPED_PROMPT,
          \"max_output_tokens\": 4000
        }")
      echo "$RESPONSE" | jq -r '
        if .error then .error.message
        elif .output then ([.output[] | select(.type == "message") | .content[0].text] | first) // "No content"
        else "Error"
        end
      '
      echo ""
      echo "---"
      echo ""

      echo "### OpenAI GPT-5.2"
      echo ""
      RESPONSE=$(curl -s https://api.openai.com/v1/chat/completions \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $OPENAI_API_KEY" \
        -d "{
          \"model\": \"gpt-5.2\",
          \"messages\": [{\"role\": \"user\", \"content\": $ESCAPED_PROMPT}],
          \"temperature\": 0.3
        }")
      echo "$RESPONSE" | jq -r '.choices[0].message.content // .error.message // "Error"'
      echo ""
      echo "---"
      echo ""
    fi

    if [ -n "$GEMINI_API_KEY" ]; then
      echo "### Google Gemini"
      echo ""
      RESPONSE=$(curl -s "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$GEMINI_API_KEY" \
        -H "Content-Type: application/json" \
        -d "{
          \"contents\": [{\"parts\": [{\"text\": $ESCAPED_PROMPT}]}],
          \"generationConfig\": {\"temperature\": 0.3}
        }")
      echo "$RESPONSE" | jq -r '.candidates[0].content.parts[0].text // .error.message // "Error"'
      echo ""
    fi
    ;;

  *)
    echo "Unknown model: $MODEL. Use 'codex', '5.2', 'gemini', 'gemini3', or 'council'" >&2
    exit 1
    ;;
esac
