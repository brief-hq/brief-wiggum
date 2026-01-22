---
description: Refine a component to follow Brief design patterns
---

# /design-polish

Refine a component to better follow Brief's design system while preserving functionality.

## Usage

```bash
/design-polish [component-path-or-selection]
```

## Context Gathering

Before polishing, ask these clarifying questions:

1. **Preservation**: Are there intentional deviations that should be kept?
2. **Scope**: Should I polish only design tokens, or also refactor structure?
3. **Testing**: Is there an existing test or Storybook story I should verify against?

If the user provides a clear target and no special concerns, proceed directly.

## Polish Operations

### 1. Token Migration

Replace arbitrary values with design tokens:

```tsx
// Before
<div className="bg-[#f5f5f5] text-[#374151] border-[#e5e5e5]">

// After
<div className="bg-muted text-muted-foreground border-border">
```

### 2. Typography Upgrade

Apply semantic typography classes:

```tsx
// Before
<h2 className="text-xl font-semibold tracking-tight">Title</h2>
<p className="text-sm text-gray-500">Description</p>

// After
<h2 className="title-2-heavy">Title</h2>
<p className="callout text-muted-foreground">Description</p>
```

### 3. Component Substitution

Replace custom implementations with TailStack components:

```tsx
// Before
<button className="px-4 py-2 bg-green-600 text-white rounded hover:bg-green-700">
  Save
</button>

// After
import { Button } from "@/components/ui/button";
<Button>Save</Button>
```

### 4. Spacing Normalization

Convert margin to gap-based layouts:

```tsx
// Before
<div className="flex flex-col">
  <Item className="mb-4" />
  <Item className="mb-4" />
  <Item />
</div>

// After
<div className="flex flex-col gap-4">
  <Item />
  <Item />
  <Item />
</div>
```

### 5. Focus State Standardization

Add consistent focus rings:

```tsx
// Before
<input className="border rounded px-3 py-2" />

// After
<input className="border rounded px-3 py-2 focus-visible:ring-ring/50 focus-visible:ring-[3px] focus-visible:outline-none" />

// Or better: use Input component
import { Input } from "@/components/ui/input";
<Input />
```

## Output

Provide the polished component code with a brief summary of changes:

```markdown
## Polished: [ComponentName]

### Changes Made
| Category | Count | Details |
|----------|-------|---------|
| Color tokens | 3 | Hardcoded hex → semantic tokens |
| Typography | 2 | Ad-hoc classes → `.title-2`, `.body` |
| Components | 1 | Custom button → `<Button>` |
| Spacing | 4 | Margin → gap |

### Updated Code
[Full component code]
```

## Reference Docs

For deep context, see:
- `reference/typography.md` — Semantic typography classes
- `reference/color.md` — Token mappings
- `reference/motion.md` — Transition patterns

## Quality Check

After polishing, verify:
1. Component renders correctly
2. Colors match design system in Storybook
3. Focus states work (tab through)
4. No console errors
