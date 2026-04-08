<script lang="ts">
	import { onMount } from 'svelte';
	import { adminListEventTypes, adminCreateEventType } from '$lib/api.js';
	import type { EventType } from '$lib/types.js';
	import * as Table from '$lib/components/ui/table/index.js';
	import * as Card from '$lib/components/ui/card/index.js';
	import Button from '$lib/components/ui/button/button.svelte';
	import Input from '$lib/components/ui/input/input.svelte';
	import Label from '$lib/components/ui/label/label.svelte';
	import Textarea from '$lib/components/ui/textarea/textarea.svelte';

	let eventTypes = $state<EventType[]>([]);
	let loading = $state(true);
	let error = $state<string | null>(null);

	// Поля формы создания типа события
	let formId = $state('');
	let formName = $state('');
	let formDescription = $state('');
	let formDuration = $state(30);
	let submitting = $state(false);
	let formError = $state<string | null>(null);
	let formSuccess = $state(false);

	onMount(async () => {
		await loadEventTypes();
	});

	async function loadEventTypes() {
		loading = true;
		error = null;
		try {
			eventTypes = await adminListEventTypes();
		} catch (e) {
			error = (e as Error).message;
		} finally {
			loading = false;
		}
	}

	async function handleCreate(e: SubmitEvent) {
		e.preventDefault();
		submitting = true;
		formError = null;
		formSuccess = false;
		try {
			const created = await adminCreateEventType({
				id: formId,
				name: formName,
				description: formDescription,
				durationMinutes: formDuration
			});
			eventTypes = [...eventTypes, created];
			// Сброс формы после успешного создания
			formId = '';
			formName = '';
			formDescription = '';
			formDuration = 30;
			formSuccess = true;
		} catch (e) {
			const err = e as Error & { body?: { message?: string } };
			formError = err.body?.message ?? err.message;
		} finally {
			submitting = false;
		}
	}
</script>

<svelte:head>
	<title>Типы событий — Админ</title>
</svelte:head>

<div class="space-y-8">
	<h1 class="text-2xl font-bold tracking-tight">Типы событий</h1>

	<!-- Таблица существующих типов -->
	<div>
		{#if loading}
			<p class="text-muted-foreground">Загрузка...</p>
		{:else if error}
			<p class="text-destructive">Ошибка: {error}</p>
		{:else if eventTypes.length === 0}
			<p class="text-muted-foreground">Типов событий ещё нет.</p>
		{:else}
			<Table.Root>
				<Table.Header>
					<Table.Row>
						<Table.Head>ID (slug)</Table.Head>
						<Table.Head>Название</Table.Head>
						<Table.Head>Описание</Table.Head>
						<Table.Head class="text-right">Длительность</Table.Head>
					</Table.Row>
				</Table.Header>
				<Table.Body>
					{#each eventTypes as et (et.id)}
						<Table.Row>
							<Table.Cell class="font-mono text-sm">{et.id}</Table.Cell>
							<Table.Cell class="font-medium">{et.name}</Table.Cell>
							<Table.Cell class="text-muted-foreground">{et.description}</Table.Cell>
							<Table.Cell class="text-right">{et.durationMinutes} мин</Table.Cell>
						</Table.Row>
					{/each}
				</Table.Body>
			</Table.Root>
		{/if}
	</div>

	<!-- Форма создания нового типа события -->
	<Card.Root class="max-w-md">
		<Card.Header>
			<Card.Title>Создать тип события</Card.Title>
		</Card.Header>
		<Card.Content>
			<form onsubmit={handleCreate} class="space-y-4">
				<div class="space-y-1.5">
					<Label for="et-id">ID (slug)</Label>
					<Input
						id="et-id"
						bind:value={formId}
						required
						placeholder="intro-call"
						pattern="[a-z0-9-]+"
						title="Строчные латинские буквы, цифры и дефисы"
					/>
				</div>

				<div class="space-y-1.5">
					<Label for="et-name">Название</Label>
					<Input id="et-name" bind:value={formName} required placeholder="Первичная консультация" />
				</div>

				<div class="space-y-1.5">
					<Label for="et-desc">Описание</Label>
					<Textarea
						id="et-desc"
						bind:value={formDescription}
						required
						placeholder="Обсудим ваши задачи и цели."
						rows={3}
					/>
				</div>

				<div class="space-y-1.5">
					<Label for="et-duration">Длительность (минуты)</Label>
					<Input
						id="et-duration"
						type="number"
						bind:value={formDuration}
						required
						min={5}
						max={480}
						step={5}
					/>
				</div>

				{#if formError}
					<p class="text-sm text-destructive">{formError}</p>
				{/if}
				{#if formSuccess}
					<p class="text-sm text-green-600">Тип события создан!</p>
				{/if}

				<Button type="submit" disabled={submitting} class="w-full">
					{submitting ? 'Создаём...' : 'Создать'}
				</Button>
			</form>
		</Card.Content>
	</Card.Root>
</div>
