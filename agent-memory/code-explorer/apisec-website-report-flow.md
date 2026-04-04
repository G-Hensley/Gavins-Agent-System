---
name: ApisecWebsite — Developer Report Button Flow
description: Entry points, API calls, polling logic, auth token handling, and SSO bug location for developer report page
type: project
---

Key files for the developer report feature:

- `/src/pages/Reports/DeveloperReportTableActions.tsx` — button state machine, polling loop
- `/src/pages/Reports/ReportPage.tsx` — report table page, renders DeveloperReportTableActions
- `/src/utils/services/Reports/useReportsService.tsx` — API calls, token handling
- `/src/utils/services/api-client.ts` — axios client, auth header injection (uses `getAuthTokenAtom()`)
- `/src/utils/services/apiService.ts` — wraps apiClient, handles 401/session signout
- `/src/pages/main/Main.tsx` — sets `authTokenAtom`; Cognito sets object, Keycloak sets string
- `/src/utils/store/Store.tsx` — `authTokenAtom` and `getAuthTokenAtom()` definition

API endpoint:
- GET/POST `/v1/communications/applications/{appId}/instances/{instanceId}/dev-report`
- GET `/v1/communications/applications/{appId}/instances/{instanceId}/dev-report/download`

Status state machine: NONE → GENERATING → READY | FAILED | STALE
Polling interval: 4000ms while status === "GENERATING"

**Why:** SSO token shape issue — Cognito sets `authTokenAtom` to an idToken object (has `.toString()`) but `getAuthTokenAtom()` returns the raw object and template literal gives `[object Object]` in Bearer header. Keycloak users set a raw string. Regular Amplify users may also use the object but `.toString()` works on Cognito's JWT token class.
