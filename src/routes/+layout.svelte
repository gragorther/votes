<script lang="ts">
	import '../app.css';

	let { children } = $props();
</script>

<svelte:head><title>Lemvotes</title></svelte:head>
<main class="text-center">
	<span class="flex justify-center">
		<picture class="inline size-10">
			<!-- User prefers light mode: -->
			<source srcset="/favicon.png" media="(prefers-color-scheme: light)" />

			<!-- User prefers dark mode: -->
			<source srcset="/favicon-dark.png" media="(prefers-color-scheme: dark)" />

			<!-- User has no color preference: -->
			<img
				src="/light.png"
				alt="website icon, a downvote and upvote arrow on the left and the lemmy logo on the right"
			/>
		</picture>

		<h1 class="text-center text-4xl"><a href="/" class="text-inherit">Lemvotes</a></h1></span
	>

	{@render children()}
</main>
