<script lang="ts">
	import LikesList from '$lib/components/LikesList.svelte';
	import Like from '$lib/components/Like.svelte';
	import Downvote from '$lib/components/Downvote.svelte';
	import Upvote from '$lib/components/Upvote.svelte';
	import Time from '$lib/components/Time.svelte';
	import { sortByPublished } from '$lib/sortByPublished.ts';
	import Loading from '$lib/components/Loading.svelte';

	export let data: {
		postVotes: Promise<any>;
		commentVotes: Promise<any>;
		username: string;
		voteCount: Promise<any>;
	};
	console.log(data.voteCount);
</script>

<p>List of votes for {data.username}</p>
{#await data.voteCount then result}
	<p>Total Votes: {result.voteCount}</p>
{:catch error}
	<p>Error loading vote count: {error.message}</p>
{/await}

<svelte:head><title>Lemvotes - {data.username}</title></svelte:head>

{#await Promise.all([data.commentVotes, data.postVotes])}
	<Loading />
{:then [commentVotes, postVotes]}
	<LikesList>
		{#each sortByPublished([...commentVotes.votes, ...postVotes.votes]) as like}
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
{:catch error}
	<p>Error loading votes: {error.message}</p>
{/await}
