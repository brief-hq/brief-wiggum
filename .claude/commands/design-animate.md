---
description: Add purposeful motion to Brief components
---

# /design-animate

Add purposeful, on-brand animations to a component. Prioritize CSS-only solutions; use Motion library for complex React interactions.

## Usage

```bash
/design-animate [component-path-or-selection]
```

## Context Gathering

Before adding animations, ask these clarifying questions:

1. **Purpose**: What user action or state change should the animation communicate?
2. **Prominence**: Is this a high-traffic interaction (modal, nav) or subtle detail (hover state)?
3. **Existing motion**: Does the component already have transitions that should be enhanced or replaced?
4. **Accessibility**: Are there users who might need reduced motion support?

If the user provides a clear target and purpose, proceed directly.

## Animation Principles

### 1. Purposeful Motion

Every animation should serve a purpose:
- **Feedback** — Confirm user action (button press, form submit)
- **Orientation** — Show where something came from/goes to (modals, drawers)
- **Attention** — Draw focus to important changes (notifications, errors)

### 2. Duration Guidelines

| Purpose | Duration | Use For |
|---------|----------|---------|
| Micro-interactions | 100-150ms | Hover, focus, button press |
| State changes | 200-300ms | Toggle, expand/collapse |
| Page transitions | 300-500ms | Modal open, drawer slide |
| Attention | 500-1000ms | Notification appear |

### 3. Easing

Use CSS ease functions:
- `ease-out` — Elements entering (modals opening)
- `ease-in` — Elements leaving (modals closing)
- `ease-in-out` — Position changes

## CSS-First Animations (Preferred)

### Hover/Focus States

```tsx
// Button hover lift
<Button className="transition-transform hover:-translate-y-0.5">
  Hover me
</Button>

// Card hover shadow
<Card className="transition-shadow hover:shadow-md">
  Content
</Card>

// Focus ring animation
<Input className="transition-shadow focus-visible:ring-ring/50 focus-visible:ring-[3px]" />
```

### Reveal Animations

```tsx
// Fade in on mount (CSS animation)
<div className="animate-in fade-in duration-300">
  Content appears
</div>

// Slide up on mount
<div className="animate-in slide-in-from-bottom-4 duration-300">
  Slides up
</div>
```

### Loading States

Brief has a built-in shimmer animation:

```tsx
// Skeleton loader
<div className="h-4 w-32 rounded bg-muted animate-shimmer" />
```

### Staggered Children

Use `animation-delay` for orchestrated reveals:

```tsx
<div className="space-y-2">
  {items.map((item, i) => (
    <div
      key={item.id}
      className="animate-in fade-in slide-in-from-bottom-2"
      style={{ animationDelay: `${i * 50}ms` }}
    >
      {item.content}
    </div>
  ))}
</div>
```

## Motion Library (Complex Interactions)

For gesture-based or physics-based animations, use Motion:

```tsx
import { motion } from "framer-motion";

// Drag to reorder
<motion.div
  drag="y"
  dragConstraints={{ top: 0, bottom: 100 }}
  whileDrag={{ scale: 1.02 }}
>
  Draggable item
</motion.div>

// Spring physics
<motion.div
  initial={{ scale: 0.9, opacity: 0 }}
  animate={{ scale: 1, opacity: 1 }}
  transition={{ type: "spring", stiffness: 300, damping: 20 }}
>
  Bouncy entrance
</motion.div>

// Exit animations (requires AnimatePresence)
import { AnimatePresence, motion } from "framer-motion";

<AnimatePresence>
  {isVisible && (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      exit={{ opacity: 0, y: -20 }}
    >
      Animated modal
    </motion.div>
  )}
</AnimatePresence>
```

## Anti-Patterns

### ❌ Avoid

```tsx
// Too slow (feels sluggish)
className="transition-all duration-1000"

// Jarring (no easing)
className="transition-all duration-200 ease-linear"

// Over-animated (distracting)
<div className="animate-bounce animate-pulse animate-spin">
  Too much!
</div>

// Animation for its own sake
<Logo className="animate-spin" />  // Why is the logo spinning?
```

## Output Format

```markdown
## Animated: [ComponentName]

### Animations Added
| Element | Animation | Duration | Easing | Purpose |
|---------|-----------|----------|--------|---------|
| Action buttons | Hover lift | 150ms | ease-out | Feedback |
| List items | Staggered fade-in | 300ms + 50ms/item | ease-out | Orientation |
| Modal | Exit fade | 200ms | ease-in | Orientation |

### Implementation
- CSS transitions for hover/focus (no JS)
- Motion library for modal exit (requires AnimatePresence)

### Reduced Motion Support
Added `@media (prefers-reduced-motion: reduce)` handling for:
- Staggered reveals → instant appear
- Modal transitions → crossfade only

### Updated Code
[Component with animations]
```

## Reference Docs

For deep context, see:
- `reference/motion.md` — Timing guidelines, easing curves, performance

## Verification

After adding animations:
1. Test with `prefers-reduced-motion` (should disable/reduce)
2. Verify on mobile (60fps)
3. Check Storybook for visual consistency
