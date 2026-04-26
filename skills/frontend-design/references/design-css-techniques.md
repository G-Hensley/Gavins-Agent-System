# Design CSS-Technique Styles

When to reference: applying surface treatments to a chosen design tradition. These are CSS techniques — they layer onto layout philosophies (minimalist, Swiss, editorial, etc.) without replacing them.

For tradition styles (the foundation), see `design-tradition-styles.md`. For selection guidance, see `design-styles.md`.

## Glassmorphism

Frosted-glass effect with transparency, blur, and subtle borders. Content panels float over vibrant backgrounds.

- **Characteristics:** translucent backgrounds (`bg-white/10`–`bg-white/30`); backdrop-blur 8–24px; subtle light borders (`border-white/20`); soft shadows; generous radius.
- **Use for:** hero sections with gradient backgrounds, dashboard overlays, music/media players, modal dialogs, floating navigation.
- **Avoid for:** text-heavy interfaces (frosted bg reduces contrast); performance-constrained mobile (backdrop-filter is GPU-intensive); pages without colorful backgrounds (nothing to blur).
- **Critical:** verify text contrast on frosted panels. White text on frosted white is unreadable — increase opacity or add a dark overlay.

```
bg-white/10 backdrop-blur-lg border border-white/20 rounded-2xl shadow-xl
```

## Neumorphism (Soft UI)

Soft, extruded elements that appear to push out of or sink into a matching background. Dual shadows on a same-color base.

- **Characteristics:** background and elements share the same base color; dual box-shadow (light upper-left + dark lower-right); soft rounded corners; quiet, almost subliminal effect; pressed variant uses `inset` shadows.
- **Use for:** calculators, settings panels, IoT dashboards, music/timer apps — interfaces with a tactile metaphor.
- **Avoid for:** text-heavy interfaces, forms, data-dense apps. Significant accessibility problems — low contrast hides interactive elements.
- **Accessibility warning:** always supplement with focus rings, hover state changes, or icon indicators. Pure neumorphism fails WCAG 3:1 contrast for UI components.

```
bg-gray-200  rounded-xl
shadow-[8px_8px_16px_#b8b8b8,-8px_-8px_16px_#ffffff]              /* raised */
shadow-[inset_4px_4px_8px_#b8b8b8,inset_-4px_-4px_8px_#ffffff]    /* pressed */
```

## Claymorphism

3D clay/plasticine. Rounded, puffy, tactile elements with inner shadows and pastel backgrounds.

- **Characteristics:** very large radius (24px+); inner shadow (inflated look) + outer shadow (depth); pastel palette (pink, lavender, mint, peach, baby blue); often paired with 3D Blender clay illustrations; subtle gradient backgrounds.
- **Use for:** kids' products, creative apps, onboarding flows, marketing landing pages for playful brands, education platforms.
- **Avoid for:** professional/corporate, finance, healthcare, dev tools — playful conflicts with the needed tone.

```
rounded-3xl  bg-gradient-to-br from-pink-200 to-purple-200  shadow-xl
shadow-[inset_0_-4px_8px_rgba(0,0,0,0.1),0_8px_24px_rgba(0,0,0,0.15)]
```

## Material Design

Google's design system. Elevation-based depth via shadows, card layouts, bold accents, structured motion.

- **Characteristics:** consistent shadow scale representing elevation 1–5; 8dp grid (all spacing × 8); FAB for primary actions; drawer navigation; ripple effect on click; cards as the content unit; bold accents on neutral base; defined motion curves.
- **Use for:** Android-adjacent apps, productivity tools, admin panels, anything in Google's ecosystem.
- **Avoid for:** iOS-native experiences (use Apple HIG); luxury brands; editorial sites.

```
shadow-sm   /* elevation 1 */
shadow-md   /* elevation 2 */
shadow-lg   /* elevation 3 */
shadow-xl   /* elevation 4 */
rounded-lg  transition-shadow hover:shadow-lg
```

## Corporate / Enterprise

Professional, trustworthy, information-dense. The visual language of B2B SaaS, financial dashboards, admin systems.

- **Characteristics:** navy/slate/gray palettes + one professional accent (blue, teal, indigo); high information density (data tables, metrics, charts, sidebar nav); compact spacing (`p-3 gap-2`); clear borders/dividers; functional iconography (Lucide, Heroicons, Phosphor); sidebar nav with collapsible sections; breadcrumbs for deep hierarchies; minimal decoration.
- **Use for:** B2B SaaS, fintech dashboards, healthcare portals, admin systems, CRMs, internal tools.
- **Avoid for:** consumer-facing products, marketing sites, anything emotional.

```
bg-slate-50 text-slate-800  border border-slate-200
p-3 gap-2  text-sm  divide-y divide-slate-100
```

## Dark Mode

Not just inverting colors — a complete design direction with its own palette decisions.

- **Background:** never pure black (`#000`). Use `gray-900` (main) or `gray-950` (deepest). Pure black causes halation on OLED.
- **Text:** never pure white for body. Use `gray-100` for headings, `gray-300` for body, `gray-500` for muted.
- **Elevation is inverted:** lighter = higher elevation. Elevated cards are `gray-800` on `gray-900` (opposite of light mode).
- **Accents:** reduce saturation. A `blue-500` on white becomes `blue-400` or `blue-300` on dark — vivid colors vibrate against dark backgrounds.
- **Borders > shadows.** Shadows mostly disappear on dark surfaces — use `ring-1 ring-gray-700` to define edges.
- **Images:** consider slight brightness/contrast reduction so they don't wash out the UI.

**Use for:** tech products, gaming, dev tools, media apps (video, music, reading). Many brands now lead with dark-first.

**Implementation:** define the dark palette upfront in CSS custom properties — don't bolt it on later. Use `prefers-color-scheme: dark` plus a manual toggle.

```css
:root {
  --color-surface: #ffffff;
  --color-text: #1a1a1a;
}
[data-theme="dark"] {
  --color-surface: #111827;
  --color-text: #e5e7eb;
}
```

```
dark:bg-gray-900 dark:text-gray-100
dark:border-gray-700  dark:shadow-none
dark:ring-1 dark:ring-gray-700   /* rings replace shadows */
```
