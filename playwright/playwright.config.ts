import { defineConfig, devices } from '@playwright/test';

/**
 * Playwright configuration for Brief Wiggum
 *
 * Customize baseURL and authentication for your project.
 * See docs on setting up auth: https://playwright.dev/docs/auth
 */
export default defineConfig({
  testDir: './e2e',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: 'html',

  use: {
    // Update this to your app's URL
    baseURL: process.env.BASE_URL || 'http://localhost:3000',
    trace: 'on-first-retry',
  },

  projects: [
    // Setup project for authentication
    // Customize auth.setup.ts for your auth provider
    { name: 'setup', testMatch: /.*\.setup\.ts/ },

    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
      dependencies: ['setup'],
    },

    // Add more browsers as needed
    // {
    //   name: 'firefox',
    //   use: { ...devices['Desktop Firefox'] },
    //   dependencies: ['setup'],
    // },
    // {
    //   name: 'webkit',
    //   use: { ...devices['Desktop Safari'] },
    //   dependencies: ['setup'],
    // },
  ],

  // Configure web server to start before tests
  webServer: {
    command: 'pnpm dev',  // or npm run dev, yarn dev
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
  },
});
