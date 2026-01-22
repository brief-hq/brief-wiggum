---
description: Audit a component for Brief design system compliance
---

# /design-audit

Check a component against Brief's design system and report violations by severity.

## Usage

```bash
/design-audit [component-path-or-selection]
```

## Context Gathering

Before auditing, ask these clarifying questions:

1. **Scope**: Is this a single component, a page, or a set of related files?
2. **Purpose**: Is this a new component or existing code being reviewed?
3. **Priority**: Are there specific areas of concern (typography, colors, accessibility)?

If the user provides a clear target and no special concerns, proceed directly.

## Audit Checklist

### 1. Typography
- Uses `font-sans` / `font-serif` / `font-mono` (not Inter, Roboto, Arial)
- Uses semantic classes (`.title-1`, `.body`, `.callout`) over ad-hoc combinations
- No hardcoded `fontFamily` styles

### 2. Colors — Dual Token System

Brief uses TWO token systems. Both are valid:

#### shadcn Tokens (base layer)
Standard semantic tokens from shadcn/ui:
- `bg-background`, `bg-card`, `bg-popover`, `bg-primary`, `bg-secondary`, `bg-muted`, `bg-accent`, `bg-destructive`
- `text-foreground`, `text-card-foreground`, `text-muted-foreground`, `text-primary-foreground`, etc.
- `border-border`, `border-input`
- `ring-ring`

#### Brief Tokens (namespaced layer)
Brief-specific tokens use prefixes to distinguish from generic Tailwind:

| Prefix | Usage | Examples |
|--------|-------|----------|
| `bg-bkg-*` | Backgrounds | `bg-bkg-basic`, `bg-bkg-reversed`, `bg-bkg-neutralShade`, `bg-bkg-edit`, `bg-bkg-edit-destructive`, `bg-bkg-highlight` |
| `text-txt-*` | Text/Font | `text-txt-basic`, `text-txt-reversed`, `text-txt-error`, `text-txt-disabled`, `text-txt-ghost`, `text-txt-highlight` |
| `border-brd-*` | Borders | `border-brd-brand`, `border-brd-subtle`, `border-brd-error`, `border-brd-highlight`, `border-brd-disabled` |
| `ring-rng` | Focus halo | `ring-rng` |
| `stroke-stk-*` | SVG strokes (icons) | `stroke-stk-brandFern`, `stroke-stk-skyBlue`, `stroke-stk-red`, `stroke-stk-black` |
| `fill-icn-*` | Icon fills | `fill-icn-basic`, `fill-icn-brand` |

#### When to Use Primitives
Tailwind primitives (`bg-gray-200`, `stroke-red-500`) are acceptable for:
- **Non-prerendered SVG content** (e.g., dynamic chart strokes, progress rings)
- **Loading skeletons** where semantic meaning doesn't apply
- When no semantic token exists for the use case

### 2b. Token Validation (Critical)

**DO NOT INVENT TOKENS.** Common hallucinations to flag:

| ❌ Wrong | ✅ Correct |
|----------|-----------|
| `bg-neutralShade` | `bg-bkg-neutralShade` |
| `text-error` | `text-txt-error` |
| `border-subtle` | `border-brd-subtle` |
| `bg-edit-destructive` | `bg-bkg-edit-destructive` |
| `text-disabled` | `text-txt-disabled` |
| `stroke-txt-error` | `stroke-red-500` (use primitive for strokes) |
| `bg-background-secondary` | `bg-secondary` or `bg-bkg-neutralShade` |
| `text-primary` | `text-foreground` or `text-primary-foreground` |

### 3. Component Reuse
- Uses `@/components/ui/*` primitives (Button, Input, Dialog, Card)
- No recreated modals, buttons, or form controls
- Composition over duplication

### 4. Layout
- Uses `gap` instead of margin for spacing
- No nested cards (Card inside Card)
- Standard border-radius (`rounded-md`, `rounded-lg`)

### 5. Focus States
- Interactive elements have `focus-visible:ring-ring/50` or `focus-visible:ring-rng`
- No custom focus colors

### 6. Icons
- Uses Brief icons or Lucide (not FontAwesome, Heroicons)
- Proper sizing (`h-4 w-4` for buttons)
- Icon colors use `stroke-stk-*` tokens or primitives

## Severity Definitions

| Severity | Definition | Examples |
|----------|------------|----------|
| **Critical** | Breaks visual consistency or accessibility | Custom modals, missing focus states, broken contrast |
| **High** | Clear design system violation | Hardcoded hex colors, wrong fonts, **invented tokens** (missing prefix) |
| **Medium** | Deviation from best practices | Margin instead of gap, ad-hoc typography combos |
| **Low** | Nit or improvement opportunity | Verbose class lists, minor nesting |

## Output Format

```markdown
## Design Audit: [ComponentName]

### Summary
- **Critical**: 0
- **High**: 2
- **Medium**: 3
- **Low**: 1

### 🔴 Critical Issues
(None found)

### 🟠 High Issues
1. **Line 42**: Hardcoded color `bg-[#6366f1]`
   - **Impact**: Inconsistent with brand colors
   - **Fix**: Replace with `bg-primary` or `bg-bkg-brand`

2. **Line 58**: Invented token `text-error`
   - **Impact**: Token doesn't exist (missing `txt-` prefix)
   - **Fix**: Use `text-txt-error`

3. **Line 73**: Invented token `bg-neutralShade`
   - **Impact**: Token doesn't exist (missing `bkg-` prefix)
   - **Fix**: Use `bg-bkg-neutralShade`

### 🟡 Medium Issues
1. **Line 24**: Margin-based spacing `mb-4` in flex container
   - **Impact**: Harder to maintain consistent spacing
   - **Fix**: Convert to `gap-4` on parent

### 🔵 Low Issues
1. **Line 12**: Verbose class `flex flex-row items-center justify-start`
   - **Impact**: None (functional)
   - **Fix**: Simplify to `flex items-center`

### ✅ Passes
- Proper focus ring implementation
- Correct icon library (Lucide)
- Brief tokens used correctly with prefixes
```

## Token Quick Reference

```
# Brief Tokens (use these!)
bg-bkg-{basic,reversed,disabled,brand,brand-subtle,brand-hover,brand-press,neutralShade,neutralShade-subtle,neutralShade-hover,neutralShade-press,blur,blur-reversed,edit,edit-destructive,edit-destructive-press,highlight,highlight-subtle}

text-txt-{basic,reversed,subtleBrand,neutralShade,ghost,error,highContrastBrand,disabled,highlight,edit-add,edit-remove,edit-destructive}

border-brd-{brand,neutralShade,subtle,error,highlight,disabled,edit-destructive,edit-destructive-subtle}

ring-rng

stroke-stk-{brandFern,slateBlue,red,orange,yellowGreen,green,teal,skyBlue,blue,violet,purple,maroon,black}

# shadcn Tokens (also valid)
bg-{background,card,popover,primary,secondary,muted,accent,destructive}
text-{foreground,card-foreground,popover-foreground,primary-foreground,secondary-foreground,muted-foreground,accent-foreground,destructive-foreground}
border-{border,input}
ring-ring
```

## Reference Docs

For deep context, see:
- `reference/typography.md` — Font families, type scale, semantic classes
- `reference/color.md` — OKLCH primitives, semantic tokens, contrast
- `reference/motion.md` — Timing, easing, CSS vs Motion library
- `packages/ui-storybook/src/stories/foundations/ColorTokens.stories.tsx` — Live token reference

## Verification

After fixes, confirm in Storybook:
```bash
cd packages/ui-storybook && pnpm run storybook
```
