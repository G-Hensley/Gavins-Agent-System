# Design Principles

## Visual Hierarchy
The most important element should be the most visually prominent. Establish hierarchy through:
- **Size**: larger = more important. Heading scale: 2xl → xl → lg → base → sm
- **Weight**: bold for emphasis, normal for body, light for secondary
- **Color**: high contrast for primary content, muted for secondary
- **Position**: top-left gets scanned first (F-pattern for text, Z-pattern for landing pages)
- **Spacing**: more space around important elements isolates and elevates them

## Whitespace
Whitespace is not empty space — it's a design tool. Use it to:
- **Group related elements** — tighter spacing within groups, wider between groups
- **Create breathing room** — cramped layouts feel cheap; generous padding feels professional
- **Establish rhythm** — use a consistent spacing scale (4, 8, 12, 16, 24, 32, 48, 64px)
- **Direct attention** — isolated elements with surrounding whitespace draw the eye

Tailwind spacing: use the scale consistently. `p-4` for tight, `p-6` for standard, `p-8` for generous, `p-12`+ for sections.

## Color Theory
- **60-30-10 rule**: 60% neutral/background, 30% secondary, 10% accent
- **Contrast**: WCAG AA minimum (4.5:1 for text, 3:1 for large text)
- **Semantic colors**: green=success, red=error, yellow=warning, blue=info — don't override these associations
- **Dark/light modes**: design for both. Use CSS variables or Tailwind dark: variants
- **Saturation**: lower saturation for backgrounds and large areas, higher for small accents and CTAs

## Typography
- **One typeface** is usually enough. Two max (one for headings, one for body).
- **Scale ratio**: use a consistent ratio between sizes (1.25 minor third, 1.333 perfect fourth)
- **Line height**: 1.5 for body text, 1.2-1.3 for headings
- **Line length**: 45-75 characters per line for readability (max-w-prose in Tailwind)
- **Weight pairs**: bold headings + normal body, or medium headings + light body

## Responsive Design
- **Mobile-first**: write base styles for mobile, add breakpoints for larger screens
- **Breakpoints**: sm(640) → md(768) → lg(1024) → xl(1280). Don't add custom breakpoints.
- **Flexible grids**: use `grid-cols-1 md:grid-cols-2 lg:grid-cols-3` patterns
- **Touch targets**: minimum 44x44px for interactive elements on mobile
- **Stack on mobile**: side-by-side layouts should stack vertically on small screens

## Component Patterns
- **Cards**: consistent padding, subtle border or shadow, rounded corners. Don't mix styles.
- **Forms**: label above input, consistent field spacing, clear error states, visible focus rings
- **Buttons**: primary (filled), secondary (outlined), ghost (text only). Clear hierarchy.
- **Navigation**: sticky header, clear active state, mobile hamburger or bottom nav
- **Tables**: zebra striping or borders (not both), sticky headers for long tables, responsive overflow

## Tailwind Implementation
- Use the design system (`tailwind.config.js` colors, spacing, fonts) — don't use arbitrary values
- Extract repeated patterns into components, not utility class strings
- Use `@apply` sparingly — prefer component extraction
- Use `group` and `peer` for interactive state management
- Use `ring` for focus indicators (accessible and visible)

## Accessibility Essentials
- Semantic HTML: `nav`, `main`, `section`, `article`, `button` (not div-with-onclick)
- Alt text on images, aria-labels on icon buttons
- Visible focus indicators on all interactive elements
- Sufficient color contrast (check with contrast checker)
- Keyboard navigable: tab order follows visual order
