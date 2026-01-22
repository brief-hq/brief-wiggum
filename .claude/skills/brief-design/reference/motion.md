# Brief Motion Reference

Deep-dive on animation and motion in Brief. Use this when adding animations beyond basic hover states.

## Motion Philosophy

Brief uses **purposeful, restrained motion**. Every animation should:

1. **Provide feedback** — Confirm user actions
2. **Establish relationships** — Show where things come from/go to
3. **Guide attention** — Direct focus to changes

**Avoid**: Animation for decoration, excessive micro-interactions, bouncy/playful motion.

## Timing Guidelines

| Purpose | Duration | Example |
|---------|----------|---------|
| Micro-feedback | 100–150ms | Button press, toggle |
| State changes | 200–300ms | Expand/collapse, hover |
| Layout changes | 300–400ms | Modal open, drawer slide |
| Page transitions | 400–500ms | Route change, hero reveal |

### Exit vs. Enter

Exit animations should be **faster** than entrances (~75% duration). Users want to dismiss things quickly.

```css
.modal-enter { animation-duration: 300ms; }
.modal-exit  { animation-duration: 200ms; }
```

## Easing Curves

Brief uses exponential ease-out for natural deceleration:

```css
/* Recommended */
--ease-out-quart: cubic-bezier(0.25, 1, 0.5, 1);   /* Smooth, refined */
--ease-out-quint: cubic-bezier(0.22, 1, 0.36, 1);  /* Slightly snappier */
--ease-out-expo: cubic-bezier(0.16, 1, 0.3, 1);    /* Confident, decisive */

/* For enter animations */
--ease-out: ease-out;  /* Or custom cubic-bezier above */

/* For exit animations */
--ease-in: ease-in;
```

### ❌ Never Use

```css
/* Dated and tacky */
--bounce: cubic-bezier(0.34, 1.56, 0.64, 1);     /* ❌ Bounce */
--elastic: cubic-bezier(0.68, -0.6, 0.32, 1.6);  /* ❌ Elastic */
--linear: linear;                                  /* ❌ Feels robotic */
```

## CSS Animations

### Built-in: Shimmer

Brief has a shimmer animation for skeleton loaders:

```tsx
<div className="h-4 w-32 rounded bg-muted animate-shimmer" />
```

Defined in `globals.css`:
```css
@keyframes shimmer {
  0% { background-position: -200% 0; }
  100% { background-position: 200% 0; }
}
.animate-shimmer {
  animation: shimmer 2s infinite linear;
}
```

### Tailwind Animate Classes

Use Tailwind's animation utilities for common patterns:

```tsx
// Fade in
<div className="animate-in fade-in duration-300">Content</div>

// Slide up
<div className="animate-in slide-in-from-bottom-4 duration-300">Content</div>

// Combined
<div className="animate-in fade-in slide-in-from-bottom-2 duration-200">Content</div>
```

### Staggered Reveals

Use `animation-delay` for orchestrated entrances:

```tsx
{items.map((item, i) => (
  <div
    key={item.id}
    className="animate-in fade-in slide-in-from-bottom-2 duration-300"
    style={{ animationDelay: `${i * 50}ms` }}
  >
    {item.content}
  </div>
))}
```

**Rule**: Keep delays short (50–100ms per item). Long staggered reveals feel slow.

## Hover & Focus States

### Standard Patterns

```tsx
// Button hover lift
<Button className="transition-transform hover:-translate-y-0.5">
  Action
</Button>

// Card hover shadow
<Card className="transition-shadow hover:shadow-md">
  Content
</Card>

// Focus ring (standard for all interactive elements)
<input className="focus-visible:ring-ring/50 focus-visible:ring-[3px] focus-visible:outline-none" />
```

### Transition Properties

```tsx
// Prefer specific properties over transition-all
className="transition-colors"     // Color changes
className="transition-opacity"    // Fade
className="transition-transform"  // Move/scale
className="transition-shadow"     // Shadow changes

// Avoid (triggers unnecessary repaints)
className="transition-all"
```

## Motion Library (Complex Interactions)

For gesture-based or physics animations, use Motion (Framer Motion):

```tsx
import { motion, AnimatePresence } from "framer-motion";

// Spring entrance
<motion.div
  initial={{ scale: 0.95, opacity: 0 }}
  animate={{ scale: 1, opacity: 1 }}
  transition={{ type: "spring", stiffness: 300, damping: 25 }}
>
  Content
</motion.div>

// Exit animations (requires AnimatePresence wrapper)
<AnimatePresence>
  {isOpen && (
    <motion.div
      initial={{ opacity: 0, y: 10 }}
      animate={{ opacity: 1, y: 0 }}
      exit={{ opacity: 0, y: -10 }}
      transition={{ duration: 0.2 }}
    >
      Modal content
    </motion.div>
  )}
</AnimatePresence>

// Drag interactions
<motion.div
  drag="y"
  dragConstraints={{ top: 0, bottom: 100 }}
  whileDrag={{ scale: 1.02 }}
>
  Draggable
</motion.div>
```

### When to Use Motion vs CSS

| Use CSS | Use Motion |
|---------|------------|
| Hover/focus states | Exit animations |
| Simple fade/slide | Gesture-based (drag, swipe) |
| Skeleton loaders | Physics-based spring |
| Staggered reveals | Shared element transitions |

## Performance

### ✅ GPU-Accelerated (Safe)

```css
transform: translateX(), translateY(), scale(), rotate()
opacity
```

### ❌ Layout Thrashing (Avoid)

```css
width, height
top, left, right, bottom
margin, padding
```

### will-change

Add sparingly for known expensive animations:

```tsx
<div className="will-change-transform">
  {/* Only for elements that WILL animate */}
</div>
```

**Don't** add `will-change` to everything — it consumes GPU memory.

## Accessibility

### Reduced Motion

Always respect user preferences:

```css
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}
```

Brief's `globals.css` does **not** include this by default — add it when using custom animations.

### Motion Guidelines

- **Essential animations** (loading spinners, progress) can remain
- **Decorative animations** should be disabled
- **Page transitions** should crossfade (no slide)

## Anti-Patterns

### ❌ Never Do This

```tsx
// Bounce/elastic easing
className="transition-transform duration-300 ease-bounce"

// Animating layout properties
className="transition-all hover:w-full"

// Over-animation
<div className="animate-bounce animate-pulse">Too much!</div>

// Too slow
className="transition-all duration-1000"

// No easing
className="transition-all ease-linear"
```

### ✅ Do This

```tsx
// Smooth ease-out
className="transition-transform duration-200 ease-out hover:-translate-y-0.5"

// Transform only
className="transition-transform duration-300 hover:scale-105"

// Restrained, purposeful
<Button className="transition-colors hover:bg-primary/90">Action</Button>
```

## Storybook Reference

Motion examples in Storybook — inspect timing and easing:

```bash
cd packages/ui-storybook && pnpm run storybook
# → Components with interactive states
# → Skeleton loaders (shimmer)
```
