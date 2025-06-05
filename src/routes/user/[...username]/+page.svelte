<script lang="ts">
	import VotesList from '$lib/components/VotesList.svelte';
	import Vote from '$lib/components/Vote.svelte';
	import Downvote from '$lib/components/Downvote.svelte';
	import Upvote from '$lib/components/Upvote.svelte';
	import Time from '$lib/components/Time.svelte';
	import { sortVotes } from '$lib/sortVotes';
	import Loading from '$lib/components/Loading.svelte';

	interface Props {
		data: {
			postVotes: Promise<any>;
			commentVotes: Promise<any>;
			username: string;
			voteCount: Promise<any>;
		};
	}

	let { data }: Props = $props();
	console.log(data.voteCount);
	let downvotesFirst = $state(true);
</script>

<p class="font-bold">List of votes for {data.username}:</p>
{#await data.voteCount then result}
	<p>Total post upvotes: {result.posts.upvotes}</p>
	<p>Total post downvotes: {result.posts.downvotes}</p>
	<p>Total comment upvotes: {result.comments.upvotes}</p>
	<p>Total comment downvotes: {result.comments.downvotes}</p>
{:catch error}
	<p>Error loading vote count: {error.message}</p>
{/await}

<svelte:head><title>{data.username} - Lemvotes</title></svelte:head>
<div class="flex justify-center gap-1 p-2">
	<input
		id="downvotesFirst"
		type="checkbox"
		class="size-4 self-center"
		bind:checked={downvotesFirst}
	/>
	<label for="downvotesFirst" class="text-xl text-white select-none">Downvotes first</label>
</div>

{#await Promise.all([data.commentVotes, data.postVotes])}
	<Loading />
{:then [commentVotes, postVotes]}
	<VotesList>
		{#each sortVotes( [...commentVotes.votes, ...postVotes.votes], { downvotesFirst: downvotesFirst } ) as vote}
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
