<script lang="ts">
	import { onMount } from 'svelte';
	import { page } from '$app/stores';
	import { getAvailableDays, getSlots, createBooking, listEventTypes } from '$lib/api.js';
	import type { Slot, EventType } from '$lib/types.js';
	import { Calendar } from '$lib/components/ui/calendar/index.js';
	import Button from '$lib/components/ui/button/button.svelte';
	import Input from '$lib/components/ui/input/input.svelte';
	import Label from '$lib/components/ui/label/label.svelte';
	import Textarea from '$lib/components/ui/textarea/textarea.svelte';

	import { goto } from '$app/navigation';
	import { today, getLocalTimeZone } from '@internationalized/date';
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
	let availableDays = $state<Set<string>>(new Set());
	let slotsForSelectedDate = $state<Slot[]>([]);
	let loadingSlots = $state(false);
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
			const [types, days] = await Promise.all([listEventTypes(), getAvailableDays(id)]);
			eventType = types.find((t) => t.id === id) ?? null;
			availableDays = new Set(days);
		} catch (e) {
			error = (e as Error).message;
		} finally {
			loading = false;
		}
	});


	// Дни без доступных слотов — disabled в календаре
	function isDateDisabled(date: DateValue): boolean {
		const dayStr = `${date.year}-${String(date.month).padStart(2, '0')}-${String(date.day).padStart(2, '0')}`;
		const todayVal = today(getLocalTimeZone());
		if (date.compare(todayVal) < 0) return true;
		return !availableDays.has(dayStr);
	}

	// При смене даты — сбрасываем слот и загружаем слоты для нового дня
	$effect(() => {
		if (!selectedDate) return;
		const dayStr = `${selectedDate.year}-${String(selectedDate.month).padStart(2, '0')}-${String(selectedDate.day).padStart(2, '0')}`;
		selectedSlot = null;
		loadingSlots = true;
		getSlots(id, dayStr)
			.then((s) => { slotsForSelectedDate = s; })
			.finally(() => { loadingSlots = false; });
	});

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
		<div class="flex items-center gap-3 text-muted-foreground">
			<span class="loading-spinner"></span>
			<span>Загрузка...</span>
		</div>
	</div>
{:else if error}
	<div class="container mx-auto px-4 py-8">
		<p class="text-destructive">Ошибка: {error}</p>
	</div>
{:else}
	<div class="container mx-auto max-w-4xl px-4 py-8">
		<!-- Заголовок + шаги -->
		<div class="mb-6 animate-fade-in-up">
			<h1 class="text-2xl sm:text-3xl font-black tracking-tight mb-3">{eventType?.name}</h1>
			<!-- Индикатор шагов -->
			<div class="flex items-center gap-3 text-sm">
				<span class="flex items-center gap-2 {step === 1 ? 'text-primary font-semibold' : 'text-muted-foreground'}">
					<span class="flex h-6 w-6 items-center justify-center rounded-full text-xs font-bold transition-all
						{step === 1 ? 'bg-primary text-primary-foreground shadow-sm' : 'bg-muted text-muted-foreground'}">1</span>
					Выбор времени
				</span>
				<span class="flex-1 h-px bg-border max-w-8"></span>
				<span class="flex items-center gap-2 {step === 2 ? 'text-primary font-semibold' : 'text-muted-foreground'}">
					<span class="flex h-6 w-6 items-center justify-center rounded-full text-xs font-bold transition-all
						{step === 2 ? 'bg-primary text-primary-foreground shadow-sm' : 'bg-muted text-muted-foreground'}">2</span>
					Контактные данные
				</span>
			</div>
		</div>

		{#if step === 1}
			<!-- Шаг 1: адаптивный лейаут — инфо | календарь | слоты -->
			<div class="grid grid-cols-1 md:grid-cols-[200px_1fr] lg:grid-cols-[260px_1fr_220px] gap-5">
				<!-- Левая панель: инфо о событии -->
				<div class="space-y-4">
					<div class="glass rounded-2xl p-5 space-y-4">
						<!-- Аватар хоста -->
						<div class="flex items-center gap-2.5">
							{#if hostAvatarUrl}
								<img src={hostAvatarUrl} alt={hostName} class="h-9 w-9 rounded-full object-cover ring-2 ring-primary/20" />
							{:else}
								<div class="h-9 w-9 rounded-full bg-gradient-to-br from-primary to-primary/60 flex items-center justify-center text-primary-foreground text-xs font-bold">
									{hostInitials}
								</div>
							{/if}
							<span class="text-sm font-semibold">{hostName}</span>
						</div>

						<!-- Название + длительность -->
						<div>
							<p class="font-bold">{eventType?.name}</p>
							<div class="mt-1.5 inline-flex items-center gap-1 rounded-full bg-primary/10 px-2.5 py-0.5 text-xs font-medium text-primary">
								<svg class="h-3 w-3" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
									<circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/>
								</svg>
								{eventType?.durationMinutes} мин
							</div>
						</div>

						<!-- Описание -->
						{#if eventType?.description}
							<p class="text-sm text-muted-foreground leading-relaxed">{eventType.description}</p>
						{/if}

						<!-- Выбранная дата/время -->
						<div class="pt-3 border-t border-border/50 space-y-2 text-sm">
							<div class="flex justify-between">
								<span class="text-muted-foreground">Дата</span>
								<span class="font-medium">{selectedDate ? formatDate(selectedDate) : '—'}</span>
							</div>
							<div class="flex justify-between">
								<span class="text-muted-foreground">Время</span>
								<span class="font-medium {selectedSlot ? 'text-primary' : ''}">{selectedSlot ? formatTime(selectedSlot.startTime) : '—'}</span>
							</div>
						</div>
					</div>
				</div>

				<!-- Центр: календарь -->
				<div class="glass rounded-2xl p-5">
					<h2 class="text-xs font-bold mb-4 text-muted-foreground uppercase tracking-widest">Выберите дату</h2>
					<Calendar
						bind:value={selectedDate}
						isDateDisabled={isDateDisabled}
						locale="ru-RU"
						class="mx-auto"
					/>
				</div>

				<!-- Правая панель: слоты для выбранной даты -->
				<div class="glass rounded-2xl p-5 md:col-span-2 lg:col-span-1">
					<h2 class="text-xs font-bold mb-4 text-muted-foreground uppercase tracking-widest">Доступное время</h2>

					{#if !selectedDate}
						<p class="text-sm text-muted-foreground">Выберите дату в календаре</p>
					{:else if loadingSlots}
						<div class="flex items-center gap-2 text-muted-foreground text-sm">
							<span class="loading-spinner"></span>
							<span>Загрузка...</span>
						</div>
					{:else if slotsForSelectedDate.length === 0}
						<p class="text-sm text-muted-foreground">Нет слотов на эту дату</p>
					{:else}
						<div class="space-y-2">
							{#each slotsForSelectedDate as slot (slot.startTime)}
								<button
									type="button"
									onclick={() => { selectedSlot = slot; }}
									class="w-full flex items-center gap-2.5 px-3 py-2.5 rounded-xl border text-sm font-medium transition-all
										{selectedSlot?.startTime === slot.startTime
											? 'bg-primary text-primary-foreground border-primary shadow-sm'
											: 'hover:bg-green-50 dark:hover:bg-green-950/40 hover:border-green-300 dark:hover:border-green-800 border-border'}"
								>
									{#if selectedSlot?.startTime === slot.startTime}
										<span class="h-2 w-2 rounded-full bg-primary-foreground shrink-0"></span>
									{:else}
										<span class="h-2 w-2 rounded-full bg-green-500 pulse-dot shrink-0"></span>
									{/if}
									<span class="whitespace-nowrap">{formatTime(slot.startTime)} – {formatTime(slot.endTime)}</span>
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
					class={selectedSlot ? 'btn-shimmer border-0' : ''}
				>
					Продолжить →
				</Button>
			</div>

		{:else}
			<!-- Шаг 2: форма бронирования -->
			<div class="max-w-md space-y-5">
				<!-- Выбранное время -->
				<div class="glass rounded-2xl p-5 animate-fade-in-up">
					<p class="text-xs font-bold uppercase tracking-widest text-primary mb-2">Выбранное время</p>
					<p class="font-bold text-lg">{eventType?.name}</p>
					{#if selectedSlot}
						<p class="text-muted-foreground text-sm mt-0.5">
							{formatDateFull(selectedSlot.startTime)} — {formatTime(selectedSlot.endTime)}
						</p>
					{/if}
				</div>

				<form onsubmit={handleSubmit} class="glass rounded-2xl p-5 space-y-4 animate-fade-in-up animate-fade-in-up-delay-1">
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

					<div class="flex justify-between pt-1">
						<Button type="button" variant="outline" onclick={() => (step = 1)}>Назад</Button>
						<Button type="submit" disabled={submitting} class={!submitting ? 'btn-shimmer border-0' : ''}>
							{submitting ? 'Отправляем...' : 'Забронировать →'}
						</Button>
					</div>
				</form>
			</div>
		{/if}
	</div>
{/if}
