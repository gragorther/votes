<script lang="ts">
	let { data } = $props();
	import CommentPost from '$lib/components/CommentPost.svelte';
</script>

<CommentPost voteArray={data.post.votes} url={data.post_url} />
