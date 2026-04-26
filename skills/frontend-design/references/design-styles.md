# Design Styles & Aesthetics

When to reference: choosing a visual direction for a project, matching a style to a brand or audience, or when the user asks for a specific aesthetic.

This file is the entry point. For deep-dive details on each style, see:
- `design-tradition-styles.md` — graphic-design-history-rooted styles (Minimalist, Swiss, Editorial, Constructivism, Brutalism, Retro, Hand-Drawn, Flat, Bento)
- `design-css-techniques.md` — CSS treatment styles (Glassmorphism, Neumorphism, Claymorphism, Material, Corporate, Dark Mode)

## How to Choose a Style

Match the aesthetic to the audience, industry, and emotional tone — not personal preference. Ask three questions before choosing:

1. **Who is the audience?** A developer-tools company and a children's brand need fundamentally different visual languages.
2. **What emotion should the site evoke?** Trust? Excitement? Calm? Playfulness? Luxury?
3. **What are the conventions of this industry?** Jakob's Law: users expect your site to work like the ones they already know. Breaking conventions should be intentional, not accidental.

| Goal | Styles that work |
|------|-----------------|
| Trust & authority | Swiss, Corporate, Minimalist, Flat |
| Innovation & energy | Constructivism, Brutalism, Glassmorphism |
| Playfulness & warmth | Hand-Drawn, Claymorphism, Retro |
| Luxury & premium | Minimalist + Dark Mode, Editorial, Swiss |
| Technical & developer | Minimalist, Dark Mode, Monospace accents |
| Creative & artistic | Brutalism, Editorial, Hand-Drawn |
| Content-dense & organized | Bento, Flat, Corporate, Swiss |
| Nostalgic & personality-driven | Retro, Hand-Drawn, Editorial |

## Mixing Rule

**Don't mix tradition styles.** Pick one direction and commit. Inconsistency reads as unfinished, not creative.

**Exception:** you can layer a CSS technique (glassmorphism, neumorphism, dark mode) onto a tradition style (minimalist, Swiss, editorial) since they operate at different levels — philosophy vs. surface treatment.

## Choosing Between Similar Styles

| Comparison | Key difference |
|---|---|
| Minimalist vs. Swiss | Minimalism strips away; Swiss adds structured complexity through grids and typography |
| Minimalist vs. Flat | Minimalism is a philosophy (less is more); Flat is a technique (no depth effects). Flat can be busy; minimalism can't. |
| Brutalism vs. Constructivism | Brutalism provokes through chaos; Constructivism channels energy through structured asymmetry. |
| Editorial vs. Swiss | Editorial is decorative and layered; Swiss is clean and grid-pure. |
| Bento vs. Corporate | Bento uses modular tiles with visual variety; Corporate uses tables, lists, uniform spacing. |
| Retro vs. Hand-Drawn | Retro references specific past decades; Hand-Drawn references handmade craft without an era. |
| Glassmorphism vs. Neumorphism | Glass is transparent over color; Neumorphism is opaque, extruded from a matching surface. |
| Flat vs. Material | Material is Google's evolution of Flat — adds shadow-based elevation and prescribed motion. |

## Combinations That Work

- **Minimalist + Glassmorphism** — clean layout with frosted cards over a gradient hero
- **Swiss + Dark Mode** — precision grid typography on dark surfaces. Premium tech aesthetic.
- **Editorial + Retro** — magazine layout with vintage typography and muted palette
- **Corporate + Flat** — information-dense dashboard with flat, shadow-free components
- **Bento + Neumorphism** — tile grid with soft extruded panels (subtle, not for text-heavy tiles)
- **Minimalist + Dark Mode** — the default "premium tech" look. Generous space + restrained accent.

## Combinations That Clash

- **Brutalism + Corporate** — chaos undermines trust signals
- **Claymorphism + Swiss** — playful 3D clay conflicts with precision
- **Hand-Drawn + Material** — Google's structured system conflicts with organic imperfection
- **Neumorphism + Editorial** — soft shadows disappear in content-dense layouts
- **Retro + Glassmorphism** — frosted glass is modern; breaks vintage immersion

## Quick Selection Workflow

1. Brief audit — write 3 adjectives the brand should evoke (e.g., *trustworthy / fast / serious*)
2. Cross-reference with the **Goal** table above
3. Pick **one** tradition style as the foundation
4. Optionally layer **one** CSS technique on top
5. Validate: pull up 2-3 reference sites in that style — does the brand fit there?
