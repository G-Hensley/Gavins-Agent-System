# Code Smells

Indicators that code needs refactoring. Not bugs — the code works, but it's harder to understand, change, or maintain than it should be.

## Size Smells
- **Long function** (>50 lines): doing too much, extract into sub-functions
- **Large file** (>300 lines): multiple responsibilities, split into focused modules
- **Long parameter list** (>4 params): group into an object/config
- **Deep nesting** (>3 levels): invert conditions, extract early returns, extract functions

## Duplication Smells
- **Copy-pasted code**: same logic in multiple places — extract to shared function
- **Parallel type definitions**: same shape defined in multiple files — define once, import
- **Similar switch/if chains**: same conditions in multiple places — use polymorphism or lookup table
- **Repeated setup code**: same initialization pattern — extract to factory or builder

## Naming Smells
- **Vague names**: `data`, `info`, `handler`, `manager`, `utils` — rename to describe what it does
- **Misleading names**: name suggests one thing, implementation does another
- **Abbreviated names**: `usr`, `mgr`, `proc` — use full words
- **Boolean naming**: `flag`, `status` — use `isActive`, `hasPermission`, `canEdit`

## Coupling Smells
- **Feature envy**: function uses more data from another module than its own — move it
- **Inappropriate intimacy**: module reaches into another's internals — define an interface
- **Shotgun surgery**: one change requires edits in many unrelated files — consolidate
- **God object**: one class/module that everything depends on — break into focused modules

## Abstraction Smells
- **Premature abstraction**: abstraction for one use case — inline until you have 3 cases
- **Missing abstraction**: raw primitives where a named concept would clarify — create a type/class
- **Leaky abstraction**: implementation details exposed through the interface — hide them
- **Dead code**: unused functions, unreachable branches — delete them
