# Node.js Backend Patterns

## Project Structure
```
src/
├── routes/         # Express/Next.js route handlers
├── services/       # Business logic
├── repositories/   # Data access, API clients
├── models/         # TypeScript types/interfaces
├── middleware/      # Auth, validation, error handling
├── utils/          # Shared utilities
└── config.ts       # Configuration from env vars
```

## Layered Architecture
Same principle as Python: handlers → services → repositories. Keep framework code in handlers, business logic in services.

## TypeScript Patterns
```typescript
// Use interfaces for API contracts
interface CreateUserRequest {
  name: string;
  email: string;
}

interface UserResponse {
  id: string;
  name: string;
  email: string;
  createdAt: string;
}

// Use Zod for runtime validation
const createUserSchema = z.object({
  name: z.string().min(1).max(100),
  email: z.string().email(),
});
```

## Express Error Handling
```typescript
class AppError extends Error {
  constructor(
    public message: string,
    public code: string,
    public status: number = 500
  ) { super(message); }
}

// Error middleware (register last)
app.use((err: Error, req: Request, res: Response, next: NextFunction) => {
  if (err instanceof AppError) {
    return res.status(err.status).json({ error: err.code, message: err.message });
  }
  logger.error('Unexpected error', { error: err, requestId: req.id });
  res.status(500).json({ error: 'internal', message: 'Internal error' });
});
```

## Next.js API Routes
```typescript
export async function POST(request: Request) {
  const body = await request.json();
  const validated = createUserSchema.parse(body); // Zod validation
  const result = await userService.create(validated);
  return Response.json(result, { status: 201 });
}
```

## Async Patterns
```typescript
// Parallel with concurrency limit
async function processInBatches<T>(items: T[], fn: (item: T) => Promise<void>, concurrency = 5) {
  for (let i = 0; i < items.length; i += concurrency) {
    await Promise.all(items.slice(i, i + concurrency).map(fn));
  }
}
```

## Middleware Pattern
```typescript
function requireAuth(req: Request, res: Response, next: NextFunction) {
  const token = req.headers.authorization?.replace('Bearer ', '');
  if (!token) return res.status(401).json({ error: 'unauthorized' });
  try {
    req.user = verifyToken(token);
    next();
  } catch { res.status(401).json({ error: 'invalid_token' }); }
}
```
