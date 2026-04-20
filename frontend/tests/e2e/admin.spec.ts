import { test, expect } from '@playwright/test';
import { createBookingViaApi, deleteBookingViaApi, getUpcomingSlot } from './helpers/api.js';

test('страница типов событий показывает сидированные данные', async ({ page }) => {
	await page.goto('/admin/event-types');
	await expect(page.getByTestId('event-types-table')).toBeVisible();
	// 3 сидированных типа: intro-call, follow-up, deep-dive
	await expect(page.getByTestId('event-type-row')).toHaveCount(3);
	await expect(page.getByTestId('event-type-row').filter({ hasText: 'intro-call' })).toBeVisible();
	await expect(page.getByTestId('event-type-row').filter({ hasText: 'deep-dive' })).toBeVisible();
});

test('создание нового типа события отображается в таблице', async ({ page }) => {
	await page.goto('/admin/event-types');
	await expect(page.getByTestId('event-types-table')).toBeVisible();

	await page.getByTestId('form-event-type-id').fill('e2e-test-type');
	await page.getByTestId('form-event-type-name').fill('E2E Test Type');
	await page.getByTestId('form-event-type-desc').fill('Создан E2E-тестом');
	await page.getByTestId('form-event-type-duration').fill('45');

	await page.getByTestId('create-event-type-button').click();

	await expect(page.getByTestId('form-success-message')).toBeVisible();
	await expect(page.getByTestId('event-type-row').filter({ hasText: 'e2e-test-type' })).toBeVisible();
	// Форма очищается
	await expect(page.getByTestId('form-event-type-id')).toHaveValue('');
});

test('дубликат ID типа события показывает ошибку', async ({ page }) => {
	await page.goto('/admin/event-types');
	await expect(page.getByTestId('event-types-table')).toBeVisible();

	await page.getByTestId('form-event-type-id').fill('intro-call');
	await page.getByTestId('form-event-type-name').fill('Дубликат');
	await page.getByTestId('form-event-type-desc').fill('Должно упасть');
	await page.getByTestId('form-event-type-duration').fill('30');

	await page.getByTestId('create-event-type-button').click();

	await expect(page.getByTestId('form-error-message')).toBeVisible();
});

test('удаление брони через диалог подтверждения', async ({ page }) => {
	const { startTime } = await getUpcomingSlot('follow-up');
	const booking = await createBookingViaApi({
		eventTypeId: 'follow-up',
		startTime,
		guestName: 'E2E Delete Guest',
		guestEmail: 'e2e-delete@example.com',
	});

	await page.goto('/admin/bookings');

	const row = page.getByTestId('booking-row').filter({ hasText: 'E2E Delete Guest' });
	await expect(row).toBeVisible();

	await row.getByTestId('delete-booking-button').click();

	await expect(page.getByTestId('confirm-delete-dialog')).toBeVisible();
	await page.getByTestId('confirm-delete-action').click();

	// Строка исчезает после удаления
	await expect(page.getByTestId('booking-row').filter({ hasText: 'E2E Delete Guest' })).toHaveCount(0);

	// Дополнительная очистка на случай ошибки диалога
	await deleteBookingViaApi(booking.id).catch(() => {});
});
