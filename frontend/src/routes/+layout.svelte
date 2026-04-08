<script lang="ts">
	import '../app.css';
	import favicon from '$lib/assets/favicon.svg';
	import { Clock, Sun, Moon } from '@lucide/svelte';
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

<!-- Навигационная шапка -->
<header class="border-b bg-background/95 backdrop-blur sticky top-0 z-10">
	<div class="container mx-auto flex items-center justify-between px-4 py-3">
		<a href="/" class="flex items-center gap-1.5 font-bold text-lg tracking-tight">
			<Clock class="h-5 w-5 text-primary" />
			Calendar
		</a>
		<div class="flex items-center gap-4">
			<nav class="flex gap-4 text-sm">
				<a href="/book" class="text-muted-foreground hover:text-foreground transition-colors">Записаться</a>
				<a href="/admin/event-types" class="text-muted-foreground hover:text-foreground transition-colors">Админка</a>
			</nav>
			<button
				onclick={toggleTheme}
				aria-label="Переключить тему"
				class="rounded-md p-1.5 text-muted-foreground hover:text-foreground hover:bg-accent transition-colors"
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
