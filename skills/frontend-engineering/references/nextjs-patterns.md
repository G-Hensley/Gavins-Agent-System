# Next.js Patterns (App Router)

## Server vs Client Components
- **Default is Server** — components are server components unless marked `'use client'`
- **Server**: data fetching, database access, sensitive logic, no useState/useEffect
- **Client**: interactivity, browser APIs, useState, useEffect, event handlers
- Push `'use client'` as deep as possible — keep most of the tree server-rendered

```
app/
├── layout.tsx        # Server — shared layout
├── page.tsx          # Server — data fetching
└── components/
    ├── DataTable.tsx  # Server — renders data
    └── SearchBar.tsx  # 'use client' — needs input state
```

## Data Fetching
```typescript
// Server component — fetch directly (no useEffect needed)
export default async function DashboardPage() {
  const data = await fetchDashboardData();
  return <Dashboard data={data} />;
}
```
- Fetch in server components, pass data down as props
- Use `loading.tsx` for streaming/suspense fallbacks
- Use `error.tsx` for error boundaries per route segment

## Route Organization
```
app/
├── (auth)/           # Route group (no URL segment)
│   ├── login/
│   └── signup/
├── dashboard/
│   ├── page.tsx      # /dashboard
│   ├── loading.tsx   # Loading state
│   └── [id]/
│       └── page.tsx  # /dashboard/:id
└── api/
    └── v1/
        └── users/
            └── route.ts  # API route handler
```

## API Routes
```typescript
export async function GET(request: Request) {
  const { searchParams } = new URL(request.url);
  const data = await service.list(searchParams);
  return Response.json(data);
}

export async function POST(request: Request) {
  const body = await request.json();
  const validated = schema.parse(body);
  const result = await service.create(validated);
  return Response.json(result, { status: 201 });
}
```

## Middleware
```typescript
// middleware.ts (root level)
export function middleware(request: NextRequest) {
  // Auth check, redirects, headers
  if (!request.cookies.get('session')) {
    return NextResponse.redirect(new URL('/login', request.url));
  }
}
export const config = { matcher: ['/dashboard/:path*'] };
```

## Environment Variables
- `NEXT_PUBLIC_*` — exposed to client (non-sensitive only)
- Everything else — server-only (secrets, API keys)
- Access via `process.env` in server components and API routes
