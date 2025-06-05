<script lang="ts">
	import VotesList from '$lib/components/VotesList.svelte';
	import Vote from '$lib/components/Vote.svelte';
	import Upvote from '$lib/components/Upvote.svelte';
	import Downvote from '$lib/components/Downvote.svelte';
	import Time from '$lib/components/Time.svelte';
	import { sortVotes } from '$lib/sortVotes.ts';
	let { voteArray, url } = $props();
	let downvotesFirst: boolean = $state(true);
</script>

<p>List of votes for <a href="https://{url}">https://{url}</a></p>
<svelte:head><title>{url} - Lemvotes</title></svelte:head>
<div class="flex justify-center gap-1 p-2">
	<input
		id="downvotesFirst"
		type="checkbox"
		class="size-4 self-center"
		bind:checked={downvotesFirst}
	/>
	<label for="downvotesFirst" class="text-xl text-white select-none">Downvotes first</label>
</div>
<VotesList>
	{#each sortVotes([...voteArray], { downvotesFirst: downvotesFirst }) as vote}
		<Vote>
			<a href="https://{vote.person.instance.domain}/u/{vote.person.name}"
				>{vote.person.name}@{vote.person.instance.domain}</a
			>

			{#if vote.score === -1}
				<Downvote />
			{:else}
				<Upvote />
			{/if}
			at <Time time={vote.published} />
		</Vote>
	{/each}
</VotesList>
