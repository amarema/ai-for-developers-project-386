<script lang="ts">
	import { Calendar as CalendarPrimitive } from 'bits-ui';
	import { cn } from '$lib/utils.js';
	import type { DateValue } from '@internationalized/date';
	import { ChevronLeft, ChevronRight } from '@lucide/svelte';

	interface Props {
		value?: DateValue;
		onValueChange?: (value: DateValue | undefined) => void;
		isDateDisabled?: (date: DateValue) => boolean;
		isDateUnavailable?: (date: DateValue) => boolean;
		locale?: string;
		class?: string;
	}

	let {
		value = $bindable(),
		onValueChange,
		isDateDisabled,
		isDateUnavailable,
		locale = 'ru-RU',
		class: className
	}: Props = $props();
</script>

<CalendarPrimitive.Root
	type="single"
	bind:value
	{onValueChange}
	{isDateDisabled}
	{isDateUnavailable}
	{locale}
	weekdayFormat="short"
	class={cn('p-3', className)}
>
	{#snippet children({ months, weekdays })}
		<CalendarPrimitive.Header class="relative flex items-center justify-between mb-3">
			<CalendarPrimitive.PrevButton
				class="inline-flex h-7 w-7 items-center justify-center rounded-md border border-input bg-background hover:bg-accent hover:text-accent-foreground transition-colors"
			>
				<ChevronLeft class="h-4 w-4" />
			</CalendarPrimitive.PrevButton>
			<CalendarPrimitive.Heading class="text-sm font-semibold capitalize" />
			<CalendarPrimitive.NextButton
				class="inline-flex h-7 w-7 items-center justify-center rounded-md border border-input bg-background hover:bg-accent hover:text-accent-foreground transition-colors"
			>
				<ChevronRight class="h-4 w-4" />
			</CalendarPrimitive.NextButton>
		</CalendarPrimitive.Header>

		{#each months as month (month.value)}
			<CalendarPrimitive.Grid class="w-full border-collapse">
				<CalendarPrimitive.GridHead>
					<CalendarPrimitive.GridRow class="flex">
						{#each weekdays as weekday (weekday)}
							<CalendarPrimitive.HeadCell
								class="w-9 text-[0.8rem] font-normal text-muted-foreground text-center pb-1"
							>
								{weekday}
							</CalendarPrimitive.HeadCell>
						{/each}
					</CalendarPrimitive.GridRow>
				</CalendarPrimitive.GridHead>

				<CalendarPrimitive.GridBody>
					{#each month.weeks as weekDates (weekDates)}
						<CalendarPrimitive.GridRow class="flex w-full mt-1">
							{#each weekDates as date (date)}
								<CalendarPrimitive.Cell
									{date}
									month={month.value}
									class="relative h-9 w-9 p-0 text-center text-sm"
								>
									<CalendarPrimitive.Day
										class={cn(
											'inline-flex h-9 w-9 items-center justify-center rounded-md text-sm font-normal transition-colors',
											'hover:bg-accent hover:text-accent-foreground',
											'focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring',
											'data-[selected]:bg-primary data-[selected]:text-primary-foreground data-[selected]:hover:bg-primary',
											'data-[disabled]:opacity-30 data-[disabled]:pointer-events-none',
											'data-[unavailable]:text-muted-foreground data-[unavailable]:line-through data-[unavailable]:pointer-events-none',
											'data-[outside-month]:opacity-0 data-[outside-month]:pointer-events-none',
											'data-[today]:font-semibold data-[today]:underline'
										)}
									/>
								</CalendarPrimitive.Cell>
							{/each}
						</CalendarPrimitive.GridRow>
					{/each}
				</CalendarPrimitive.GridBody>
			</CalendarPrimitive.Grid>
		{/each}
	{/snippet}
</CalendarPrimitive.Root>
