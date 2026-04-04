# Frontend Performance

## Code Splitting
- Next.js automatically splits by route
- Use `dynamic()` for heavy components not needed on initial load:
```typescript
const HeavyChart = dynamic(() => import('./HeavyChart'), {
  loading: () => <ChartSkeleton />,
});
```

## Memoization
Use sparingly — only when profiling shows a problem:
- `React.memo()` — prevent re-render when props haven't changed
- `useMemo()` — cache expensive computations
- `useCallback()` — stable function references for child components
- Do NOT memoize everything by default — it has overhead

## Bundle Size
- Import only what you need: `import { Button } from './ui'` not `import * as UI`
- Check bundle with `@next/bundle-analyzer`
- Tree-shaking works with ES modules — avoid CommonJS imports
- Use `next/image` for automatic image optimization

## Core Web Vitals
- **LCP** (Largest Contentful Paint): preload hero images, use server components for initial data
- **FID/INP** (Interaction to Next Paint): keep main thread free, defer non-critical JS
- **CLS** (Cumulative Layout Shift): set explicit dimensions on images/videos, avoid dynamic content insertion above fold

## Data Fetching Performance
- Fetch in server components (no client-side waterfall)
- Use React Suspense + streaming for progressive loading
- Cache API responses appropriately (stale-while-revalidate)
- Prefetch links: `<Link prefetch>` in Next.js

## Rendering Strategies
- **SSR**: dynamic data, personalized pages (use when data changes per request)
- **SSG**: static content, blog posts (use when data rarely changes)
- **ISR**: mix of both (revalidate at intervals)
- **Client**: interactive widgets, real-time data (use when server can't help)
