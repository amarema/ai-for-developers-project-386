<script lang="ts">
	import { onMount } from 'svelte';
	import { page } from '$app/stores';
	import { getSlots, createBooking, listEventTypes } from '$lib/api.js';
	import type { Slot, EventType } from '$lib/types.js';
	import Button from '$lib/components/ui/button/button.svelte';
	import Input from '$lib/components/ui/input/input.svelte';
	import Label from '$lib/components/ui/label/label.svelte';
	import Textarea from '$lib/components/ui/textarea/textarea.svelte';
	import Badge from '$lib/components/ui/badge/badge.svelte';
	import { goto } from '$app/navigation';

	// id типа события из URL
	const id = $derived($page.params.id);

	let eventType = $state<EventType | null>(null);
	let slots = $state<Slot[]>([]);
	let loading = $state(true);
	let error = $state<string | null>(null);

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

	// Группировка слотов по дате для удобного отображения
	const slotsByDay = $derived(() => {
		const map = new Map<string, Slot[]>();
		for (const slot of slots) {
			const day = slot.startTime.slice(0, 10); // YYYY-MM-DD
			if (!map.has(day)) map.set(day, []);
			map.get(day)!.push(slot);
		}
		return [...map.entries()].sort(([a], [b]) => a.localeCompare(b));
	});

	function formatTime(iso: string) {
		return new Date(iso).toLocaleTimeString('ru-RU', { hour: '2-digit', minute: '2-digit' });
	}

	function formatDate(dateStr: string) {
		return new Date(dateStr).toLocaleDateString('ru-RU', {
			weekday: 'long',
			day: 'numeric',
			month: 'long'
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
			// Передаём данные бронирования через query-параметры для страницы подтверждения
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

<div class="space-y-8">
	{#if loading}
		<p class="text-muted-foreground">Загрузка...</p>
	{:else if error}
		<p class="text-destructive">Ошибка: {error}</p>
	{:else}
		<div>
			<h1 class="text-3xl font-bold tracking-tight">{eventType?.name}</h1>
			<p class="text-muted-foreground mt-1">{eventType?.description}</p>
		</div>

		<!-- Выбор слота -->
		<div class="space-y-4">
			<h2 class="text-xl font-semibold">Выберите время</h2>
			{#if slotsByDay().length === 0}
				<p class="text-muted-foreground">Свободных слотов нет.</p>
			{:else}
				{#each slotsByDay() as [day, daySlots] (day)}
					<div>
						<p class="text-sm font-medium capitalize text-muted-foreground mb-2">
							{formatDate(day)}
						</p>
						<div class="flex flex-wrap gap-2">
							{#each daySlots as slot (slot.startTime)}
								<button
									type="button"
									disabled={!slot.available}
									onclick={() => (selectedSlot = slot)}
									class="px-3 py-1.5 rounded-md border text-sm font-medium transition-colors
										{slot.available
										? selectedSlot?.startTime === slot.startTime
											? 'bg-primary text-primary-foreground border-primary'
											: 'hover:bg-accent hover:text-accent-foreground border-border'
										: 'opacity-40 cursor-not-allowed border-border bg-muted text-muted-foreground'}"
								>
									{formatTime(slot.startTime)}
								</button>
							{/each}
						</div>
					</div>
				{/each}
			{/if}
		</div>

		<!-- Форма бронирования (показывается после выбора слота) -->
		{#if selectedSlot}
			<form onsubmit={handleSubmit} class="space-y-4 max-w-md border rounded-lg p-6">
				<h2 class="text-xl font-semibold">Ваши данные</h2>
				<p class="text-sm text-muted-foreground">
					Выбрано: {formatDate(selectedSlot.startTime.slice(0, 10))}
					{formatTime(selectedSlot.startTime)} — {formatTime(selectedSlot.endTime)}
				</p>

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

				<Button type="submit" disabled={submitting} class="w-full">
					{submitting ? 'Отправляем...' : 'Забронировать'}
				</Button>
			</form>
		{/if}
	{/if}
</div>
