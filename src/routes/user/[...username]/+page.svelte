<script lang="ts">
	import LikesList from '$lib/components/LikesList.svelte';
	import Like from '$lib/components/Like.svelte';
	import { formatDate } from '$lib/formatDate.ts';
	import Downvote from '$lib/components/Downvote.svelte';
	import Upvote from '$lib/components/Upvote.svelte';
	let { data } = $props();
	const votes = data.user.votes; // The user's votes
</script>

<p>List of votes for {data.user.name}@{data.user.instance.domain}</p>
<p>Total votes: {votes.length}</p>

<svelte:head><title>Lemvotes - {data.user.name}@{data.user.instance.domain}</title></svelte:head>
<LikesList>
	{#each [...votes].sort((a, b) => a.score - b.score) as like}
		<Like>
			<a href={like.ap_id}>{like.ap_id}</a>

			{#if like.score === -1}
				<Downvote />
			{:else}
				<Upvote />
			{/if}
			at {formatDate(like.published)}
		</Like>
	{/each}
</LikesList>
