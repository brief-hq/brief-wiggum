---
description: Check session health and recommend when to start fresh
---

# /session-check

Evaluate the current session's efficiency and recommend whether to continue or start fresh.

## When to Run

- Periodically during long work sessions
- When you feel the session has been going a while
- Before starting a new task in an existing session
- When responses feel slower or less focused

## Assessment Checklist

### 1. Session Length

Count approximate tool calls made in this session by reviewing conversation history.

| Tool Calls | Status | Action |
|------------|--------|--------|
| < 30 | Healthy | Continue |
| 30-50 | Getting long | Consider wrapping up current task, then fresh session |
| 50-100 | Long | Finish immediate task, then `/transfer-context` to new session |
| > 100 | Too long | `/transfer-context` NOW — you're paying 3-5x per turn in cache costs |

### 2. Task Scope

Check if this session is still focused on a single task:

- **Single task?** Continue
- **Drifted to a second task?** Finish current, start new session for the next
- **Third+ task?** Start fresh — context from old tasks is waste

### 3. File Read Efficiency

Review files you've read this session:

- Have you read the **same file more than twice** without editing it between reads? Stop re-reading — use what you know
- Are you reading **entire files** when you only need one function? Use offset/limit for targeted reads
- Could a **sub-agent** handle the search/exploration instead? Use Task tool to isolate context

### 4. Sub-agent Model Selection

If you've launched sub-agents this session:

- Were they doing simple tasks (grep, file reads, single edits)? → Should be `model: "fast"`
- Were they doing multi-step reasoning or architecture? → Default model is appropriate

## Output

Report the session health:

```
Session Health Check:
- Tool calls: ~[N] (Healthy/Getting long/Long/Too long)
- Task focus: [single/drifted/multi]
- File re-reads: [none/some/excessive]
- Recommendation: [continue / wrap up soon / transfer now]
```

If recommending transfer:
1. Summarize current task state
2. Run `/transfer-context` to generate handoff prompt
3. Tell user: "Start a new session and paste the handoff prompt to continue efficiently"

## Why This Matters

Real data from usage:
- A 900-turn session costs **$13+** when a fresh-start approach would cost **$2-3**
- Reading the same file 32 times in one session wastes **thousands of tokens**
- Prompt cache grows from ~20K tokens/turn to **150K tokens/turn** over long sessions
- Starting fresh is almost always cheaper than continuing a bloated session
