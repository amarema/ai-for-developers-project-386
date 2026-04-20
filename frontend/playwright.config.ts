import { defineConfig, devices } from '@playwright/test';
import path from 'path';

const ROOT = path.resolve(import.meta.dirname, '..');

export default defineConfig({
	testDir: './tests/e2e',
	fullyParallel: false,
	forbidOnly: !!process.env.CI,
	retries: process.env.CI ? 1 : 0,
	workers: 1,
	reporter: [['html', { outputFolder: 'playwright-report', open: 'never' }], ['list']],
	use: {
		baseURL: 'http://localhost:5173',
		trace: 'on-first-retry',
		screenshot: 'only-on-failure',
		video: 'retain-on-failure',
	},
	webServer: [
		{
			// Go-бэкенд стартует первым — фронт зависит от него
			command: `cd ${ROOT}/backend && go run ./main.go`,
			port: 8080,
			timeout: 60_000,
			reuseExistingServer: !process.env.CI,
		},
		{
			command: `npm --prefix ${ROOT}/frontend run dev -- --port 5173`,
			port: 5173,
			timeout: 30_000,
			reuseExistingServer: !process.env.CI,
			env: { VITE_API_BASE_URL: 'http://localhost:8080' },
		},
	],
	projects: [
		{
			name: 'chromium',
			use: { ...devices['Desktop Chrome'] },
		},
	],
});
