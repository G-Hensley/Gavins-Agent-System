# Design Tradition Styles

When to reference: picking a visual foundation rooted in graphic-design history. These define layout philosophy, typography, composition, and hierarchy — not just surface effects.

For surface treatments (glassmorphism, neumorphism, etc.), see `design-css-techniques.md`. For style selection guidance, see `design-styles.md`.

## Minimalist

Clean, content-focused. Every element must earn its place. If it doesn't serve hierarchy or function, remove it.

- **Characteristics:** heavy whitespace; 2–3 colors max (often monochrome + one accent); clean sans-serif type; flat (no gradients/shadows); content hierarchy via size/weight/space, not color or decoration.
- **Use for:** SaaS dashboards, dev tools, portfolios, docs, photography, fashion brands.
- **Avoid for:** kids' products, food/restaurant warmth, anything where personality matters more than sophistication.
- **Common mistake:** minimalism is *not* "empty." Every remaining element must be perfect — poor minimalism is just a sparse page with no hierarchy.

```
bg-white text-gray-900  p-8 md:p-16  max-w-3xl mx-auto  space-y-8
```

## Swiss Style (International Typographic Style)

Born in 1950s Switzerland — the granddaddy of modern web design. Precision, order, and typography as the primary design element.

- **Characteristics:** strong modular grid; sans-serif (Helvetica, Univers, Inter); large headlines + compact body; asymmetric but balanced layouts; mostly monochrome with restrained accents; mathematical precision in spacing.
- **Use for:** technology companies, premium brands, professional services, design agencies.
- **Avoid for:** brands that need warmth or casualness — Swiss can feel cold when misapplied.
- **vs. Minimalism:** Minimalism strips away. Swiss adds structured complexity through grids, typographic hierarchy, and content. Swiss can be dense yet ordered; minimalism aims for sparse.

```
grid grid-cols-12 gap-6  font-sans tracking-tight
text-6xl font-bold leading-none      /* headlines */
text-sm font-normal leading-relaxed  /* body */
```

## Editorial

Print-magazine aesthetics adapted for the web. Rich, layered, visually dense in a controlled way.

- **Characteristics:** dramatic type contrast (48px headline, 14px body); decorative serifs (Playfair, Didot, Freight); multi-layer composition (text over images); pull quotes, drop caps, ornamental dividers; bold, large, full-bleed photography.
- **Use for:** digital magazines, blogs, news, content-heavy sites, luxury, fashion, food/lifestyle.
- **Avoid for:** SaaS, admin panels, dev tools — utility over atmosphere.
- **Key insight:** editorial is about contrast — between headline and body, image and text, dense sections and breathing room.

```
font-serif text-5xl md:text-7xl leading-none  /* headlines */
font-sans text-sm leading-relaxed              /* body */
max-w-prose mx-auto  border-t border-gray-300 pt-8
```

## Constructivism

Geometry-driven, dynamic. Asymmetric layouts that convey motion, energy, and forward-thinking ideology (rooted in early-20th-century Russian art).

- **Characteristics:** bold sans-serif headlines; geometric shapes as structure (lines, triangles, slashes); off-center, angled, intentionally unbalanced layouts; black/white photo cutouts over bold color; palette often red/black/white + one accent; diagonal lines breaking the grid.
- **Use for:** tech startups, creative agencies, activist orgs, launch/campaign pages.
- **Avoid for:** anything that needs to feel calm or traditional (healthcare, finance, legal).
- **vs. Brutalism:** both break conventions, but Constructivism has structured asymmetry and an ideology of progress; Brutalism has deliberate chaos.

```
bg-red-600 text-white  font-sans font-black uppercase tracking-widest
-rotate-3 md:-rotate-6  mix-blend-mode-multiply
```

## Brutalism & Neobrutalism

Bold, provocative, intentionally breaking design conventions. **Brutalism** is maximalist (raw, "ugly," default-browser energy). **Neobrutalism** keeps the energy (thick borders, hard shadows) but with more control — rounded corners, structured grids, harmonious palettes (Figma marketing, Gumroad, Notion).

- **Characteristics:** thick borders (3–4px+, often black); hard drop shadows (no blur, e.g. `4px 4px 0 #000`); monospace or grotesque sans-serif; clashing high-contrast colors; no radius (brutalism) or chunky radius (neo); deliberate misalignment.
- **Use for:** creative portfolios, art, counter-culture brands, statement pieces.
- **Avoid for:** finance, healthcare, enterprise B2B — anywhere convention signals quality.
- **Critical rule:** every "rough" choice must be deliberate. Random roughness looks like bugs.

```
border-4 border-black  font-mono uppercase tracking-widest
bg-yellow-300  shadow-[4px_4px_0px_#000]  rounded-none  /* brutalism */
rounded-xl                                              /* neobrutalism */
hover:translate-x-[2px] hover:translate-y-[2px] hover:shadow-none
```

## Retro / Vintage

Nostalgic aesthetic channelling specific decades — usually '70s, '80s, or '90s. Personality, warmth, cultural reference.

- **Characteristics:** era-specific palettes (burnt orange + mustard for '70s; neon pink + cyan for '80s; teal + lime for '90s); slight desaturation/age; grain/noise/scratch textures; vintage display typography; analog references (CRT scanlines, VHS, cassette, pixel art); warm textured backgrounds.
- **Use for:** cafés, music/entertainment, vintage shops, bars, breweries, heritage brands.
- **Avoid for:** anything cutting-edge or clinical.
- **Decade matters:** don't mix '70s and '90s — pick an era and commit in color, type, and references.

```
bg-amber-100 text-amber-950  font-display  rounded-full
shadow-[3px_3px_0px_theme(colors.amber.800)]  backdrop-brightness-95
```

## Hand-Drawn / Illustrated

Handwritten fonts, sketchy graphics, doodle illustrations. Warmth, creativity, approachability, human touch.

- **Characteristics:** handwritten/calligraphic for headlines + accents (Caveat, Patrick Hand, Dancing Script) — *never* body; rough photo edges, sketch icons; deliberately wobbly lines, brush strokes; loose, slightly off-grid layouts; doodle annotations (arrows, circles, underlines); warm organic palette.
- **Use for:** illustrator portfolios, kids' brands, family cafés, bakeries, craft shops, weddings, kid-focused education.
- **Avoid for:** enterprise, fintech, healthcare, legal.
- **Implementation tip:** start with a proper grid, get content structured, then nudge slightly off — order first, chaos second.

```
font-handwritten  rotate-1 md:rotate-2
border-2 border-dashed border-gray-400  rounded-[40%]
```

## Flat Design

Total simplicity. No depth effects, no pretending UI elements are physical objects.

- **Characteristics:** no shadows, gradients, textures, or 3D; basic geometric shapes; solid flat colors (pastels or saturated with strong contrast); clean sans-serif (Roboto, Open Sans, Inter); flat iconography; hierarchy via size/color/spacing, not depth.
- **Use for:** corporate sites, SaaS, government, news portals — clarity over atmosphere.
- **Avoid for:** luxury, entertainment, anything that needs visual richness.
- **Context:** emerged ~2012–13 as reaction to skeuomorphism (iOS 7, Microsoft Metro). Semi-flat (flat + subtle shadows for affordance) is the current evolution.

```
bg-blue-500 text-white  rounded-lg  shadow-none  border-0
hover:bg-blue-600   /* color shift only */
```

## Bento

Modular tile-based layouts inspired by the Japanese bento lunchbox. Self-contained rectangular panels in a tight grid.

- **Characteristics:** rounded rectangles (12–16px radius); tight grid, small gaps (8–16px); each tile is self-contained; tiles vary in size (1×1, 2×1, 1×2, 2×2) for hierarchy; clean readable typography per tile; subtle background variation between tiles; mini illustrations/charts/UI previews inside.
- **Use for:** feature/product marketing pages (Apple popularized this), dashboards, SaaS product pages, portfolio grids.
- **Avoid for:** long-form content, narrative-driven sites — bento is scan-and-explore, not linear reading.
- **Key insight:** tiles must make sense independently. No tile should depend on another for context.

```
grid grid-cols-2 md:grid-cols-4 gap-3 md:gap-4
rounded-2xl bg-gray-100 p-6           /* tile */
col-span-2 row-span-2                 /* featured */
```
