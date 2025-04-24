<script lang="ts">
	import { ArrowBigUp } from 'lucide-svelte';
	import { ArrowBigDown } from 'lucide-svelte';
	import { env } from '$env/dynamic/public';
	interface Vote {
		user: string;
		vote: number;
		instance: string;
	}

	const backend_url = env.PUBLIC_BACKEND_URL;
	const instance_url = env.PUBLIC_INSTANCE_DOMAIN;

	let postId = '';
	let votes: Vote[] = [];
	let error = '';
	let comment = false;

	async function fetchVotes() {
		console.log('Submitting post ID:', postId);
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
</script>

<title>Lemvotes</title>

<div class="text-center">
	<span class=" flex justify-center"
		><img class="display:inline inline size-10" src="/favicon.png" alt=" description" />

		<h1 class="text-center text-4xl">Lemvotes</h1></span
	>

	<p>A tool I made for getting information about who votes on which Lemmy post</p>
	<div class="flex items-center justify-center">
		<div
			class="max-w-xs content-center justify-center overflow-auto rounded-2xl border-2 border-pink-400 p-4"
		>
			<form
				on:submit|preventDefault={fetchVotes}
				class="mt-2 flex flex-col flex-wrap justify-center gap-2"
			>
				<input
					type="text"
					bind:value={postId}
					placeholder="Enter Post URL"
					class="self-center rounded-md border-2 border-orange-500 text-center"
					required
				/><span>
					<input type="checkbox" bind:checked={comment} id="post-or-comment" />
					<label for="post-or-comment">This is a comment</label>
				</span>
				<button
					type="submit"
					class="cursor-pointer self-center rounded bg-blue-500 px-4 py-2 text-white"
				>
					Get Votes
				</button>
			</form>
			<div class="mt-2 text-left">
				<p class="mb-2">
					Enter the post/comment URL in the field above, and be aware that currently the
					post/comment URL has to be from its origin instance (the commenter/poster's instance). I
					am working on a better option.
				</p>
				<p>
					This tool is open source, you can access the code <a
						href="https://github.com/gragorther/votes">on GitHub</a
					>
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
				<li class="rounded border p-2">
					<a href="https://{vote.instance}/u/{vote.user}" class="text-blue-600"
						>{vote.user}@{vote.instance}</a
					>
					{#if vote.vote === -1}
						<ArrowBigDown color="#eb3434" />
					{:else}
						<ArrowBigUp color="#34a4e0" />
					{/if}
				</li>
			{/each}
		</ul>
	</div>
{/if}
