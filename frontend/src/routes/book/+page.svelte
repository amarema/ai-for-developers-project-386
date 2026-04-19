<script lang="ts">
	import { onMount } from 'svelte';
	import { listEventTypes } from '$lib/api.js';
	import type { EventType } from '$lib/types.js';
	import { Clock, ChevronRight, Zap } from '@lucide/svelte';

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

<div class="container mx-auto px-4 py-10 space-y-8">
	<!-- Профиль хоста -->
	<div class="glass rounded-2xl p-6 animate-fade-in-up">
		<div class="flex items-center gap-4 mb-4">
			{#if hostAvatarUrl}
				<img src={hostAvatarUrl} alt={hostName} class="h-14 w-14 rounded-full object-cover ring-2 ring-primary/30 shadow-md" />
			{:else}
				<div class="h-14 w-14 rounded-full bg-gradient-to-br from-primary to-primary/60 flex items-center justify-center text-primary-foreground font-bold text-lg shadow-md">
					{hostInitials}
				</div>
			{/if}
			<div>
				<p class="font-bold text-lg">{hostName}</p>
				<p class="text-sm text-muted-foreground flex items-center gap-1">
					<Zap class="h-3 w-3 text-primary" />
					Быстрая запись
				</p>
			</div>
		</div>
		<h1 class="text-2xl sm:text-3xl font-black tracking-tight mb-1">Выберите тип события</h1>
		<p class="text-sm text-muted-foreground">Нажмите на карточку, чтобы открыть календарь и выбрать удобный слот.</p>
	</div>

	<!-- Список типов событий -->
	{#if loading}
		<div class="flex items-center gap-3 text-muted-foreground py-4">
			<span class="loading-spinner"></span>
			<span>Загрузка...</span>
		</div>
	{:else if error}
		<p class="text-destructive">Ошибка: {error}</p>
	{:else if eventTypes.length === 0}
		<p class="text-muted-foreground">Типы событий не найдены.</p>
	{:else}
		<div class="grid gap-4 sm:grid-cols-2">
			{#each eventTypes as et, i (et.id)}
				<a
					href="/event-types/{et.id}"
					class="block group animate-fade-in-up"
					style="animation-delay: {i * 0.08}s"
				>
					<div class="glow-card h-full rounded-2xl border border-border bg-card p-6 cursor-pointer group-hover:scale-[1.02] group-hover:-translate-y-1 group-hover:border-primary/30">
						<!-- Верхняя полоска-акцент -->
						<div class="h-1 w-12 rounded-full bg-gradient-to-r from-primary to-primary/40 mb-5 group-hover:w-full transition-all duration-500"></div>
						<div class="flex items-start justify-between gap-2 mb-3">
							<h2 class="text-xl font-bold">{et.name}</h2>
							<ChevronRight class="h-5 w-5 text-muted-foreground shrink-0 mt-0.5 group-hover:text-primary group-hover:translate-x-1 transition-all" />
						</div>
						<p class="text-sm text-muted-foreground mb-4 leading-relaxed">{et.description}</p>
						<div class="flex items-center gap-1.5 text-xs font-medium text-primary">
							<Clock class="h-3.5 w-3.5" />
							<span>{et.durationMinutes} минут</span>
						</div>
					</div>
				</a>
			{/each}
		</div>
	{/if}
</div>
