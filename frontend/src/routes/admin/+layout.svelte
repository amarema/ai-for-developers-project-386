<script lang="ts">
	import { page } from '$app/stores';

	let { children } = $props();

	// Определяем активный раздел по текущему пути
	const isEventTypes = $derived($page.url.pathname.startsWith('/admin/event-types'));
	const isBookings = $derived($page.url.pathname.startsWith('/admin/bookings'));
</script>

<!-- Подменю для административного раздела -->
<div class="container mx-auto px-4 py-8">
	<div class="space-y-6">
		<nav class="flex gap-1 border-b pb-0 text-sm">
			<a
				href="/admin/event-types"
				class="px-4 py-2.5 font-medium transition-colors border-b-2 -mb-px
					{isEventTypes
						? 'border-primary text-primary'
						: 'border-transparent text-muted-foreground hover:text-foreground hover:border-border'}"
			>
				Типы событий
			</a>
			<a
				href="/admin/bookings"
				class="px-4 py-2.5 font-medium transition-colors border-b-2 -mb-px
					{isBookings
						? 'border-primary text-primary'
						: 'border-transparent text-muted-foreground hover:text-foreground hover:border-border'}"
			>
				Бронирования
			</a>
		</nav>

		{@render children()}
	</div>
</div>
