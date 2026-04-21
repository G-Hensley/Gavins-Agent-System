# Add MFA to Login Flow

**Goal:** Require TOTP-based MFA on all Cognito logins.

## Task 1: Extend Cognito user pool

- Modify `infra/cognito-stack.ts` to enable MFA
- Update IAM role `LoginHandlerRole` to allow `cognito-idp:AdminSetUserMFAPreference`
- Add TOTP setup endpoint `POST /auth/mfa/setup` returning the shared secret
- Modify `api/src/handlers/login.ts` to enforce MFA challenge response before issuing session token
