<script lang="ts">
	import { ArrowBigDown, ArrowBigUp } from 'lucide-svelte';
	import LikesList from '$lib/components/LikesList.svelte';
	import Like from '$lib/components/Like.svelte';
	export let data;
	const posts = data.post;
	const post_url = data.post_url;
	import { formatDate } from '$lib/formatDate.ts';
</script>

<p>List of votes for {post_url}</p>
<LikesList>
	{#each [...posts.likes].sort((a, b) => a.score - b.score) as like}
		<Like>
			<a href="https://{like.person.instance.domain}/u/{like.person.name}"
				>{like.person.name}@{like.person.instance.domain}</a
			>

			{#if like.score === -1}
				<ArrowBigDown class="inline" color="#eb3434" />
			{:else}
				<ArrowBigUp class="inline" color="#34a4e0" />
			{/if}
			at {formatDate(like.published)}
		</Like>
	{/each}
</LikesList>
