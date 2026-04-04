# Frontend Security

## XSS Prevention
- Never use innerHTML, document.write, or dangerouslySetInnerHTML with user input
- Use textContent for plain text, DOM APIs for structured content
- In React: JSX auto-escapes by default — only dangerouslySetInnerHTML bypasses this
- Sanitize any HTML that must be rendered (use DOMPurify or equivalent)

## Content Security Policy (CSP)
- Set Content-Security-Policy headers to restrict script sources
- Avoid unsafe-inline and unsafe-eval — use nonces or hashes instead
- Start strict: default-src 'self' and loosen only as needed

## CSRF Protection
- Use anti-CSRF tokens for state-changing requests
- Set SameSite=Strict or SameSite=Lax on cookies
- Verify Origin header on sensitive endpoints

## Secure Cookies
- HttpOnly — prevents JavaScript access
- Secure — only sent over HTTPS
- SameSite — prevents cross-site request attachment
- Set appropriate Max-Age — avoid session cookies for persistent auth

## Input Handling
- Validate on the client for UX, validate on the server for security
- Never trust client-side validation as the only defense
- Escape output based on context (HTML, URL, CSS, JavaScript)

## Common Anti-Patterns to Catch
- Dynamic code execution with user input → use JSON.parse for structured data
- Setting innerHTML with unsanitized content → use textContent or sanitize
- Dynamic code generation from user strings → use structured logic instead
- URL params rendered in DOM without encoding → validate and encode first
- Tokens stored in localStorage → use HttpOnly cookies instead
