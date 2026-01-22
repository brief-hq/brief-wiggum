import { test as setup, expect } from '@playwright/test';

/**
 * Authentication setup for Playwright tests
 *
 * Customize this file for your auth provider:
 * - Clerk: https://clerk.com/docs/testing/playwright
 * - Auth0: https://auth0.com/docs/authenticate/login/test-integration
 * - NextAuth: https://next-auth.js.org/tutorials/testing-with-cypress
 *
 * This runs once before all tests and saves auth state to reuse.
 */

const authFile = 'playwright/.auth/user.json';

setup('authenticate', async ({ page }) => {
  // ═══════════════════════════════════════════════════════════════════════
  // CUSTOMIZE THIS SECTION FOR YOUR AUTH PROVIDER
  // ═══════════════════════════════════════════════════════════════════════

  // Example: Clerk authentication
  // await page.goto('/sign-in');
  // await page.fill('[name="identifier"]', process.env.TEST_USER_EMAIL!);
  // await page.click('button:has-text("Continue")');
  // await page.fill('[name="password"]', process.env.TEST_USER_PASSWORD!);
  // await page.click('button:has-text("Continue")');
  // await page.waitForURL('/dashboard');

  // Example: Custom login form
  // await page.goto('/login');
  // await page.fill('#email', process.env.TEST_USER_EMAIL!);
  // await page.fill('#password', process.env.TEST_USER_PASSWORD!);
  // await page.click('button[type="submit"]');
  // await page.waitForURL('/dashboard');

  // Example: OAuth (requires test credentials or mock)
  // await page.goto('/auth/google');
  // ... OAuth flow

  // ═══════════════════════════════════════════════════════════════════════
  // END CUSTOMIZATION
  // ═══════════════════════════════════════════════════════════════════════

  // Placeholder: Skip auth in demo mode
  console.log('Auth setup placeholder - customize for your auth provider');
  console.log('See comments in this file for examples');

  // If no auth needed for tests, just navigate to home
  // await page.goto('/');

  // Save authentication state
  // Uncomment when auth is configured:
  // await page.context().storageState({ path: authFile });
});

/**
 * Environment variables needed for test auth:
 *
 * TEST_USER_EMAIL - Test user email
 * TEST_USER_PASSWORD - Test user password
 *
 * For Clerk specifically:
 * CLERK_TESTING_TOKEN - From Clerk dashboard
 *
 * Add these to your CI/CD secrets or local .env.test file
 */
