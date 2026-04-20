<script lang="ts">
	import { page } from '$app/stores';
	import { onMount } from 'svelte';
	import Button from '$lib/components/ui/button/button.svelte';
	import confetti from 'canvas-confetti';

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

	onMount(() => {
		// Запускаем конфетти после монтирования страницы
		const duration = 2800;
		const end = Date.now() + duration;

		const frame = () => {
			confetti({
				particleCount: 3,
				angle: 60,
				spread: 55,
				origin: { x: 0, y: 0.7 },
				colors: ['#f97316', '#fb923c', '#fdba74', '#a78bfa', '#818cf8']
			});
			confetti({
				particleCount: 3,
				angle: 120,
				spread: 55,
				origin: { x: 1, y: 0.7 },
				colors: ['#f97316', '#fb923c', '#fdba74', '#a78bfa', '#818cf8']
			});
			if (Date.now() < end) {
				requestAnimationFrame(frame);
			}
		};

		frame();
	});
</script>

<svelte:head>
	<title>Бронирование подтверждено</title>
</svelte:head>

<div class="container mx-auto px-4 py-20">
	<div class="max-w-md mx-auto space-y-7 text-center">
		<!-- Анимированный круг с галочкой -->
		<div class="flex justify-center animate-fade-in-up">
			<div class="relative flex h-24 w-24 items-center justify-center">
				<!-- Внешний glow-круг -->
				<div class="absolute inset-0 rounded-full bg-green-400/20 animate-ping" style="animation-duration:2s;"></div>
				<!-- Основной круг -->
				<div class="relative flex h-24 w-24 items-center justify-center rounded-full bg-gradient-to-br from-green-400 to-emerald-600 shadow-[0_0_40px_oklch(0.7_0.2_145/0.5)]">
					<svg class="h-12 w-12 text-white" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5">
						<path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7" />
					</svg>
				</div>
			</div>
		</div>

		<!-- Заголовок -->
		<div class="animate-fade-in-up animate-fade-in-up-delay-1">
			<h1 data-testid="success-heading" class="text-3xl font-black tracking-tight bg-gradient-to-r from-green-600 to-emerald-500 bg-clip-text text-transparent">
				Бронирование подтверждено!
			</h1>
			<p class="text-muted-foreground mt-2">Мы ждём вас в назначенное время.</p>
		</div>

		<!-- Карточка с деталями -->
		<div class="glass rounded-2xl p-6 text-left border-green-200/60 dark:border-green-800/40 animate-fade-in-up animate-fade-in-up-delay-2">
			<p class="text-xs font-bold uppercase tracking-widest text-green-600 dark:text-green-400 mb-4">Детали встречи</p>
			<p data-testid="success-event-name" class="text-xl font-bold mb-4">{eventName}</p>
			<div class="space-y-3 text-sm">
				<div class="flex justify-between">
					<span class="text-muted-foreground">Начало</span>
					<span class="font-semibold">{formatDateTime(startTime)}</span>
				</div>
				<div class="flex justify-between">
					<span class="text-muted-foreground">Окончание</span>
					<span class="font-semibold">{formatDateTime(endTime)}</span>
				</div>
				{#if bookingId}
					<div class="pt-3 border-t border-border/50">
						<span class="text-muted-foreground text-xs">ID: </span>
						<code data-testid="booking-id-display" class="text-xs font-mono text-muted-foreground">{bookingId}</code>
					</div>
				{/if}
			</div>
		</div>

		<div class="animate-fade-in-up animate-fade-in-up-delay-3">
			<Button href="/" variant="outline" class="gap-2">Вернуться на главную</Button>
		</div>
	</div>
</div>
