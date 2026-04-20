import { test, expect } from '@playwright/test';

test('лендинг загружается и CTA-кнопка ведёт на /book', async ({ page }) => {
	await page.goto('/');
	await expect(page.getByTestId('hero-cta-button')).toBeVisible();
	await page.getByTestId('hero-cta-button').click();
	await expect(page).toHaveURL('/book');
});

test('ссылка в шапке "Записаться" ведёт на /book', async ({ page }) => {
	await page.goto('/');
	await page.getByTestId('nav-book-link').click();
	await expect(page).toHaveURL('/book');
});

test('ссылка в шапке "Админка" ведёт на /admin/event-types', async ({ page }) => {
	await page.goto('/');
	await page.getByTestId('nav-admin-link').click();
	await expect(page).toHaveURL('/admin/event-types');
});

test('/book показывает карточки типов событий', async ({ page }) => {
	await page.goto('/book');
	// Ждём загрузки данных
	await expect(page.getByTestId('event-type-card').first()).toBeVisible();
	// Бэкенд сидирован минимум 3 типами событий
	const count = await page.getByTestId('event-type-card').count();
	expect(count).toBeGreaterThanOrEqual(3);
});
