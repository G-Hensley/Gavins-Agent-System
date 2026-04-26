---
name: frontend-design
description: Create production-grade, distinctive frontend interfaces with strong UI/UX principles. Use when building web components, pages, layouts, or applications. Also use when the user says "build a UI", "design this page", "make it look good", "style this", "CSS help", "Tailwind", "responsive design", or when working on any user-facing interface.
last_verified: 2026-04-26
---

# Frontend Design

Build distinctive, polished interfaces that avoid generic AI aesthetics. Focus on hierarchy, whitespace, typography, intentional motion, real states (not just the happy path), and systematic design decisions.

## Process

### 1. Understand the Context
- What is the user building? (dashboard, form, landing page, app shell, component)
- What's the existing design system? (tokens, Tailwind config, component library)
- What's the target: desktop, mobile, or responsive?
- What's the emotional tone? (See `references/emotional-design.md`.)

### 2. Establish Design Foundation
Before writing any CSS/markup, define:
- **Visual hierarchy** — what does the user see first, second, third?
- **Spacing system** — consistent whitespace rhythm on a 4/8px grid
- **Color palette** — primary, secondary, neutral, accent, semantic (success/error/warning)
- **Typography scale** — heading sizes, body text, captions with consistent ratio
- **Design tokens** — name your decisions; see `references/design-tokens.md`

### 3. Design All States, Not Just the Happy Path
Every screen has five states: ideal, empty, loading, error, partial. Design each one. See `references/state-design.md`.

### 4. Build with Intention
- Layout structure first (grid/flex), then content, then polish
- Mobile-first responsive design
- Semantic HTML before adding styling
- Component boundaries that map to visual sections
- Motion serves a purpose (`references/interaction-and-motion.md`)
- Microcopy is design (`references/ux-writing.md`)

### 5. Review and Audit
- Walk through Nielsen's 10 heuristics (`references/usability-heuristics.md`)
- Check accessibility (`references/accessibility.md`)
- Watch for anti-patterns (`references/anti-patterns.md`)
- Dispatch the `uiux-designer` subagent for design system creation or formal design review

## What NOT to Do

- Do not use default/generic styling — every element should have intentional spacing, color, and typography
- Do not center everything — use alignment that creates visual flow and hierarchy
- Do not use too many colors — stick to a defined palette
- Do not skip whitespace — cramped UI feels cheap; generous spacing feels professional
- Do not ignore mobile — build responsive from the start
- Do not use arbitrary values in Tailwind — use the token / config scale consistently
- Do not add decoration without purpose — every visual element should serve hierarchy or usability
- Do not design only the happy path — empty / loading / error / partial states must be designed
- Do not animate without purpose — motion serves feedback, continuity, focus, or personality, not "looks cool"
- Do not skip `prefers-reduced-motion` — accessibility is not optional
- Do not use placeholders as labels

## Reference Files

Read the relevant references before any UI work. Each is focused and < 200 lines.

### Foundations
- `references/design-principles.md` — Core principles summary: hierarchy, whitespace, responsive, components, accessibility
- `references/design-styles.md` — Style selection: how to choose, similar-style comparisons, combinations that work / clash. Entry point for the two style-detail files below.
- `references/design-tradition-styles.md` — Tradition styles (foundation): Minimalist, Swiss, Editorial, Constructivism, Brutalism/Neobrutalism, Retro, Hand-Drawn, Flat, Bento
- `references/design-css-techniques.md` — CSS technique styles (surface): Glassmorphism, Neumorphism, Claymorphism, Material, Corporate, Dark Mode
- `references/typography.md` — Font families, pairing, type scales, readability, line height, responsive typography
- `references/color-theory.md` — Color psychology, palette types, 60-30-10 rule, contrast, accessibility
- `references/layout-principles.md` — Alignment, grids, proximity, balance, repetition, whitespace, responsive patterns
- `references/design-laws.md` — Golden ratio, rule of thirds, Gestalt, Fitts, Hick, Miller, Jakob

### Interaction & Behavior
- `references/interaction-and-motion.md` — Motion philosophy, micro-interactions, easing/duration, performance-safe animation, `prefers-reduced-motion`
- `references/state-design.md` — Empty / loading / error / partial / offline states, optimistic UI
- `references/progressive-disclosure.md` — Disclosure patterns, IA, navigation models, wizards, the click-count myth
- `references/navigation-patterns.md` — Top/side/bottom nav, hamburger, breadcrumbs, mega menus, footer, search
- `references/form-design.md` — Layout, validation, autocomplete, mobile keyboards, multi-step, accessibility

### Content & Emotion
- `references/ux-writing.md` — Microcopy, button labels, error messages, voice/tone, placeholders
- `references/emotional-design.md` — Norman's three levels (visceral/behavioral/reflective), tone-by-context

### Systems & Trust
- `references/design-tokens.md` — Three-layer token architecture, theming, CSS custom properties, design system maturity ladder
- `references/atomic-design.md` — Atoms / molecules / organisms / templates / pages, component library organization
- `references/trust-and-credibility.md` — Visual + content trust signals, dark patterns to avoid

### Specialized
- `references/data-visualization.md` — Chart selection, dashboard layout, KPI cards, color-blind safe palettes
- `references/performance-as-design.md` — Perceived performance, Core Web Vitals (LCP/INP/CLS), images, fonts
- `references/modern-css.md` — Container queries, `:has()`, subgrid, scroll-driven animations, view transitions, OKLCH

### Quality Lenses
- `references/usability-heuristics.md` — Nielsen's 10 heuristics for design reviews
- `references/accessibility.md` — WCAG 2.2 / EAA compliance, POUR, semantic HTML, focus, contrast, ARIA
- `references/anti-patterns.md` — Visual / UX / form / performance / a11y / trust / microcopy failure modes

**Subagent:** `uiux-designer` — creates design systems, color palettes, typography, component specs. Located at `~/.claude/agents/uiux-designer.md`.
