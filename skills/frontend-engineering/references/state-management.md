# State Management

## When to Use What

| State Type | Solution | Example |
|---|---|---|
| Local component | `useState` | Form input, toggle, dropdown open |
| Shared between siblings | Lift state to parent | Filter applied to list + count |
| Global app state | Zustand store | Theme, user session, sidebar state |
| Server data | React Query / SWR / fetch | API responses, cached data |
| URL state | URL params / searchParams | Active tab, pagination, filters |
| Form state | React Hook Form / native | Multi-field forms with validation |

## Zustand Patterns
```typescript
interface AppStore {
  user: User | null;
  setUser: (user: User | null) => void;
  sidebarOpen: boolean;
  toggleSidebar: () => void;
}

const useAppStore = create<AppStore>((set) => ({
  user: null,
  setUser: (user) => set({ user }),
  sidebarOpen: true,
  toggleSidebar: () => set((s) => ({ sidebarOpen: !s.sidebarOpen })),
}));

// Usage — select only what you need (prevents unnecessary re-renders)
const user = useAppStore((s) => s.user);
```

## React Context (When Zustand is Overkill)
Use for dependency injection (theme, locale, auth provider) — not for frequently changing state.
```typescript
const ThemeContext = createContext<Theme>('light');
export const useTheme = () => useContext(ThemeContext);
```

## Server State vs Client State
- **Server state**: data from APIs. Use fetch + cache, React Query, or SWR. Not Zustand.
- **Client state**: UI state, user preferences. Use Zustand or useState.
- Don't duplicate server data into Zustand — that's a cache, not state.

## Anti-Patterns
- Global state for everything → most state is local
- Zustand store with 30 fields → split into domain stores
- Putting API data in Zustand → use a data fetching library
- Context for frequently changing values → causes re-renders in all consumers
