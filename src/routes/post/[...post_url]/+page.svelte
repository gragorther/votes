<script lang="ts">
	import LikesList from '$lib/components/LikesList.svelte';
	import Like from '$lib/components/Like.svelte';
	export let data;
	const posts = data.post;
	const post_url = data.post_url;
	import { formatDate } from '$lib/formatDate.ts';
	import Downvote from '$lib/components/Downvote.svelte';
	import Upvote from '$lib/components/Upvote.svelte';
</script>

<p>List of votes for <a href={post_url}>{post_url}</a></p>
<svelte:head><title>Lemvotes - {post_url}</title></svelte:head>
<LikesList>
	{#each [...posts.likes].sort((a, b) => a.score - b.score) as like}
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
