# Refactoring Patterns

Common refactoring operations. Each should be done as a single, testable step.

## Extract Function
Pull a block of code into a named function.
```
// Before: inline logic
if (user.role === 'admin' && user.isActive && !user.isSuspended) { ... }

// After: extracted with descriptive name
if (canAccessAdmin(user)) { ... }
function canAccessAdmin(user) { return user.role === 'admin' && user.isActive && !user.isSuspended; }
```

## Extract Module
Split a large file into focused modules.
```
// Before: utils.ts (500 lines with date, string, and validation helpers)
// After:
//   date-utils.ts (date formatting, parsing, comparison)
//   string-utils.ts (truncation, casing, sanitization)
//   validators.ts (email, phone, required fields)
```

## Rename
Change names to better describe purpose. Update all references.
```
// Before
function process(d) { ... }
// After
function formatUserReport(userData) { ... }
```

## Inline
Remove unnecessary abstraction — move code back to the call site.
```
// Before: function called once, adds indirection without value
function getConfig() { return { timeout: 5000 }; }
const config = getConfig();

// After: inline the value
const config = { timeout: 5000 };
```

## Replace Conditional with Polymorphism
Replace complex switch/if chains with a lookup or strategy pattern.
```
// Before
if (type === 'csv') exportCsv(data);
else if (type === 'json') exportJson(data);
else if (type === 'pdf') exportPdf(data);

// After
const exporters = { csv: exportCsv, json: exportJson, pdf: exportPdf };
exporters[type](data);
```

## Introduce Parameter Object
Group related parameters into a single object.
```
// Before
function createUser(name, email, role, team, startDate) { ... }

// After
function createUser(params: CreateUserParams) { ... }
```

## Move to Appropriate Module
Move a function to the module that owns the data it works with.
```
// Before: user-utils.ts contains formatProjectName()
// After: move formatProjectName() to project-utils.ts
```

## Replace Magic Values
Extract unnamed constants into named values.
```
// Before
if (retries > 3) { ... }
setTimeout(fn, 86400000);

// After
const MAX_RETRIES = 3;
const ONE_DAY_MS = 24 * 60 * 60 * 1000;
```

## Safety Checklist
Before each refactoring step:
- [ ] Tests pass before the change
- [ ] The change is purely structural (no behavior change)
- [ ] Tests pass after the change
- [ ] Commit with descriptive message
