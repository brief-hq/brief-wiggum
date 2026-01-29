---
description: Design system tools for Brief components
---

# /design [mode]

Design system compliance and refinement tools.

## Usage

```bash
/design audit [component]   # Check compliance (default)
/design polish [component]  # Migrate to design tokens
/design simplify [component] # Reduce complexity
/design animate [component]  # Add purposeful motion
```

---

## /design audit (default)

Check a component against Brief's design system and report violations.

### Checklist

**Typography**: Use `font-sans`/`font-serif`/`font-mono`, semantic classes (`.title-1`, `.body`, `.callout`)

**Colors — Dual Token System**: Both shadcn and Brief tokens are valid:

| System | Examples |
|--------|----------|
| shadcn | `bg-background`, `bg-primary`, `text-foreground`, `text-muted-foreground`, `border-border` |
| Brief | `bg-bkg-*`, `text-txt-*`, `border-brd-*`, `stroke-stk-*`, `fill-icn-*`, `ring-rng` |

**Token Validation (Critical)** — Common hallucinations:

| ❌ Wrong | ✅ Correct |
|----------|-----------|
| `bg-neutralShade` | `bg-bkg-neutralShade` |
| `text-error` | `text-txt-error` |
| `border-subtle` | `border-brd-subtle` |
| `text-disabled` | `text-txt-disabled` |

**Components**: Use `@/components/ui/*` primitives, no recreated modals/buttons

**Layout**: Use `gap` not margin, no nested cards, standard `rounded-md`/`rounded-lg`

**Focus**: Interactive elements need `focus-visible:ring-ring/50` or `focus-visible:ring-rng`

### Severity Levels

| Level | Definition |
|-------|------------|
| **Critical** | Breaks consistency or a11y (custom modals, missing focus, broken contrast) |
| **High** | Clear violation (hardcoded hex, invented tokens) |
| **Medium** | Best practice deviation (margin instead of gap) |
| **Low** | Improvement opportunity (verbose classes) |

---

## /design polish

Migrate a component to Brief's design system.

### Transformations

**Token Migration**
```tsx
// Before → After
bg-[#f5f5f5] → bg-muted
text-[#374151] → text-muted-foreground
```

**Typography Upgrade**
```tsx
// Before → After
text-xl font-semibold tracking-tight → title-2-heavy
text-sm text-gray-500 → callout text-muted-foreground
```

**Component Substitution**
```tsx
// Before: custom button → After: <Button>
<button className="px-4 py-2 bg-green-600...">Save</button>
<Button>Save</Button>
```

**Spacing Normalization**
```tsx
// Before: margins → After: gap
<div className="flex flex-col">
  <Item className="mb-4" />  →  <div className="flex flex-col gap-4">
```

---

## /design simplify

Reduce complexity while preserving Brief's design language.

### Strategies

**Flatten Nesting** — Remove wrapper divs with no layout purpose

**Reduce Classes**
```tsx
// Before → After
flex flex-row items-center justify-start → flex items-center
```

**Remove Defensive Overrides**
```tsx
// Before → After
!bg-white !text-black → bg-background text-foreground
```

**Simplify Conditionals**
```tsx
// Before → After
`base ${isActive ? 'active' : ''} ${isDisabled ? 'disabled' : ''}`
cn("base", isActive && "active", isDisabled && "disabled")
```

**Remove Unused Props** — Strip props that aren't actually used

### Preserve
- Semantic color tokens
- Typography classes
- Accessibility attributes (`aria-*`, `role`)
- Focus management

---

## /design animate

Add purposeful, on-brand animations. CSS-first; Motion library for complex interactions.

### Duration Guidelines

| Purpose | Duration | Examples |
|---------|----------|----------|
| Micro-interactions | 100-150ms | Hover, focus, button press |
| State changes | 200-300ms | Toggle, expand/collapse |
| Page transitions | 300-500ms | Modal open, drawer slide |

### Easing
- `ease-out` — Elements entering
- `ease-in` — Elements leaving
- `ease-in-out` — Position changes

### CSS Patterns (Preferred)

```tsx
// Hover lift
<Button className="transition-transform hover:-translate-y-0.5">

// Fade in on mount
<div className="animate-in fade-in duration-300">

// Staggered children
style={{ animationDelay: `${i * 50}ms` }}

// Skeleton loader
<div className="animate-shimmer" />
```

### Motion Library (Complex Only)

```tsx
import { motion, AnimatePresence } from "framer-motion";

// Exit animations
<AnimatePresence>
  {isVisible && (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      exit={{ opacity: 0, y: -20 }}
    />
  )}
</AnimatePresence>
```

### Anti-Patterns
- `duration-1000` — Too slow
- `ease-linear` — Jarring
- Multiple animations on one element — Distracting
- Animation without purpose — Logo spinning for no reason

---

## Quick Reference

| Mode | When to Use |
|------|-------------|
| `audit` | Before PR, compliance check, inherited code review |
| `polish` | Migrate hardcoded values, upgrade to design tokens |
| `simplify` | Reduce LOC, flatten nesting, remove dead code |
| `animate` | Add interaction feedback, entrance/exit motion |

## Reference Docs

- `reference/typography.md` — Font families, type scale, semantic classes
- `reference/color.md` — OKLCH primitives, semantic tokens, contrast
- `reference/motion.md` — Timing, easing, CSS vs Motion library

## Verification

```bash
cd packages/ui-storybook && pnpm run storybook
```
