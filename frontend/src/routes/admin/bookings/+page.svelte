<script lang="ts">
	import { onMount } from 'svelte';
	import { adminListBookings } from '$lib/api.js';
	import type { Booking } from '$lib/types.js';
	import * as Table from '$lib/components/ui/table/index.js';
	import Badge from '$lib/components/ui/badge/badge.svelte';

	let bookings = $state<Booking[]>([]);
	let loading = $state(true);
	let error = $state<string | null>(null);

	onMount(async () => {
		try {
			bookings = await adminListBookings();
		} catch (e) {
			error = (e as Error).message;
		} finally {
			loading = false;
		}
	});

	function formatDateTime(iso: string) {
		return new Date(iso).toLocaleString('ru-RU', {
			day: 'numeric',
			month: 'short',
			hour: '2-digit',
			minute: '2-digit'
		});
	}
</script>

<svelte:head>
	<title>Бронирования — Админ</title>
</svelte:head>

<div class="space-y-6">
	<h1 class="text-2xl font-bold tracking-tight">Предстоящие бронирования</h1>

	{#if loading}
		<p class="text-muted-foreground">Загрузка...</p>
	{:else if error}
		<p class="text-destructive">Ошибка: {error}</p>
	{:else if bookings.length === 0}
		<p class="text-muted-foreground">Предстоящих бронирований нет.</p>
	{:else}
		<Table.Root>
			<Table.Header>
				<Table.Row>
					<Table.Head>Гость</Table.Head>
					<Table.Head>Email</Table.Head>
					<Table.Head>Тип события</Table.Head>
					<Table.Head>Начало</Table.Head>
					<Table.Head>Окончание</Table.Head>
					<Table.Head>Заметка</Table.Head>
				</Table.Row>
			</Table.Header>
			<Table.Body>
				{#each bookings as b (b.id)}
					<Table.Row>
						<Table.Cell class="font-medium">{b.guestName}</Table.Cell>
						<Table.Cell class="text-muted-foreground">{b.guestEmail}</Table.Cell>
						<Table.Cell>
							<Badge variant="secondary">{b.eventTypeName}</Badge>
						</Table.Cell>
						<Table.Cell>{formatDateTime(b.startTime)}</Table.Cell>
						<Table.Cell>{formatDateTime(b.endTime)}</Table.Cell>
						<Table.Cell class="text-muted-foreground max-w-xs truncate">
							{b.note ?? '—'}
						</Table.Cell>
					</Table.Row>
				{/each}
			</Table.Body>
		</Table.Root>
	{/if}
</div>
