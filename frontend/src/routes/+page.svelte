<script lang="ts">
	import Button from '$lib/components/ui/button/button.svelte';
	import { Clock, CheckCircle, Settings, CalendarDays, ArrowRight } from '@lucide/svelte';
</script>

<svelte:head>
	<title>Calendar — быстрая запись на звонок</title>
</svelte:head>

<div class="hero-gradient">
	<!-- Анимированные blob-пятна на фоне -->
	<div
		aria-hidden="true"
		style="position:absolute;top:-80px;left:-120px;width:480px;height:480px;
		       background:oklch(0.75 0.18 40 / 0.35);filter:blur(80px);
		       border-radius:60% 40% 30% 70% / 60% 30% 70% 40%;
		       animation:blob 10s ease-in-out infinite, float 8s ease-in-out infinite;"
	></div>
	<div
		aria-hidden="true"
		style="position:absolute;top:60px;right:-80px;width:400px;height:400px;
		       background:oklch(0.65 0.15 310 / 0.25);filter:blur(80px);
		       border-radius:30% 60% 70% 40% / 50% 60% 30% 60%;
		       animation:blob 13s ease-in-out infinite reverse, float 10s ease-in-out infinite;
		       animation-delay:-3s;"
	></div>
	<div
		aria-hidden="true"
		style="position:absolute;bottom:40px;left:40%;width:360px;height:360px;
		       background:oklch(0.78 0.16 60 / 0.2);filter:blur(70px);
		       border-radius:50% 30% 60% 40% / 40% 70% 30% 60%;
		       animation:blob 9s ease-in-out infinite, float 12s ease-in-out infinite;
		       animation-delay:-6s;"
	></div>

	<!-- Контент поверх blobs -->
	<div class="container mx-auto max-w-6xl px-4 py-10 sm:py-14 lg:py-20 flex flex-col lg:flex-row items-center gap-8 lg:gap-16 min-h-[calc(100vh-57px)] relative z-10">

		<!-- Левая часть: заголовок и CTA -->
		<div class="flex-1 space-y-7 animate-fade-in-up">
			<!-- Бейдж-тэглайн -->
			<div class="inline-flex items-center gap-2 rounded-full border border-primary/30 bg-primary/8 px-4 py-1.5 text-xs font-semibold uppercase tracking-widest text-primary">
				<span class="h-1.5 w-1.5 rounded-full bg-primary pulse-dot"></span>
				Быстрая запись на звонок
			</div>

			<!-- Мегазаголовок -->
			<h1 class="text-4xl sm:text-5xl lg:text-7xl font-black tracking-tighter leading-none bg-gradient-to-br from-foreground via-foreground/90 to-foreground/50 bg-clip-text text-transparent">
				Calendar
			</h1>

			<p class="text-base sm:text-xl text-muted-foreground max-w-md leading-relaxed animate-fade-in-up animate-fade-in-up-delay-1">
				Забронируйте встречу за минуту — выбирайте тип события и удобное время без лишних усилий.
			</p>

			<!-- Shimmer CTA -->
			<div class="animate-fade-in-up animate-fade-in-up-delay-2">
				<a
					href="/book"
					class="btn-shimmer inline-flex items-center gap-2.5 rounded-xl px-7 py-3.5 text-sm font-semibold text-white transition-transform"
				>
					<CalendarDays class="h-4 w-4" />
					Записаться на встречу
					<ArrowRight class="h-4 w-4" />
				</a>
			</div>
		</div>

		<!-- Правая часть: glass-карточка с возможностями -->
		<div class="flex-1 w-full max-w-sm animate-fade-in-up animate-fade-in-up-delay-2">
			<div class="glass rounded-2xl p-6 shadow-xl">
				<p class="text-xs font-bold uppercase tracking-widest text-primary mb-5">Возможности</p>
				<ul class="space-y-5">
					<li class="flex items-start gap-4">
						<span class="flex h-9 w-9 shrink-0 items-center justify-center rounded-xl bg-primary/12 text-primary">
							<Clock class="h-4 w-4" />
						</span>
						<div>
							<p class="text-sm font-semibold">Выбор времени</p>
							<p class="text-xs text-muted-foreground mt-0.5">Удобный календарь с доступными слотами на 14 дней</p>
						</div>
					</li>
					<li class="flex items-start gap-4">
						<span class="flex h-9 w-9 shrink-0 items-center justify-center rounded-xl bg-primary/12 text-primary">
							<CheckCircle class="h-4 w-4" />
						</span>
						<div>
							<p class="text-sm font-semibold">Мгновенное подтверждение</p>
							<p class="text-xs text-muted-foreground mt-0.5">Бронирование с заметками — без лишних шагов</p>
						</div>
					</li>
					<li class="flex items-start gap-4">
						<span class="flex h-9 w-9 shrink-0 items-center justify-center rounded-xl bg-primary/12 text-primary">
							<Settings class="h-4 w-4" />
						</span>
						<div>
							<p class="text-sm font-semibold">Панель управления</p>
							<p class="text-xs text-muted-foreground mt-0.5">Управление встречами и просмотр записей в админке</p>
						</div>
					</li>
				</ul>
			</div>
		</div>
	</div>
</div>
