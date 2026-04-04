# React Patterns

## Component Design
- One component per file, named export matching filename
- Define `Props` interface for every component
- Prefer function components with hooks
- Keep components under ~150 lines — split into sub-components when growing

```typescript
interface UserCardProps {
  user: User;
  onSelect: (id: string) => void;
  variant?: 'compact' | 'full';
}

export function UserCard({ user, onSelect, variant = 'full' }: UserCardProps) {
  // ...
}
```

## State Management
- **Local state** (`useState`): UI state scoped to one component (open/closed, form values)
- **Lifted state**: shared between siblings — lift to nearest common parent
- **Zustand**: global client state (user preferences, app state)
- **Server state** (React Query / SWR): remote data with caching, revalidation
- Do not use global state for data that's only needed in one component tree

## Custom Hooks
Extract reusable logic into custom hooks:
```typescript
function useDebounce<T>(value: T, delay: number): T {
  const [debounced, setDebounced] = useState(value);
  useEffect(() => {
    const timer = setTimeout(() => setDebounced(value), delay);
    return () => clearTimeout(timer);
  }, [value, delay]);
  return debounced;
}
```

## Forms
- Use controlled components with `useState` or form libraries (React Hook Form)
- Validate with Zod schemas shared between frontend and backend
- Show inline errors next to fields, not at the top
- Disable submit button during submission, show loading state

## Error Boundaries
Wrap major sections with error boundaries to prevent full-page crashes:
```typescript
<ErrorBoundary fallback={<SectionError />}>
  <Dashboard />
</ErrorBoundary>
```

## Component Composition
Prefer composition over prop drilling:
```typescript
// Instead of passing 10 props through 3 levels
<Layout sidebar={<Sidebar />} header={<Header />}>
  <MainContent />
</Layout>
```

## TypeScript with React
- Define Props interfaces (not types) for components
- Use `React.ReactNode` for children, not `React.FC`
- Use discriminated unions for variant props
- Use `as const` for string literal arrays (select options, etc.)
