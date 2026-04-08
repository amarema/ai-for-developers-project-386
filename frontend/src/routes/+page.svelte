<script lang="ts">
	import { onMount } from 'svelte';
	import { listEventTypes } from '$lib/api.js';
	import type { EventType } from '$lib/types.js';
	import * as Card from '$lib/components/ui/card/index.js';
	import Badge from '$lib/components/ui/badge/badge.svelte';

	// Список типов событий, загружаемый при монтировании страницы
	let eventTypes = $state<EventType[]>([]);
	let error = $state<string | null>(null);
	let loading = $state(true);

	onMount(async () => {
		try {
			eventTypes = await listEventTypes();
		} catch (e) {
			error = (e as Error).message;
		} finally {
			loading = false;
		}
	});
</script>

<svelte:head>
	<title>Выберите тип встречи</title>
</svelte:head>

<div class="space-y-6">
	<div>
		<h1 class="text-3xl font-bold tracking-tight">Выберите тип встречи</h1>
		<p class="text-muted-foreground mt-2">Выберите удобный формат — и мы подберём свободное время.</p>
	</div>

	{#if loading}
		<p class="text-muted-foreground">Загрузка...</p>
	{:else if error}
		<p class="text-destructive">Ошибка: {error}</p>
	{:else if eventTypes.length === 0}
		<p class="text-muted-foreground">Типы событий не найдены.</p>
	{:else}
		<div class="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
			{#each eventTypes as et (et.id)}
				<a href="/event-types/{et.id}" class="block group">
					<Card.Root class="h-full transition-shadow group-hover:shadow-md">
						<Card.Header>
							<div class="flex items-start justify-between gap-2">
								<Card.Title class="text-xl">{et.name}</Card.Title>
								<Badge variant="secondary">{et.durationMinutes} мин</Badge>
							</div>
							<Card.Description>{et.description}</Card.Description>
						</Card.Header>
						<Card.Footer>
							<span class="text-sm font-medium text-primary">Выбрать время →</span>
						</Card.Footer>
					</Card.Root>
				</a>
			{/each}
		</div>
	{/if}
</div>
