---
description: Design system tools for Brief components
---

# /design [mode]

Design system compliance and refinement tools.

## Usage

```bash
/design audit [component]     # Check compliance (default)
/design polish [component]    # Migrate to design tokens
/design simplify [component]  # Reduce complexity
/design animate [component]   # Add purposeful motion
/design a11y [component]      # Accessibility audit and fixes
```

---

## /design audit (default)

Check a component against Brief's design system and report violations.

### Checklist

**Typography**: Use `font-sans`/`font-serif`/`font-mono`, semantic classes (`.title-1`, `.body`, `.callout`)

**Colors -- Dual Token System**: Both shadcn and Brief tokens are valid:

| System | Examples |
|--------|----------|
| shadcn | `bg-background`, `bg-primary`, `text-foreground`, `text-muted-foreground`, `border-border` |
| Brief | `bg-bkg-*`, `text-txt-*`, `border-brd-*`, `stroke-stk-*`, `fill-icn-*`, `ring-rng` |

**Token Validation (Critical)** -- Common hallucinations:

| Wrong | Correct |
|-------|---------|
| `bg-neutralShade` | `bg-bkg-neutralShade` |
| `text-error` | `text-txt-error` |
| `border-subtle` | `border-brd-subtle` |
| `text-disabled` | `text-txt-disabled` |

**Components**: Use `@/components/ui/*` primitives, no recreated modals/buttons

**Layout**: Use `gap` not margin, no nested cards, standard `rounded-md`/`rounded-lg`

**Focus**: Interactive elements need `focus-visible:ring-ring/50` or `focus-visible:ring-rng`

**Accessibility** (see `/design a11y` for full checklist):
- Interactive elements have accessible labels (`aria-label`, `aria-labelledby`, or visible text)
- Images have `alt` text; decorative images use `alt=""`
- Color is not the sole means of conveying information
- Touch/click targets are at least 44x44px
- No `tabIndex > 0` (breaks natural tab order)

### Severity Levels

| Level | Definition |
|-------|------------|
| **Critical** | Breaks consistency or a11y (custom modals, missing focus, broken contrast, missing `alt`, unlabeled interactive elements) |
| **High** | Clear violation (hardcoded hex, invented tokens, `tabIndex > 0`, no keyboard access) |
| **Medium** | Best practice deviation (margin instead of gap, missing `aria-live` on dynamic regions) |
| **Low** | Improvement opportunity (verbose classes, redundant `aria-label` duplicating visible text) |

---

## /design polish

Migrate a component to Brief's design system.

### Transformations

**Token Migration**
```tsx
// Before -> After
bg-[#f5f5f5] -> bg-muted
text-[#374151] -> text-muted-foreground
```

**Typography Upgrade**
```tsx
// Before -> After
text-xl font-semibold tracking-tight -> title-2-heavy
text-sm text-gray-500 -> callout text-muted-foreground
```

**Component Substitution**
```tsx
// Before: custom button -> After: <Button>
<button className="px-4 py-2 bg-green-600...">Save</button>
<Button>Save</Button>
```

**Spacing Normalization**
```tsx
// Before: margins -> After: gap
<div className="flex flex-col">
  <Item className="mb-4" />  ->  <div className="flex flex-col gap-4">
```

**Accessibility Fixes**
```tsx
// Before: <button><Icon /></button>
// After:  <button aria-label="Close dialog"><Icon aria-hidden="true" /></button>

// Before: <img src="..." />
// After:  <img src="..." alt="Description of image" />

// Before: <div className="text-txt-error">Email is required</div>
// After:  <div className="text-txt-error" id="email-error">Email is required</div>
//         <input aria-describedby="email-error" aria-invalid="true" ... />
```

---

## /design simplify

Reduce complexity while preserving Brief's design language.

### Strategies

**Flatten Nesting** -- Remove wrapper divs with no layout purpose

**Reduce Classes**
```tsx
// Before -> After
flex flex-row items-center justify-start -> flex items-center
```

**Remove Defensive Overrides**
```tsx
// Before -> After
!bg-white !text-black -> bg-background text-foreground
```

**Simplify Conditionals**
```tsx
// Before -> After
`base ${isActive ? 'active' : ''} ${isDisabled ? 'disabled' : ''}`
cn("base", isActive && "active", isDisabled && "disabled")
```

**Remove Unused Props** -- Strip props that aren't actually used

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
- `ease-out` -- Elements entering
- `ease-in` -- Elements leaving
- `ease-in-out` -- Position changes

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
- `duration-1000` -- Too slow
- `ease-linear` -- Jarring
- Multiple animations on one element -- Distracting
- Animation without purpose -- Logo spinning for no reason

---

## /design a11y

Audit and fix accessibility issues. Conforms to WCAG 2.2 Level AA as a baseline; go beyond minimum when it meaningfully improves usability.

### Non-negotiables (MUST)

- Conform to [WCAG 2.2 Level AA](https://www.w3.org/TR/WCAG22/).
- Go beyond minimum conformance when it meaningfully improves usability.
- If the project uses a UI component library, you MUST use the component patterns as defined from the library. Do not recreate patterns.
  - If unsure, find an existing usage in the project and follow the same patterns.
  - Ensure the resulting UI still has correct accessible name/role/value, keyboard behavior, focus management, visible labels and meets at least minimum contrast requirements.
- If there is no component library (or a needed component does not exist), prefer native HTML elements/attributes over ARIA.
- Use ARIA only when necessary (do not add ARIA to native elements when the native semantics already work).
- Ensure correct accessible **name, role, value, states, and properties**.
- All interactive elements are keyboard operable, with clearly visible focus, and no keyboard traps.
- Do not claim the output is "fully accessible".

### Inclusive language (MUST)

- Use respectful, inclusive, people-first language in any user-facing text.
- Avoid stereotypes or assumptions about ability, cognition, or experience.

### Cognitive load (SHOULD)

- Prefer plain language.
- Use consistent page structure (landmarks).
- Keep navigation order consistent.
- Keep the interface clean and simple (avoid unnecessary distractions).

### Structure and semantics

#### Page structure (MUST)

- Use landmarks (`header`, `nav`, `main`, `footer`) appropriately.
- Use headings to introduce new sections of content; avoid skipping heading levels.
- Prefer one `h1` for the page topic. Generally, the first heading within the `main` element / landmark.

#### Page title (SHOULD)

- Set a descriptive `<title>`.
- Prefer: "Unique page - section - site".

### Keyboard and focus

#### Core rules (MUST)

- All interactive elements are keyboard operable.
- Tab order follows reading order and is predictable.
- Focus is always visible.
- Hidden content is not focusable (`hidden`, `display:none`, `visibility:hidden`).
- If content is hidden to assistive technology by using `aria-hidden="true"` then that content, nor any of its descendants, can be focusable.
- Static content MUST NOT be tabbable.
  - Exception: if an element needs programmatic focus, use `tabindex="-1"`.

#### Skip link / bypass blocks (MUST)

Provide a skip link as the first focusable element.

```html
<header>
  <a href="#maincontent" class="sr-only focus:not-sr-only focus:absolute focus:top-4 focus:left-4 focus:z-50 focus:px-4 focus:py-2 focus:bg-bkg-basic focus:text-txt-basic">
    Skip to main content
  </a>
  <!-- header content -->
</header>
<nav>
  <!-- navigation -->
</nav>
<main id="maincontent" tabindex="-1">
  <h1><!-- page title --></h1>
  <!-- content -->
</main>
```

#### Composite widgets (SHOULD)

If a component uses arrow-key navigation within itself (tabs, listbox, menu-like UI, grid/date picker):

- Provide one tab stop for the composite container or one child.
- Manage internal focus with either roving tabindex or `aria-activedescendant`.

Roving tabindex (SHOULD):

- Exactly one focusable item has `tabindex="0"`; all others are `-1`.
- Arrow keys move focus by swapping tabindex and calling `.focus()`.

`aria-activedescendant` (SHOULD):

- Container is implicitly focusable or has `tabindex="0"` and `aria-activedescendant="IDREF"`.
- Arrow keys update `aria-activedescendant`.

### Low vision and contrast (MUST)

#### Contrast requirements (MUST)

- Text contrast: at least 4.5:1 (large text: 3:1).
  - Large text is at least 24px regular or 18.66px bold.
- Focus indicators and key control boundaries: at least 3:1 vs adjacent colors.
- Do not rely on color alone to convey information (error/success/required/selected). Provide text and/or icons with accessible names.

#### Color generation rules (MUST)

- Do not invent arbitrary colors.
  - Use project-approved design tokens (CSS variables).
  - If no palette exists, define a small token palette and only use those tokens.
- Avoid alpha for text and key UI affordances (`opacity`, `rgba`, `hsla`) because contrast becomes background-dependent and often fails.
- Ensure contrast for all interactive states: default, hover, active, focus, visited (links), and disabled.

#### Safe defaults when unsure (SHOULD)

- Prefer very dark text on very light backgrounds, or the reverse.
- Avoid mid-gray text on white; muted text should still meet 4.5:1.

#### Tokenized palette contract (SHOULD)

- Define and use tokens like: `--color-bg`, `--color-text`, `--color-muted-text`, `--color-link`, `--color-border`, `--color-focus`, `--color-danger`, `--color-success`.
- Only assign UI colors via these tokens (avoid scattered inline hex values).

#### Verification (MUST)

Contrast verification is covered by the Final verification checklist.

### High contrast / forced colors mode (MUST)

#### Support OS-level accessibility features (MUST)

- Never override or disrupt OS accessibility settings.
- The UI MUST adapt to High Contrast / Forced Colors mode automatically.
- Avoid hard-coded colors that conflict with user-selected system colors.

#### Use the `forced-colors` media query when needed (SHOULD)

Use `@media (forced-colors: active)` only when system defaults are not sufficient.

```css
@media (forced-colors: active) {
  /* Example: Replace box-shadow (suppressed in forced-colors) with a border */
  .button {
    border: 2px solid ButtonBorder;
  }
}

/* if using box-shadow for a focus style, also use a transparent outline
    so that the outline will render when the high contrast setting is enabled. This is an exception to Avoid alpha for text and key UI affordances */
.btn:focus {
  box-shadow: 0 0 4px 3px rgba(90, 50, 200, .7);
  outline: 2px solid transparent;
}
```

In Forced Colors mode, avoid relying on:

- Box shadows
- Decorative gradients

#### Respect user color schemes in forced colors (MUST)

- Use system color keywords (e.g., `ButtonText`, `ButtonBorder`, `CanvasText`, `Canvas`).
- Do not use fixed hex/RGB colors inside `@media (forced-colors: active)`.

#### Do not disable forced colors (MUST)

- Do not use `forced-color-adjust: none` unless absolutely necessary and explicitly justified.
- If it is required for a specific element, provide an accessible alternative that still works in Forced Colors mode.

#### Icons (MUST)

- Icons MUST adapt to text color.
- Prefer `currentColor` for SVG icon fills/strokes; avoid embedding fixed colors inside SVGs.

```css
svg {
  fill: currentColor;
  stroke: currentColor;
}
```

### Reflow (WCAG 2.2 SC 1.4.10) (MUST)

#### Goal (MUST)

Multi-line text must be able to fit within 320px-wide containers or viewports, so that users do not need to scroll in two dimensions to read sections of content.

#### Core principles (MUST)

- Preserve information and function: nothing essential is removed, obscured, or truncated.
- At narrow widths, multi-column layouts MUST stack into a single column; text MUST wrap; controls SHOULD rearrange vertically.
- Users MUST NOT need to scroll left/right to read multi-line text.
- If content is collapsed in the narrow layout, the full content/function MUST be available within 1 click (e.g., overflow menu, dialog, tooltip).

#### Engineering requirements (MUST)

- Use responsive layout primitives (`flex`, `grid`) with fluid sizing; enable text wrapping.
- Avoid fixed widths that force two-dimensional scrolling at 320px.
- Avoid absolute positioning and `overflow: hidden` when it causes content loss, or would result in the obscuring of content at smaller viewport sizes.
- Media and containers SHOULD NOT overflow the viewport at 320px (for example, prefer `max-width: 100%` for images/video/canvas/iframes).
- In flex/grid layouts, ensure children can shrink/wrap (common fix: `min-width: 0` on flex/grid children).
- Handle long strings (URLs, tokens) without forcing overflow (common fix: `overflow-wrap: anywhere` or equivalent).
- Ensure all interactive elements remain visible, reachable, and operable at 320px.

#### Exceptions (SHOULD)

If a component truly requires a two-dimensional layout for meaning/usage (e.g., large data tables, maps, diagrams, charts, games, presentations), allow horizontal scrolling only at the component level.

- The page as a whole MUST still reflow (unless the page layout truly requires two-dimensional layout for usage).
- The component MUST remain fully usable (all content reachable; controls operable).

### Controls and labels

#### Visible labels (MUST)

- Every interactive element has a visible label.
- The label cannot disappear while entering text or after the field has a value.

#### Voice access (MUST)

- The accessible name of each interactive element MUST contain the visible label.
  - If using `aria-label`, include the visual label text.
- If multiple controls share the same visible label (e.g., many "Remove" buttons), use an `aria-label` that keeps the visible label text and adds context (e.g., "Remove item: Socks").

### Forms

#### Labels and help text (MUST)

- Every form control has a programmatic label.
  - Prefer `<label for="...">`.
- Labels describe the input purpose.
- If help text exists, associate it with `aria-describedby`.

#### Required fields (MUST)

- Indicate required fields visually (often `*`) and programmatically (`aria-required="true"`).

#### Errors and validation (MUST)

- Provide error messages that explain how to fix the issue.
- Use `aria-invalid="true"` for invalid fields; remove it when valid.
- Associate inline errors with the field via `aria-describedby`.
- Submit buttons SHOULD NOT be disabled solely to prevent submission.
- On submit with invalid input, focus the first invalid control.

### Graphics and images

All graphics include `img`, `svg`, icon fonts, and emojis.

- Informative graphics MUST have meaningful alternatives.
  - `img`: use `alt`.
  - `svg`: prefer `role="img"` and `aria-label`/`aria-labelledby`.
- Decorative graphics MUST be hidden.
  - `img`: `alt=""`.
  - Other: `aria-hidden="true"`.

### Navigation and menus

- Use semantic navigation: `<nav>` with lists and links.
- Do not use `role="menu"` / `role="menubar"` for site navigation.
- For expandable navigation:
  - Include button elements to toggle navigation and/or sub-navigations. Use `aria-expanded` on the button to indicate state.
  - `Escape` MAY close open sub-navigations.

### Tables and grids

#### Tables for static data (MUST)

- Use `<table>` for static tabular data.
- Use `<th>` to associate headers.
  - Column headers are in the first row.
  - Row headers (when present) use `<th>` in each row.

#### Grids for dynamic UIs (SHOULD)

- Use grid roles only for truly interactive/dynamic experiences.
- If using `role="grid"`, grid cells MUST be nested in rows so header/cell relationships are determinable.
- Use arrow navigation to navigate within the grid.

### Final verification checklist (MUST)

Before finalizing output, explicitly verify:

- Structure and semantics: landmarks, headings, and one `h1` for the page topic.
- Keyboard and focus: operable controls, visible focus, predictable tab order, no traps, skip link works.
- Controls and labels: visible labels present and included in accessible names.
- Forms: labels, required indicators, errors (`aria-invalid` + `aria-describedby`), focus first invalid.
- Contrast: meets 4.5:1 / 3:1 thresholds, focus/boundaries meet 3:1, color not the only cue.
- Forced colors: does not break OS High Contrast / Forced Colors; uses system colors in `forced-colors: active`.
- Reflow: sections of content should be able to adjust to 320px width without the need for two-dimensional scrolling to read multi-line text; no content loss; controls remain operable.
- Graphics: informative alternatives; decorative graphics hidden.
- Tables/grids: tables use `<th>`; grids (when needed) are structured with rows and cells.

### Final note

Accessibility issues may still exist after automated checks; manual review and testing (e.g., with Accessibility Insights or axe) is still recommended.

---

## Quick Reference

| Mode | When to Use | Key Focus |
|------|-------------|-----------|
| `audit` | Before PR, compliance check, inherited code review | Find violations by severity |
| `polish` | Migrate hardcoded values, upgrade to design tokens | Token/component upgrades |
| `simplify` | Complex components, tech debt cleanup | Remove unnecessary wrappers |
| `animate` | Adding interactions, feedback states | Purposeful motion only |
| `a11y` | Any component, before PR | WCAG 2.2 AA compliance |

## Reference Docs

- `reference/typography.md` -- Font families, type scale, semantic classes
- `reference/color.md` -- OKLCH primitives, semantic tokens, contrast
- `reference/motion.md` -- Timing, easing, CSS vs Motion library

## Verification

```bash
cd packages/ui-storybook && pnpm run storybook
```
