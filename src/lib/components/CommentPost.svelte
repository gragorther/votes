<script lang="ts">
	import VotesList from '$lib/components/VotesList.svelte';
	import Vote from '$lib/components/Vote.svelte';
	import Upvote from '$lib/components/Upvote.svelte';
	import Downvote from '$lib/components/Downvote.svelte';
	import Time from '$lib/components/Time.svelte';
	import { sortVotes } from '$lib/sortVotes.ts';
	let { voteArray, url } = $props();
</script>

<p>List of votes for <a href="https://{url}">https://{url}</a></p>
<svelte:head><title>{url} - Lemvotes</title></svelte:head>
<VotesList>
	{#each sortVotes([...voteArray], { downvotesFirst: true }) as vote}
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
