<script lang="ts">
	import '../app.css';
	import favicon from '$lib/assets/favicon.svg';
	import { CalendarDays, Sun, Moon } from '@lucide/svelte';
	import { onMount } from 'svelte';

	let { children } = $props();

	let dark = $state(false);

	onMount(() => {
		// Читаем сохранённое значение или системные настройки
		const saved = localStorage.getItem('theme');
		dark = saved ? saved === 'dark' : window.matchMedia('(prefers-color-scheme: dark)').matches;
		applyTheme(dark);
	});

	function applyTheme(isDark: boolean) {
		document.documentElement.classList.toggle('dark', isDark);
		localStorage.setItem('theme', isDark ? 'dark' : 'light');
	}

	function toggleTheme() {
		dark = !dark;
		applyTheme(dark);
	}
</script>

<svelte:head>
	<link rel="icon" href={favicon} />
	<!-- Применяем тему до первого рендера, чтобы избежать мигания -->
	<script>
		const t = localStorage.getItem('theme');
		if (t === 'dark' || (!t && window.matchMedia('(prefers-color-scheme: dark)').matches)) {
			document.documentElement.classList.add('dark');
		}
	</script>
</svelte:head>

<!-- Навигационная шапка с glassmorphism -->
<header class="border-b border-primary/10 bg-background/70 backdrop-blur-xl sticky top-0 z-10 shadow-sm">
	<div class="container mx-auto flex items-center justify-between px-4 py-3">
		<a href="/" class="flex items-center gap-2 font-black text-lg tracking-tight group">
			<span class="flex items-center justify-center h-8 w-8 rounded-xl bg-primary text-primary-foreground shadow-sm group-hover:shadow-md group-hover:scale-105 transition-all">
				<CalendarDays class="h-4 w-4" />
			</span>
			<span class="bg-gradient-to-r from-foreground to-foreground/70 bg-clip-text text-transparent">Calendar</span>
		</a>
		<div class="flex items-center gap-3">
			<nav class="flex gap-1 text-sm">
				<a href="/book" class="px-3 py-1.5 rounded-lg font-medium text-muted-foreground hover:text-foreground hover:bg-primary/8 transition-all">Записаться</a>
				<a href="/admin/event-types" class="px-3 py-1.5 rounded-lg font-medium text-muted-foreground hover:text-foreground hover:bg-primary/8 transition-all">Админка</a>
			</nav>
			<button
				onclick={toggleTheme}
				aria-label="Переключить тему"
				class="rounded-lg p-2 text-muted-foreground hover:text-foreground hover:bg-primary/10 transition-all"
			>
				{#if dark}
					<Sun class="h-4 w-4" />
				{:else}
					<Moon class="h-4 w-4" />
				{/if}
			</button>
		</div>
	</div>
</header>

<main>
	{@render children()}
</main>
