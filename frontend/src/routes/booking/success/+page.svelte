<script lang="ts">
	import { page } from '$app/stores';
	import Button from '$lib/components/ui/button/button.svelte';
	import * as Card from '$lib/components/ui/card/index.js';

	// Данные бронирования из query-параметров
	const bookingId = $derived($page.url.searchParams.get('id') ?? '');
	const eventName = $derived($page.url.searchParams.get('name') ?? '');
	const startTime = $derived($page.url.searchParams.get('start') ?? '');
	const endTime = $derived($page.url.searchParams.get('end') ?? '');

	function formatDateTime(iso: string) {
		if (!iso) return '';
		return new Date(iso).toLocaleString('ru-RU', {
			weekday: 'long',
			day: 'numeric',
			month: 'long',
			hour: '2-digit',
			minute: '2-digit'
		});
	}
</script>

<svelte:head>
	<title>Бронирование подтверждено</title>
</svelte:head>

<div class="container mx-auto px-4 py-8">
<div class="max-w-md mx-auto space-y-6 text-center">
	<div class="text-5xl">✓</div>
	<div>
		<h1 class="text-2xl font-bold tracking-tight">Бронирование подтверждено!</h1>
		<p class="text-muted-foreground mt-1">Мы ждём вас в назначенное время.</p>
	</div>

	<Card.Root class="text-left">
		<Card.Header>
			<Card.Title>{eventName}</Card.Title>
		</Card.Header>
		<Card.Content class="space-y-2 text-sm">
			<div>
				<span class="text-muted-foreground">Начало: </span>
				<span class="font-medium">{formatDateTime(startTime)}</span>
			</div>
			<div>
				<span class="text-muted-foreground">Окончание: </span>
				<span class="font-medium">{formatDateTime(endTime)}</span>
			</div>
			{#if bookingId}
				<div>
					<span class="text-muted-foreground">ID: </span>
					<code class="text-xs">{bookingId}</code>
				</div>
			{/if}
		</Card.Content>
	</Card.Root>

	<Button href="/" variant="outline">Вернуться на главную</Button>
</div>
</div>
