<script lang="ts">
	import { ArrowBigUp, Loader } from 'lucide-svelte';
	import { ArrowBigDown } from 'lucide-svelte';
	import { env } from '$env/dynamic/public';
	interface Vote {
		user: string;
		vote: number;
		instance: string;
	}

	const backend_url = env.PUBLIC_BACKEND_URL;

	let postId = $state('');
	let votes: Vote[] = $state([]);
	let error = $state('');
	let comment = $state(false);
	let post_type: string = $state('');
	let disabled = $state(false);
	let buttonColor = $state('bg-blue-500');
	let cursor = $state('');
	let buttonCursor = $state('cursor-pointer');

	async function fetchVotes() {
		console.log('Submitting post URL:', postId);
		try {
			//sends request
			const response = await fetch(`${backend_url}/api/votes`, {
				method: 'POST',
				headers: { 'Content-Type': 'application/json' },
				body: JSON.stringify({ post_url: postId, comment: comment })
			});

			const data = await response.json();
			if (response.ok) {
				votes = data.votes;
				error = '';
			} else {
				error = data.error || 'An error occurred';
			}
		} catch (err) {
			error = 'Failed to fetch votes';
			console.error('Fetch error:', err);
		}
	}

	async function handleSubmit(event: any) {
		event.preventDefault();
		disabled = true;
		buttonColor = 'bg-blue-300';
		cursor = 'cursor-progress';
		buttonCursor = 'cursor-progress';
		await fetchVotes();

		buttonColor = 'bg-blue-500';
		buttonCursor = 'cursor-pointer';
		disabled = false;
		cursor = '';
	}

	$effect(() => {
		if (comment) {
			post_type = 'Comment';
		} else {
			post_type = 'Post';
		}
	});
</script>

<title>Lemvotes</title>
<div class={cursor}>
	<div class="text-center">
		<span class=" flex justify-center">
			<picture class="inline size-10">
				<!-- User prefers light mode: -->
				<source srcset="favicon.png" media="(prefers-color-scheme: light)" />

				<!-- User prefers dark mode: -->
				<source srcset="favicon-dark.png" media="(prefers-color-scheme: dark)" />

				<!-- User has no color preference: -->
				<img
					src="light.png"
					alt="website icon, a downvote and upvote arrow on the left and the lemmy logo on the right"
				/>
			</picture>

			<h1 class="text-center text-4xl">Lemvotes</h1></span
		>

		<p>A tool for getting information about who votes on a Lemmy post/comment</p>
		<div class="flex items-center justify-center">
			<div
				class="max-w-xs content-center justify-center overflow-auto rounded-2xl border-2 border-pink-400 p-4"
			>
				<form onsubmit={handleSubmit} class="mt-2 flex flex-col flex-wrap justify-center gap-2">
					<input
						type="text"
						bind:value={postId}
						placeholder="Enter {post_type} URL"
						class="self-stretch rounded-md border-2 border-orange-500 text-center"
						onfocus={(e) => {
							const input = e.target as HTMLInputElement | null;
							if (input) {
								input.select();
							}
						}}
						required
					/><span>
						<input type="checkbox" bind:checked={comment} id="post-or-comment" />
						<label class="select-none" for="post-or-comment">This is a comment</label>
					</span>
					<button
						type="submit"
						class="{buttonCursor} self-center rounded {buttonColor} px-4 py-2 text-white"
						{disabled}
					>
						Get Votes
						{#if disabled}
							<!--I used the disabled variable here to avoid making another one named `loading` which would do exactly the same-->
							<Loader class="inline size-4 animate-spin" />
						{/if}
					</button>
				</form>
				<div class="mt-2 text-left">
					<p>
						This tool is open source, you can access the code <a
							href="https://github.com/gragorther/votes">on GitHub</a
						>
						and you can read the dev's posts on
						<a href="https://blog.gregtech.eu/tags/lemvotes/">the blog</a>.
					</p>
				</div>
			</div>
		</div>
	</div>
	{#if error}
		<p class="mt-4 text-center text-red-500">{error}</p>
	{/if}

	{#if !error}
		<div class="m-2 flex justify-center break-all">
			<ul class="mt-4 space-y-2">
				{#each [...votes].sort((a, b) => a.vote - b.vote) as vote}
					<li class="rounded border p-1 text-center">
						<a href="https://{vote.instance}/u/{vote.user}">{vote.user}@{vote.instance}</a>

						{#if vote.vote === -1}
							<ArrowBigDown class="inline" color="#eb3434" />
						{:else}
							<ArrowBigUp class="inline" color="#34a4e0" />
						{/if}
					</li>
				{/each}
			</ul>
		</div>
	{/if}
</div>
