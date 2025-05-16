<script lang="ts">
	import LikesList from '$lib/components/LikesList.svelte';
	import Like from '$lib/components/Like.svelte';
	export let data;
	const comments = data.comment;
	const comment_url = data.comment_url;
	import { formatDate } from '$lib/formatDate.ts';
	import Upvote from '$lib/components/Upvote.svelte';
	import Downvote from '$lib/components/Downvote.svelte';
</script>

<p>List of votes for <a href={comment_url}>{comment_url}</a></p>
<LikesList>
	{#each [...comments.likes].sort((a, b) => a.score - b.score) as like}
		<Like>
			<a href="https://{like.person.instance.domain}/u/{like.person.name}"
				>{like.person.name}@{like.person.instance.domain}</a
			>

			{#if like.score === -1}
				<Downvote />
			{:else}
				<Upvote />
			{/if}
			at {formatDate(like.published)}
		</Like>
	{/each}
</LikesList>
