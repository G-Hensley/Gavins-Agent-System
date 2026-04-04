# E2E Testing (Playwright)

## Page Object Pattern
```typescript
class LoginPage {
  constructor(private page: Page) {}

  async goto() {
    await this.page.goto('/login');
  }

  async login(email: string, password: string) {
    await this.page.fill('[data-testid="email"]', email);
    await this.page.fill('[data-testid="password"]', password);
    await this.page.click('[data-testid="submit"]');
  }

  async expectError(message: string) {
    await expect(this.page.locator('[data-testid="error"]')).toHaveText(message);
  }
}
```
One page object per page/section. Encapsulate selectors and actions. Tests read like user stories.

## Test Structure
```typescript
test.describe('User Authentication', () => {
  test('successful login redirects to dashboard', async ({ page }) => {
    const loginPage = new LoginPage(page);
    await loginPage.goto();
    await loginPage.login('user@test.com', 'password');
    await expect(page).toHaveURL('/dashboard');
  });

  test('invalid credentials show error', async ({ page }) => {
    const loginPage = new LoginPage(page);
    await loginPage.goto();
    await loginPage.login('user@test.com', 'wrong');
    await loginPage.expectError('Invalid credentials');
  });
});
```

## Test Isolation
- Each test starts from a clean state
- Use `test.beforeEach` for setup, not shared mutable state
- Use API calls to set up test data (faster than UI setup)
- Clean up after tests (or use isolated test databases)

## Selectors (Priority Order)
1. `data-testid` — most stable, explicit test hooks
2. `role` — accessible, semantic (`getByRole('button', { name: 'Submit' })`)
3. `text` — readable but fragile to copy changes
4. CSS selectors — last resort, fragile

## Waiting
- Use Playwright's auto-waiting (built into actions)
- For custom waits: `await page.waitForSelector('[data-testid="loaded"]')`
- Never use `page.waitForTimeout()` — use condition-based waiting

## CI Integration
```yaml
- name: E2E Tests
  run: npx playwright test
  env:
    BASE_URL: http://localhost:3000
```
- Run against a local or staging server, not production
- Use Playwright's built-in HTML reporter for failure screenshots
- Parallelize with `workers` config for speed
