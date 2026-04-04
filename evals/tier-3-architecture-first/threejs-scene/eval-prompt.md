Build an interactive 3D solar system visualization in the browser using Three.js.

The scene should show the Sun at the center with at least 6 planets orbiting it. Each planet should:
- Orbit the Sun at a speed and radius roughly proportional to real relative values (exact accuracy not required, just clearly distinguishable)
- Rotate on its own axis
- Be visually distinct — different size, color, or texture

The user should be able to interact with the scene:
- **Orbit controls** — click-drag to rotate the camera around the scene, scroll to zoom
- **Click a planet** — clicking a planet displays a label or tooltip with its name and approximate distance from the Sun
- **Speed slider** — a UI control that adjusts the global orbit speed from paused to 10x

The scene needs a starfield background, ambient and directional lighting (Sun as the light source), and smooth 60 fps animation via `requestAnimationFrame`.

The app should be a single HTML file or a minimal Vite + vanilla JS project. No React required. Focus on the Three.js implementation — not on framework scaffolding.

Keep the code organized: separate files (or clearly separated sections) for scene setup, planet configuration, animation loop, and UI controls.
