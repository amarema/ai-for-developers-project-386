<script lang="ts">
	import { onMount } from 'svelte';
	import { listEventTypes } from '$lib/api.js';
	import type { EventType } from '$lib/types.js';
	import * as Card from '$lib/components/ui/card/index.js';
	import Badge from '$lib/components/ui/badge/badge.svelte';

	// Данные хоста из переменных окружения
	const hostName = import.meta.env.VITE_HOST_NAME ?? 'Host';
	const hostAvatarUrl = import.meta.env.VITE_HOST_AVATAR_URL ?? '';

	// Инициалы для аватара-заглушки
	const hostInitials = hostName
		.split(' ')
		.map((w: string) => w[0])
		.join('')
		.toUpperCase()
		.slice(0, 2);

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
	<title>Выберите тип события</title>
</svelte:head>

<div class="container mx-auto px-4 py-8 space-y-6">
	<!-- Профиль хоста -->
	<Card.Root>
		<Card.Content class="pt-6">
			<div class="flex items-center gap-3 mb-4">
				{#if hostAvatarUrl}
					<img src={hostAvatarUrl} alt={hostName} class="h-12 w-12 rounded-full object-cover" />
				{:else}
					<!-- Аватар с инициалами -->
					<div class="h-12 w-12 rounded-full bg-primary/20 flex items-center justify-center text-primary font-semibold text-sm">
						{hostInitials}
					</div>
				{/if}
				<div>
					<p class="font-semibold">{hostName}</p>
					<p class="text-sm text-muted-foreground">Host</p>
				</div>
			</div>
			<h1 class="text-2xl font-bold tracking-tight mb-1">Выберите тип события</h1>
			<p class="text-sm text-muted-foreground">Нажмите на карточку, чтобы открыть календарь и выбрать удобный слот.</p>
		</Card.Content>
	</Card.Root>

	<!-- Список типов событий -->
	{#if loading}
		<p class="text-muted-foreground">Загрузка...</p>
	{:else if error}
		<p class="text-destructive">Ошибка: {error}</p>
	{:else if eventTypes.length === 0}
		<p class="text-muted-foreground">Типы событий не найдены.</p>
	{:else}
		<div class="grid gap-4 sm:grid-cols-2">
			{#each eventTypes as et (et.id)}
				<a href="/event-types/{et.id}" class="block group">
					<Card.Root class="h-full transition-shadow group-hover:shadow-md cursor-pointer">
						<Card.Content class="pt-6">
							<div class="flex items-start justify-between gap-2 mb-2">
								<h2 class="text-lg font-bold">{et.name}</h2>
								<Badge variant="secondary" class="shrink-0 text-xs">{et.durationMinutes} мин</Badge>
							</div>
							<p class="text-sm text-muted-foreground">{et.description}</p>
						</Card.Content>
					</Card.Root>
				</a>
			{/each}
		</div>
	{/if}
</div>
