<script lang="ts">
	import { ArrowBigDown, ArrowBigUp } from 'lucide-svelte';
	import LikesList from '$lib/components/LikesList.svelte';
	import Like from '$lib/components/Like.svelte';
	export let data;
	const username = data.username; // The username
	const votes = data.user.votes; // The user's votes
	import { formatDate } from '$lib/formatDate.ts';
</script>

<p>List of votes for {username}</p>
<p>Total votes: {votes.length}</p>
<LikesList>
	{#each [...votes].sort((a, b) => a.score - b.score) as like}
		<Like>
			<a href={like.ap_id}>{like.ap_id}</a>

			{#if like.score === -1}
				<ArrowBigDown class="inline" color="#eb3434" />
			{:else}
				<ArrowBigUp class="inline" color="#34a4e0" />
			{/if}
			at {formatDate(like.published)}
		</Like>
	{/each}
</LikesList>
