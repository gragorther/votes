<script lang="ts">
	import LikesList from '$lib/components/LikesList.svelte';
	import Like from '$lib/components/Like.svelte';
	import Downvote from '$lib/components/Downvote.svelte';
	import Upvote from '$lib/components/Upvote.svelte';
	import Time from '$lib/components/Time.svelte';
	import { sortByPublished } from '$lib/sortByPublished.js';
	let { data } = $props();
	const posts = data.post;
	const post_url = data.post_url;
</script>

<p>List of votes for <a href={post_url}>{post_url}</a></p>
<svelte:head><title>Lemvotes - {post_url}</title></svelte:head>
<LikesList>
	{#each sortByPublished([...posts.likes]) as like}
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
