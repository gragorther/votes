<script lang="ts">
	import LikesList from '$lib/components/LikesList.svelte';
	import Like from '$lib/components/Like.svelte';
	import Upvote from '$lib/components/Upvote.svelte';
	import Downvote from '$lib/components/Downvote.svelte';
	import Time from '$lib/components/Time.svelte';
	import { sortByPublished } from '$lib/sortByPublished.ts';
	let { data } = $props();
	const comments = data.comment;
	const comment_url = data.comment_url;
</script>

<p>List of votes for <a href={comment_url}>{comment_url}</a></p>
<svelte:head><title>Lemvotes - {comment_url}</title></svelte:head>
<LikesList>
	{#each sortByPublished([...comments.likes]) as like}
		<Like>
			<a href="https://{like.person.instance.domain}/u/{like.person.name}"
				>{like.person.name}@{like.person.instance.domain}</a
			>

			{#if like.score === -1}
				<Downvote />
			{:else}
				<Upvote />
			{/if}
			at <Time time={like.published} />
		</Like>
	{/each}
</LikesList>
