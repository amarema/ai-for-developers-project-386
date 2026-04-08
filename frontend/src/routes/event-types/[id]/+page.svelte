<script lang="ts">
	import { onMount } from 'svelte';
	import { page } from '$app/stores';
	import { getSlots, createBooking, listEventTypes } from '$lib/api.js';
	import type { Slot, EventType } from '$lib/types.js';
	import { Calendar } from '$lib/components/ui/calendar/index.js';
	import Button from '$lib/components/ui/button/button.svelte';
	import Input from '$lib/components/ui/input/input.svelte';
	import Label from '$lib/components/ui/label/label.svelte';
	import Textarea from '$lib/components/ui/textarea/textarea.svelte';
	import Badge from '$lib/components/ui/badge/badge.svelte';
	import { goto } from '$app/navigation';
	import { CalendarDate, today, getLocalTimeZone } from '@internationalized/date';
	import type { DateValue } from '@internationalized/date';

	// Данные хоста из переменных окружения
	const hostName = import.meta.env.VITE_HOST_NAME ?? 'Host';
	const hostAvatarUrl = import.meta.env.VITE_HOST_AVATAR_URL ?? '';
	const hostInitials = hostName
		.split(' ')
		.map((w: string) => w[0])
		.join('')
		.toUpperCase()
		.slice(0, 2);

	// id типа события из URL (гарантированно присутствует в маршруте /event-types/[id])
	const id = $derived($page.params.id as string);

	let eventType = $state<EventType | null>(null);
	let slots = $state<Slot[]>([]);
	let loading = $state(true);
	let error = $state<string | null>(null);

	// Шаг 1 — выбор слота; Шаг 2 — форма бронирования
	let step = $state<1 | 2>(1);

	// Выбранная дата в формате CalendarDate
	let selectedDate = $state<DateValue | undefined>(undefined);
	// Выбранный слот
	let selectedSlot = $state<Slot | null>(null);

	// Поля формы бронирования
	let guestName = $state('');
	let guestEmail = $state('');
	let note = $state('');
	let submitting = $state(false);
	let formError = $state<string | null>(null);

	onMount(async () => {
		try {
			const [types, fetchedSlots] = await Promise.all([listEventTypes(), getSlots(id)]);
			eventType = types.find((t) => t.id === id) ?? null;
			slots = fetchedSlots;
		} catch (e) {
			error = (e as Error).message;
		} finally {
			loading = false;
		}
	});

	// Множество дат (YYYY-MM-DD) с доступными слотами
	const availableDays = $derived.by(() => {
		const days = new Set<string>();
		for (const slot of slots) {
			if (slot.available) {
				days.add(slot.startTime.slice(0, 10));
			}
		}
		return days;
	});

	// Слоты для выбранной даты
	const slotsForSelectedDate = $derived.by(() => {
		if (!selectedDate) return [];
		const dayStr = `${selectedDate.year}-${String(selectedDate.month).padStart(2, '0')}-${String(selectedDate.day).padStart(2, '0')}`;
		return slots.filter((s) => s.startTime.slice(0, 10) === dayStr);
	});

	// Дни без доступных слотов — disabled в календаре
	function isDateDisabled(date: DateValue): boolean {
		const dayStr = `${date.year}-${String(date.month).padStart(2, '0')}-${String(date.day).padStart(2, '0')}`;
		// Прошедшие дни и дни без слотов — недоступны
		const todayVal = today(getLocalTimeZone());
		if (date.compare(todayVal) < 0) return true;
		return !availableDays.has(dayStr);
	}

	// Сбрасываем слот при смене даты
	$effect(() => {
		selectedDate;
		selectedSlot = null;
	});

	function handleSlotSelect(slot: Slot) {
		if (!slot.available) return;
		selectedSlot = slot;
	}

	function formatTime(iso: string) {
		return new Date(iso).toLocaleTimeString('ru-RU', { hour: '2-digit', minute: '2-digit' });
	}

	function formatDate(date: DateValue) {
		const d = new Date(date.year, date.month - 1, date.day);
		return d.toLocaleDateString('ru-RU', { day: 'numeric', month: 'long' });
	}

	function formatDateFull(iso: string) {
		return new Date(iso).toLocaleString('ru-RU', {
			day: 'numeric',
			month: 'long',
			hour: '2-digit',
			minute: '2-digit'
		});
	}

	async function handleSubmit(e: SubmitEvent) {
		e.preventDefault();
		if (!selectedSlot) return;
		submitting = true;
		formError = null;
		try {
			const booking = await createBooking({
				eventTypeId: id,
				startTime: selectedSlot.startTime,
				guestName,
				guestEmail,
				note: note || undefined
			});
			// Передаём данные бронирования через query-параметры на страницу подтверждения
			goto(
				`/booking/success?id=${booking.id}&name=${encodeURIComponent(booking.eventTypeName)}&start=${encodeURIComponent(booking.startTime)}&end=${encodeURIComponent(booking.endTime)}`
			);
		} catch (e) {
			const err = e as Error & { status?: number; body?: { message?: string } };
			formError = err.body?.message ?? err.message;
		} finally {
			submitting = false;
		}
	}
</script>

<svelte:head>
	<title>{eventType?.name ?? 'Выбор времени'}</title>
</svelte:head>

{#if loading}
	<div class="container mx-auto px-4 py-8">
		<p class="text-muted-foreground">Загрузка...</p>
	</div>
{:else if error}
	<div class="container mx-auto px-4 py-8">
		<p class="text-destructive">Ошибка: {error}</p>
	</div>
{:else}
	<div class="container mx-auto px-4 py-8">
		<h1 class="text-2xl font-bold tracking-tight mb-6">{eventType?.name}</h1>

		{#if step === 1}
			<!-- Шаг 1: 3-колоночный лейаут — инфо | календарь | слоты -->
			<div class="grid grid-cols-1 lg:grid-cols-[260px_1fr_220px] gap-6">
				<!-- Левая панель: инфо о событии -->
				<div class="space-y-4">
					<div class="border rounded-xl p-4 space-y-3 bg-card">
						<!-- Аватар хоста -->
						<div class="flex items-center gap-2">
							{#if hostAvatarUrl}
								<img src={hostAvatarUrl} alt={hostName} class="h-8 w-8 rounded-full object-cover" />
							{:else}
								<div class="h-8 w-8 rounded-full bg-primary/20 flex items-center justify-center text-primary text-xs font-semibold">
									{hostInitials}
								</div>
							{/if}
							<span class="text-sm font-medium">{hostName}</span>
						</div>

						<!-- Название + длительность -->
						<div>
							<p class="font-semibold">{eventType?.name}</p>
							<Badge variant="secondary" class="mt-1 text-xs">{eventType?.durationMinutes} мин</Badge>
						</div>

						<!-- Описание -->
						{#if eventType?.description}
							<p class="text-sm text-muted-foreground">{eventType.description}</p>
						{/if}

						<!-- Выбранная дата/время -->
						<div class="pt-2 border-t space-y-1 text-sm">
							<p class="text-muted-foreground">
								Выбрана дата: <span class="text-foreground font-medium">
									{selectedDate ? formatDate(selectedDate) : 'Не выбрана'}
								</span>
							</p>
							<p class="text-muted-foreground">
								Выбрано время: <span class="text-foreground font-medium">
									{selectedSlot ? formatTime(selectedSlot.startTime) : 'Время не выбрано'}
								</span>
							</p>
						</div>
					</div>
				</div>

				<!-- Центр: календарь -->
				<div class="border rounded-xl p-4 bg-card">
					<h2 class="text-sm font-semibold mb-3 text-muted-foreground uppercase tracking-wide">Календарь</h2>
					<Calendar
						bind:value={selectedDate}
						isDateDisabled={isDateDisabled}
						locale="ru-RU"
						class="mx-auto"
					/>
				</div>

				<!-- Правая панель: слоты для выбранной даты -->
				<div class="border rounded-xl p-4 bg-card">
					<h2 class="text-sm font-semibold mb-3 text-muted-foreground uppercase tracking-wide">Статус слотов</h2>

					{#if !selectedDate}
						<p class="text-sm text-muted-foreground">Выберите дату в календаре</p>
					{:else if slotsForSelectedDate.length === 0}
						<p class="text-sm text-muted-foreground">Нет слотов на эту дату</p>
					{:else}
						<div class="space-y-1.5">
							{#each slotsForSelectedDate as slot (slot.startTime)}
								<button
									type="button"
									disabled={!slot.available}
									onclick={() => handleSlotSelect(slot)}
									class="w-full flex items-center justify-between px-3 py-2 rounded-lg border text-sm transition-colors
										{slot.available
											? selectedSlot?.startTime === slot.startTime
												? 'bg-primary text-primary-foreground border-primary'
												: 'hover:bg-accent border-border'
											: 'opacity-40 cursor-not-allowed border-border bg-muted text-muted-foreground'}"
								>
									<span class="font-medium">{formatTime(slot.startTime)} – {formatTime(slot.endTime)}</span>
									<span class="text-xs {slot.available ? (selectedSlot?.startTime === slot.startTime ? 'opacity-80' : 'text-muted-foreground') : ''}">
										{slot.available ? 'Свободно' : 'Занято'}
									</span>
								</button>
							{/each}
						</div>
					{/if}
				</div>
			</div>

			<!-- Кнопки внизу -->
			<div class="flex justify-between mt-6">
				<Button variant="outline" href="/book">Назад</Button>
				<Button
					disabled={!selectedSlot}
					onclick={() => (step = 2)}
				>
					Продолжить
				</Button>
			</div>

		{:else}
			<!-- Шаг 2: форма бронирования -->
			<div class="max-w-md space-y-6">
				<!-- Выбранное время -->
				<div class="border rounded-xl p-4 bg-muted/30 text-sm space-y-1">
					<p class="font-medium">{eventType?.name}</p>
					{#if selectedSlot}
						<p class="text-muted-foreground">
							{formatDateFull(selectedSlot.startTime)} — {formatTime(selectedSlot.endTime)}
						</p>
					{/if}
				</div>

				<form onsubmit={handleSubmit} class="space-y-4">
					<div class="space-y-1.5">
						<Label for="name">Имя</Label>
						<Input id="name" bind:value={guestName} required placeholder="Иван Иванов" />
					</div>

					<div class="space-y-1.5">
						<Label for="email">Email</Label>
						<Input id="email" type="email" bind:value={guestEmail} required placeholder="ivan@example.com" />
					</div>

					<div class="space-y-1.5">
						<Label for="note">Комментарий (необязательно)</Label>
						<Textarea id="note" bind:value={note} placeholder="О чём хотите поговорить?" rows={3} />
					</div>

					{#if formError}
						<p class="text-sm text-destructive">{formError}</p>
					{/if}

					<div class="flex justify-between pt-2">
						<Button type="button" variant="outline" onclick={() => (step = 1)}>Назад</Button>
						<Button type="submit" disabled={submitting}>
							{submitting ? 'Отправляем...' : 'Забронировать'}
						</Button>
					</div>
				</form>
			</div>
		{/if}
	</div>
{/if}
