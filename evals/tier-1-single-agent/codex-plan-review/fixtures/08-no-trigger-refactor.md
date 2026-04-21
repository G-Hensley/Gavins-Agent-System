# Extract CSV Parsing to a Utility Module

**Goal:** Move duplicated CSV parsing logic from three handlers into a shared utility.

## Task 1: Create utility module

- Create `src/utils/csv.ts` with `parseCsv(input: string): Row[]`
- Update `src/handlers/reportA.ts`, `src/handlers/reportB.ts`, `src/handlers/reportC.ts` to import from the new util
- Add unit tests for the utility
- Delete the inlined parse functions
