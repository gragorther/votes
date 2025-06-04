<script lang="ts">
	import VotesList from '$lib/components/VotesList.svelte';
	import Vote from '$lib/components/Vote.svelte';
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

<svelte:head><title>{data.username} - Lemvotes</title></svelte:head>

{#await Promise.all([data.commentVotes, data.postVotes])}
	<Loading />
{:then [commentVotes, postVotes]}
	<VotesList>
		{#each sortByPublished([...commentVotes.votes, ...postVotes.votes]) as vote}
			<Vote>
				<a href={vote.ap_id}>{vote.ap_id}</a>
				{#if vote.score === -1}
					<Downvote />
				{:else}
					<Upvote />
				{/if}
				at <Time time={vote.published} />
			</Vote>
		{/each}
	</VotesList>
{:catch error}
	<p>Error loading votes: {error.message}</p>
{/await}
