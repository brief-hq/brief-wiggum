# Brief Color Reference

Deep-dive on Brief's color system. Use this when making color decisions beyond the basics in SKILL.md.

## Color Architecture

Brief's colors are built in three layers:

```text
Layer 3: Tailwind Utilities     bg-primary, text-muted-foreground, border-border
              ↑
Layer 2: Semantic Tokens        --primary, --muted-foreground, --border
              ↑
Layer 1: OKLCH Primitives       --color-brand-fern-050, --color-neutral-090
```

**Rule**: Always work at the highest layer possible. Drop to lower layers only when semantic tokens don't cover your case.

## Layer 1: OKLCH Primitives

All colors are defined in OKLCH (Oklab Lightness Chroma Hue) in `globals.css`:

```css
/* OKLCH: lightness (0-100%), chroma (0-0.4+), hue (0-360) */
--color-brand-fern-050: oklch(60.4% 0.1208 169.1);
--color-neutral-090: oklch(91.5% 0.0035 39.5);
--color-sky-blue-070: oklch(73.4% 0.1308 228.6);
```

### Why OKLCH?

- **Perceptually uniform**: Equal steps in lightness *look* equal (unlike HSL)
- **Predictable**: Adjusting lightness doesn't shift hue
- **Modern CSS**: Supported in all evergreen browsers

### Color Ramps

| Ramp | Hue | Use For |
|------|-----|---------|
| `brand-fern` | ~169° (green) | Primary actions, brand surfaces |
| `neutral` | ~40° (warm gray) | Backgrounds, borders, text |
| `sky-blue` | ~228° (blue) | Focus states, interactive chrome |

### Stop Naming

Stops use a lightness-based scale:
- `050` = ~50-60% lightness (mid-tone)
- `070` = ~70% lightness (lighter)
- `090` = ~90% lightness (very light)
- `095_50` = 95% lightness at 50% opacity

```css
/* Fractional stops use underscore */
--color-neutral-100_90: oklch(100% 0 89.9 / 0.9);
--color-neutral-095_50: oklch(95% 0.0035 39.5 / 0.5);
```

## Layer 2: Semantic Tokens

Semantic tokens map primitives to UI purposes. Defined in `:root` in `globals.css`:

### Core Tokens

| Token | Maps To | Use For |
|-------|---------|---------|
| `--primary` | `brand-fern-050` | Primary buttons, CTAs, active states |
| `--primary-foreground` | white | Text on primary backgrounds |
| `--secondary` | neutral light | Secondary buttons |
| `--muted` | neutral light | Muted backgrounds |
| `--muted-foreground` | neutral mid | Secondary text, placeholders |
| `--accent` | neutral light | Hover highlights |
| `--destructive` | red | Delete, errors, warnings |
| `--border` | `neutral-090` | Dividers, card edges |
| `--ring` | `sky-blue-070` | Focus rings |

### Sidebar Tokens

| Token | Maps To |
|-------|---------|
| `--sidebar` | near-white |
| `--sidebar-primary` | `brand-fern-050` |
| `--sidebar-border` | neutral |
| `--sidebar-ring` | `sky-blue-070` |

### Extended Token Bundles

For fine-grained control, Brief defines additional bundles:

```css
/* Background stack */
--color-bkg-*     /* brand, neutral, blur, edit, highlight surfaces */

/* Typography stack */
--color-txt-*     /* default, reversed, brand, highlight, disabled text */

/* Icon stack */
--color-icn-*     /* matches typography roles */

/* Border stack */
--color-brd-*     /* brand, neutral, highlight, disabled, edit borders */

/* Focus utilities */
--color-rng       /* focus rings */
--color-act       /* checkbox/radio accent */
--color-crt       /* caret color */
```

## Layer 3: Tailwind Utilities

Tailwind generates utilities from both semantic tokens and primitives:

```tsx
// Semantic (preferred)
<Button className="bg-primary text-primary-foreground">Save</Button>
<div className="border-border rounded-lg">Card</div>
<span className="text-muted-foreground">Hint</span>

// Primitive (when needed)
<div className="bg-brand-fern-050/20">Tinted surface</div>
<span className="text-sky-blue-070">Accent text</span>
```

### Opacity Modifiers

Apply opacity to any color:

```tsx
<div className="bg-primary/10">Very light primary</div>
<div className="border-border/50">50% opacity border</div>
<div className="ring-ring/50">Standard focus ring</div>
```

## Dark Mode

Brief is **light mode only** (Decision D-18), but dark mode tokens exist for defensive programming:

```css
.dark {
  --background: oklch(0.145 0 0);
  --foreground: oklch(0.985 0 0);
  /* ... */
}
```

**Do not** design for dark mode. These exist only for graceful degradation.

## Anti-Patterns

### ❌ Never Do This

```tsx
// Hardcoded hex values
<div style={{ backgroundColor: '#2d6a4f' }}>Wrong</div>
<div className="bg-[#6366f1]">Wrong</div>

// Generic Tailwind colors
<button className="bg-blue-500">Wrong</button>
<span className="text-gray-500">Wrong</span>

// Purple gradients (AI slop)
<div className="bg-gradient-to-r from-purple-500 to-pink-500">Wrong</div>

// Pure black/white
<div className="bg-black">Wrong — use bg-foreground</div>
<div className="text-white">Wrong — use text-background</div>
```

### ✅ Do This

```tsx
// Semantic tokens
<button className="bg-primary text-primary-foreground">Correct</button>
<span className="text-muted-foreground">Correct</span>

// Primitives with opacity
<div className="bg-brand-fern-050/10">Correct (tinted surface)</div>

// Proper neutrals
<div className="bg-background text-foreground">Correct</div>
```

## Contrast Requirements

All text must meet WCAG AA contrast:

| Content | Minimum Ratio |
|---------|---------------|
| Body text | 4.5:1 |
| Large text (18px+) | 3:1 |
| UI components | 3:1 |

Brief's semantic tokens are pre-validated for contrast. Avoid overriding `--muted-foreground` with lighter values.

## Storybook Reference

Color examples in Storybook:

```bash
cd packages/ui-storybook && pnpm run storybook
# → Foundations / Color Primitives
# → Foundations / Color Tokens
# → Foundations / Color Utilities
```

The **Playground tab** in Color Tokens lets you preview any CSS variable.
