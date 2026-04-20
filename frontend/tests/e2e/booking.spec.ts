import { test, expect } from '@playwright/test';
import { createBookingViaApi, deleteBookingViaApi, getUpcomingSlot } from './helpers/api.js';

// Список созданных броней для очистки после каждого теста
const createdBookingIds: string[] = [];

test.afterEach(async () => {
	for (const id of createdBookingIds.splice(0)) {
		await deleteBookingViaApi(id).catch(() => {});
	}
});

test('happy path: гость бронирует intro-call от начала до конца', async ({ page }) => {
	// Шаг 1: страница /book показывает карточки
	await page.goto('/book');
	await expect(page.getByTestId('event-type-card').first()).toBeVisible();

	// Клик на карточку intro-call по data-id атрибуту
	await page.locator('[data-testid="event-type-card"][data-id="intro-call"]').click();
	await expect(page).toHaveURL(/\/event-types\/intro-call/);

	// Ждём загрузки календаря
	await expect(page.getByTestId('calendar-root')).toBeVisible();

	// Выбираем первый доступный день — bits-ui Calendar рендерит кнопки с data-value и data-disabled
	const enabledDay = page.locator('[role="button"][data-value]:not([data-disabled])').first();
	await expect(enabledDay).toBeVisible();
	await enabledDay.click();

	// Ждём появления слотов
	await expect(page.getByTestId('slot-button').first()).toBeVisible({ timeout: 10_000 });
	await page.getByTestId('slot-button').first().click();

	// Кнопка "Продолжить" становится активной
	await expect(page.getByTestId('continue-button')).not.toBeDisabled();
	await page.getByTestId('continue-button').click();

	// Шаг 2: заполняем форму
	await page.getByLabel('Имя').fill('Тест Пользователь');
	await page.getByLabel('Email').fill('e2e@example.com');
	await page.getByLabel('Комментарий').fill('E2E тестовое бронирование');

	// Перехватываем ответ POST /bookings для получения ID
	const bookingResponsePromise = page.waitForResponse(
		(resp) => resp.url().includes('/bookings') && resp.request().method() === 'POST'
	);

	await page.getByTestId('submit-booking-button').click();

	const bookingResponse = await bookingResponsePromise;
	const booking = await bookingResponse.json();
	createdBookingIds.push(booking.id);

	// Шаг 3: страница подтверждения
	await expect(page).toHaveURL(/\/booking\/success/);
	await expect(page.getByTestId('success-heading')).toBeVisible();
	await expect(page.getByTestId('success-event-name')).not.toBeEmpty();
	await expect(page.getByTestId('booking-id-display')).toBeVisible();
});

test('занятый слот не отображается в списке', async ({ page }) => {
	// Забронируем слот через API
	const { startTime } = await getUpcomingSlot('intro-call');
	const existing = await createBookingViaApi({
		eventTypeId: 'intro-call',
		startTime,
		guestName: 'Занятый Гость',
		guestEmail: 'occupied@example.com',
	});
	createdBookingIds.push(existing.id);

	await page.goto('/event-types/intro-call');
	await expect(page.getByTestId('calendar-root')).toBeVisible();

	// Выбираем дату занятого слота — указываем role=button чтобы избежать strict-конфликта с <td>
	const targetDate = startTime.split('T')[0]; // YYYY-MM-DD
	const dayButton = page.locator(`[role="button"][data-value="${targetDate}"]`);
	await expect(dayButton).toBeVisible();
	await dayButton.click();

	// Ждём загрузки слотов (или сообщения "нет слотов")
	await page.waitForTimeout(1000);

	// Занятый слот не должен появиться в списке доступных
	const occupiedTime = new Date(startTime).toLocaleTimeString('ru-RU', {
		hour: '2-digit',
		minute: '2-digit',
	});
	// Если слоты вообще есть — занятого среди них нет
	const slotCount = await page.getByTestId('slot-button').count();
	if (slotCount > 0) {
		await expect(
			page.getByTestId('slot-button').filter({ hasText: occupiedTime })
		).toHaveCount(0);
	}
});

test('валидация формы: пустая форма не позволяет отправить запрос', async ({ page }) => {
	await page.goto('/event-types/intro-call');
	await expect(page.getByTestId('calendar-root')).toBeVisible();

	// Выбираем дату и слот
	const enabledDay = page.locator('[role="button"][data-value]:not([data-disabled])').first();
	await enabledDay.click();
	await expect(page.getByTestId('slot-button').first()).toBeVisible({ timeout: 10_000 });
	await page.getByTestId('slot-button').first().click();

	await page.getByTestId('continue-button').click();

	// Пытаемся отправить пустую форму
	await page.getByTestId('submit-booking-button').click();

	// Страница не меняется — HTML5-валидация блокирует отправку
	await expect(page).toHaveURL(/\/event-types\/intro-call/);
});
