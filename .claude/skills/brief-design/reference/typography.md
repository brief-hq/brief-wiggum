# Brief Typography Reference

Deep-dive on Brief's typography system. Use this when making typography decisions beyond the basics in SKILL.md.

## Font Stack

Brief uses three carefully chosen fonts configured in `web/lib/fonts.ts`:

| Role | Font | Variable | Weights | Use For |
|------|------|----------|---------|---------|
| Sans | Spline Sans | `--font-spline-sans` | 300–700 | UI, body, headings |
| Mono | Spline Sans Mono | `--font-spline-sans-mono` | 300–700 | Code, data, technical |
| Serif | Piazzolla | `--font-piazzolla` | 100–900 | Accents, quotes, editorial |

### Why These Fonts?

- **Spline Sans**: Geometric sans with personality — distinctive enough to avoid "generic tech" but neutral enough for dense UI. The slightly condensed letterforms work well in constrained spaces.
- **Spline Sans Mono**: Matched mono for code blocks and data tables. Shares x-height with the sans, so mixed content aligns.
- **Piazzolla**: Variable serif with optical sizing. Use sparingly for quotes, pull-outs, or editorial moments. Adds warmth without compromising the clean UI feel.

### CSS Variables

```css
:root {
  --font-sans: var(--font-spline-sans);
  --font-serif: var(--font-piazzolla);
  --font-mono: var(--font-spline-sans-mono);
}
```

```tsx
// Tailwind usage
<h1 className="font-sans">Default (Spline Sans)</h1>
<blockquote className="font-serif">Quote (Piazzolla)</blockquote>
<code className="font-mono">code (Spline Sans Mono)</code>
```

## Type Scale

Brief's type scale is defined in `globals.css` with custom sizes:

| Token | Size | Pixels | Use For |
|-------|------|--------|---------|
| `text-xxs` | 0.6875rem | 11px | Fine print, timestamps |
| `text-xs` | 0.75rem | 12px | Captions, metadata |
| `text-sm` | 0.8125rem | 13px | Secondary UI |
| `text-base` | 0.875rem | 14px | Body text (default) |
| `text-lg` | 1.0625rem | 17px | Lead paragraphs |
| `text-xl` | 1.25rem | 20px | Section headers |
| `text-2xl` | 1.5rem | 24px | Page titles |
| `text-3xl` | 1.875rem | 30px | Hero headlines |

### Why 14px Base?

Brief's UI is information-dense (decisions, documents, research signals). A 14px base keeps more content visible without sacrificing readability. For long-form content (docs, reports), consider bumping to `text-base` or `text-lg`.

## Semantic Typography Classes

Pre-composed classes in `globals.css` — use these instead of ad-hoc combinations:

```css
/* Display */
.large-title       { @apply text-3xl font-normal tracking-tighter leading-8; }
.large-title-heavy { @apply text-3xl font-semibold tracking-tighter leading-8; }

/* Headings */
.title-1       { @apply text-2xl font-normal tracking-tight leading-7; }
.title-1-heavy { @apply text-2xl font-semibold tracking-tight leading-7; }
.title-2       { @apply text-xl font-normal tracking-wider leading-6; }
.title-2-heavy { @apply text-xl font-semibold tracking-wider leading-6; }
.title-3       { @apply text-lg font-normal tracking-widest leading-5; }
.title-3-heavy { @apply text-lg font-semibold tracking-widest leading-5; }

/* Body */
.body       { @apply text-base font-normal tracking-widest leading-4; }
.body-heavy { @apply text-base font-semibold tracking-widest leading-4; }

/* Supporting */
.callout       { @apply text-sm font-normal tracking-widest leading-3; }
.callout-heavy { @apply text-sm font-semibold tracking-widest leading-3; }
.subhead       { @apply text-xs font-normal tracking-wider leading-2; }
.subhead-heavy { @apply text-xs font-semibold tracking-wider leading-2; }
.caption-1       { @apply text-xxs font-normal tracking-wide leading-1; }
.caption-1-heavy { @apply text-xxs font-semibold tracking-wide leading-1; }
```

### When to Use Each

| Class | Context |
|-------|---------|
| `.large-title` | Hero sections, landing pages |
| `.title-1` | Page titles, modal headers |
| `.title-2` | Section headers, card titles |
| `.title-3` | Subsection headers, list group titles |
| `.body` | Default paragraph text |
| `.callout` | Helper text, descriptions |
| `.subhead` | Labels, form field titles |
| `.caption-1` | Timestamps, fine print |

## Line Height & Tracking

Brief uses **tighter** line heights than typical web defaults:

| Class | Line Height | Tracking | Notes |
|-------|-------------|----------|-------|
| `.large-title` | `leading-8` (2rem) | `tracking-tighter` | Display text needs tighter leading |
| `.title-*` | `leading-5`–`leading-7` | `tracking-tight`–`tracking-widest` | Varies by size |
| `.body` | `leading-4` (1rem) | `tracking-widest` | Compact for UI |

### Why Tight Leading?

Brief's UI often shows lists of items (decisions, signals, features). Tighter leading keeps related content visually grouped. For long-form reading (docs, weekly reports), consider using standard Tailwind leading (`leading-normal`, `leading-relaxed`).

## Font Loading

Fonts are loaded via Next.js font optimization in `web/lib/fonts.ts`:

```tsx
import { Spline_Sans, Spline_Sans_Mono, Piazzolla } from "next/font/google";

export const splineSans = Spline_Sans({
  variable: "--font-spline-sans",
  subsets: ["latin"],
  display: "swap",
  weight: ["300", "400", "500", "600", "700"],
});
```

This ensures:
- **No FOUT**: `display: swap` shows fallback immediately
- **Subset loading**: Only Latin characters
- **Variable fonts**: Multiple weights in single file

## Anti-Patterns

### ❌ Never Do This

```tsx
// Hardcoded font families
<h1 style={{ fontFamily: 'Inter' }}>Wrong</h1>
<p className="font-['Roboto']">Wrong</p>

// Ad-hoc size/weight combos when semantic class exists
<h2 className="text-2xl font-semibold tracking-tight leading-7">
  {/* Use .title-1-heavy instead */}
</h2>

// Mismatched fonts
<p className="font-serif">Body text in Piazzolla</p>
{/* Serif is for accents, not body */}
```

### ✅ Do This

```tsx
// Use CSS variables
<h1 className="font-sans title-1">Correct</h1>

// Use semantic classes
<h2 className="title-1-heavy">Correct</h2>

// Reserve serif for accents
<blockquote className="font-serif text-lg italic">
  "A distinctive quote"
</blockquote>
```

## Storybook Reference

Typography examples live in Storybook:

```bash
cd packages/ui-storybook && pnpm run storybook
# → Foundations / Type Basics
# → Foundations / Type Semantics
```

Visual regression tests guard the type scale — changes require baseline updates.
