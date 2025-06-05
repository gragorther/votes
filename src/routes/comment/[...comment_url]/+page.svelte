<script lang="ts">
	let { data } = $props();
	import CommentPost from '$lib/components/CommentPost.svelte';
</script>

<CommentPost voteArray={[...data.comment.votes]} url={data.comment_url} />
