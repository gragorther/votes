<script lang="ts">
	import VotesList from '$lib/components/VotesList.svelte';
	import Vote from '$lib/components/Vote.svelte';
	import Upvote from '$lib/components/Upvote.svelte';
	import Downvote from '$lib/components/Downvote.svelte';
	import Time from '$lib/components/Time.svelte';
	import { sortByPublished } from '$lib/sortByPublished.ts';
	let { data } = $props();
	const comments = data.comment;
	const comment_url = data.comment_url;
</script>

<p>List of votes for <a href="https://{comment_url}">{comment_url}</a></p>
<svelte:head><title>{comment_url} - Lemvotes</title></svelte:head>
<VotesList>
	{#each sortByPublished([...comments.votes]) as vote}
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
