---
description: Reduce complexity while maintaining Brief brand identity
---

# /design-simplify

Simplify a component by removing unnecessary complexity while preserving Brief's design language.

## Usage

```
/design-simplify [component-path-or-selection]
```

## Context Gathering

Before simplifying, ask these clarifying questions:

1. **Constraints**: Are there accessibility requirements (ARIA patterns) that must be preserved?
2. **Dependencies**: Are other components consuming this one (breaking change risk)?
3. **Intentional complexity**: Is any nesting/verbosity deliberate (e.g., animation targets, test hooks)?

If the user provides a clear target and no special concerns, proceed directly.

## Simplification Strategies

### 1. Flatten Nesting

Remove excessive wrapper divs and nested structures:

```tsx
// Before (over-nested)
<div className="container">
  <div className="wrapper">
    <div className="inner">
      <Card>
        <div className="card-wrapper">
          <CardContent>
            <div className="content-inner">
              <Text />
            </div>
          </CardContent>
        </div>
      </Card>
    </div>
  </div>
</div>

// After (flat)
<Card>
  <CardContent>
    <Text />
  </CardContent>
</Card>
```

### 2. Reduce Class Proliferation

Consolidate redundant Tailwind classes:

```tsx
// Before (verbose)
<div className="flex flex-row items-center justify-start gap-2 w-full">

// After (simplified)
<div className="flex items-center gap-2 w-full">
```

### 3. Remove Defensive Overrides

Strip unnecessary `!important` and specificity hacks:

```tsx
// Before
className="!bg-white !text-black !border-gray-200"

// After (trust the cascade)
className="bg-background text-foreground border-border"
```

### 4. Eliminate Duplicate States

Consolidate hover/focus/active states:

```tsx
// Before (repetitive)
className="bg-primary hover:bg-primary/90 active:bg-primary/80 focus:bg-primary/90"

// After (Button handles this)
<Button>Click</Button>
```

### 5. Simplify Conditionals

Replace complex ternaries with `cn()`:

```tsx
// Before
className={`base-class ${isActive ? 'active-class' : ''} ${isDisabled ? 'disabled-class' : ''}`}

// After
import { cn } from "@/lib/utils";
className={cn("base-class", isActive && "active-class", isDisabled && "disabled-class")}
```

### 6. Remove Unused Props

Strip props that aren't actually used:

```tsx
// Before
function Card({ children, className, style, onClick, onHover, ...rest }) {
  return <div className={className}>{children}</div>;  // style, onClick, onHover unused!
}

// After
function Card({ children, className }) {
  return <div className={className}>{children}</div>;
}
```

## Output Format

```markdown
## Simplified: [ComponentName]

### Complexity Reduction
| Metric | Before | After | Change |
|--------|--------|-------|--------|
| Lines of code | 87 | 34 | -61% |
| Wrapper divs | 6 | 2 | -4 |
| Tailwind classes | 48 | 24 | -50% |
| Unused props | 3 | 0 | -3 |

### Key Changes
1. Removed 4 wrapper divs (no layout purpose)
2. Consolidated 12 Tailwind classes using defaults
3. Replaced custom button with `<Button>`
4. Removed `style`, `onClick`, `onHover` props (unused)

### Updated Code
[Simplified component]
```

## Preservation Rules

While simplifying, **preserve**:
- Brief's semantic color tokens
- Typography classes
- Accessibility attributes (`aria-*`, `role`)
- Proper focus management
- Component composition patterns

## Reference Docs

For context on what to keep:
- `reference/typography.md` — Essential typography patterns
- `reference/color.md` — Required semantic tokens
- `reference/motion.md` — Animation patterns worth keeping
