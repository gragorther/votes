<script lang="ts">
	import LikesList from '$lib/components/LikesList.svelte';
	import Like from '$lib/components/Like.svelte';
	import Downvote from '$lib/components/Downvote.svelte';
	import Upvote from '$lib/components/Upvote.svelte';
	import Time from '$lib/components/Time.svelte';
	import { sortByPublished } from '$lib/sortByPublished.js';
	let { data } = $props();
	const username = data.username;
	const postVotes = data.postVotes.votes; // The user's votes
	const commentVotes = data.commentVotes.votes;
	const allVotes = postVotes.concat(commentVotes);
</script>

<p>List of votes for {username}</p>
<p>Total votes: {allVotes.length}</p>

<svelte:head><title>Lemvotes - {username}</title></svelte:head>
<LikesList>
	{#each sortByPublished([...allVotes]) as like}
		<Like>
			<a href={like.ap_id}>{like.ap_id}</a>

			{#if like.score === -1}
				<Downvote />
			{:else}
				<Upvote />
			{/if}
			at <Time time={like.published} />
		</Like>
	{/each}
</LikesList>
