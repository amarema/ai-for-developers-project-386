<script lang="ts">
	import { onMount } from 'svelte';
	import { adminListBookings, adminDeleteBooking } from '$lib/api.js';
	import type { Booking } from '$lib/types.js';
	import * as Table from '$lib/components/ui/table/index.js';
	import * as AlertDialog from '$lib/components/ui/alert-dialog/index.js';
	import Badge from '$lib/components/ui/badge/badge.svelte';
	import Button from '$lib/components/ui/button/button.svelte';

	let bookings = $state<Booking[]>([]);
	let loading = $state(true);
	let error = $state<string | null>(null);
	let deletingId = $state<string | null>(null);

	// Бронирование, выбранное для удаления (открывает диалог подтверждения)
	let pendingBooking = $state<Booking | null>(null);
	let dialogOpen = $state(false);

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

	async function confirmDelete() {
		if (!pendingBooking) return;
		const id = pendingBooking.id;
		pendingBooking = null;
		dialogOpen = false;
		deletingId = id;
		try {
			await adminDeleteBooking(id);
			bookings = bookings.filter((b) => b.id !== id);
		} catch (e) {
			error = (e as Error).message;
		} finally {
			deletingId = null;
		}
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
					<Table.Head></Table.Head>
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
						<Table.Cell class="text-right">
							<Button
								variant="destructive"
								size="sm"
								disabled={deletingId === b.id}
								onclick={() => { pendingBooking = b; dialogOpen = true; }}
							>
								{deletingId === b.id ? 'Удаление...' : 'Удалить'}
							</Button>
						</Table.Cell>
					</Table.Row>
				{/each}
			</Table.Body>
		</Table.Root>
	{/if}
</div>

<!-- Диалог подтверждения удаления -->
<AlertDialog.Root bind:open={dialogOpen} onOpenChange={(open) => { if (!open) pendingBooking = null; }}>
	<AlertDialog.Portal>
		<AlertDialog.Overlay />
		<AlertDialog.Content>
			<AlertDialog.Header>
				<AlertDialog.Title>Удалить бронирование?</AlertDialog.Title>
				<AlertDialog.Description>
					{#if pendingBooking}
						<span class="block space-y-1">
							<span class="block"><strong>Гость:</strong> {pendingBooking.guestName} ({pendingBooking.guestEmail})</span>
							<span class="block"><strong>Тип события:</strong> {pendingBooking.eventTypeName}</span>
							<span class="block"><strong>Время:</strong> {formatDateTime(pendingBooking.startTime)} — {formatDateTime(pendingBooking.endTime)}</span>
							{#if pendingBooking.note}
								<span class="block"><strong>Заметка:</strong> {pendingBooking.note}</span>
							{/if}
						</span>
					{/if}
				</AlertDialog.Description>
			</AlertDialog.Header>
			<AlertDialog.Footer>
				<AlertDialog.Cancel>Отмена</AlertDialog.Cancel>
				<AlertDialog.Action onclick={confirmDelete} class="bg-destructive text-destructive-foreground hover:bg-destructive/90">
					Удалить
				</AlertDialog.Action>
			</AlertDialog.Footer>
		</AlertDialog.Content>
	</AlertDialog.Portal>
</AlertDialog.Root>
