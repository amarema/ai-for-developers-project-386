<script lang="ts">
	let { children } = $props();
</script>

<!-- Подменю для административного раздела -->
<div class="space-y-6">
	<nav class="flex gap-4 border-b pb-4 text-sm">
		<a href="/admin/event-types" class="font-medium hover:text-primary transition-colors">
			Типы событий
		</a>
		<a href="/admin/bookings" class="font-medium hover:text-primary transition-colors">
			Бронирования
		</a>
	</nav>

	{@render children()}
</div>
