<script lang="ts">
	import Button from '$lib/components/ui/button/button.svelte';
	import * as Card from '$lib/components/ui/card/index.js';
</script>

<svelte:head>
	<title>Calendar — быстрая запись на звонок</title>
</svelte:head>

<!-- Лендинг с тёплым градиентным фоном -->
<div class="hero-gradient">
	<div class="container mx-auto px-4 py-16 flex flex-col lg:flex-row items-center gap-12 min-h-[calc(100vh-57px)]">
		<!-- Левая часть: заголовок и CTA -->
		<div class="flex-1 space-y-6">
			<p class="text-sm text-muted-foreground uppercase tracking-widest font-medium">
				быстрое запись на звонок
			</p>
			<h1 class="text-6xl font-bold tracking-tight leading-tight">Calendar</h1>
			<p class="text-lg text-muted-foreground max-w-md">
				Забронируйте встречу за минуту — выбирайте тип события и удобное время.
			</p>
			<Button href="/book" size="lg" class="gap-2">
				Записаться →
			</Button>
		</div>

		<!-- Правая часть: карточка с возможностями -->
		<div class="flex-1 max-w-sm">
			<Card.Root class="bg-white/80 backdrop-blur shadow-sm">
				<Card.Header>
					<Card.Title class="text-base">Возможности</Card.Title>
				</Card.Header>
				<Card.Content>
					<ul class="space-y-3 text-sm text-muted-foreground">
						<li class="flex gap-2">
							<span class="text-primary">•</span>
							Выберите тип события и удобное время для встречи
						</li>
						<li class="flex gap-2">
							<span class="text-primary">•</span>
							Быстрое бронирование с подтверждением и дополнительными заметками
						</li>
						<li class="flex gap-2">
							<span class="text-primary">•</span>
							Управление типами встреч и просмотр предстоящих записей в админке
						</li>
					</ul>
				</Card.Content>
			</Card.Root>
		</div>
	</div>
</div>
