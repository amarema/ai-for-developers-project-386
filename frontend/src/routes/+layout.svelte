<script lang="ts">
	import '../app.css';
	import favicon from '$lib/assets/favicon.svg';

	let { children } = $props();
</script>

<svelte:head>
	<link rel="icon" href={favicon} />
</svelte:head>

<!-- Навигационная шапка -->
<header class="border-b bg-background sticky top-0 z-10">
	<div class="container mx-auto flex items-center justify-between px-4 py-3">
		<a href="/" class="text-lg font-semibold tracking-tight">Calendar Booking</a>
		<nav class="flex gap-4 text-sm text-muted-foreground">
			<a href="/" class="hover:text-foreground transition-colors">Запись</a>
			<a href="/admin/event-types" class="hover:text-foreground transition-colors">Админ</a>
		</nav>
	</div>
</header>

<main class="container mx-auto px-4 py-8">
	{@render children()}
</main>
