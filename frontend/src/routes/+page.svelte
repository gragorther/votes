<script lang="ts">
	import { ArrowBigUp } from 'lucide-svelte';
	import { ArrowBigDown } from 'lucide-svelte';
	interface Vote {
		user: string;
		vote: number;
		instance: string;
	}

	let postId = '';
	let votes: Vote[] = [];
	let error = '';

	async function fetchVotes() {
		console.log('Submitting post ID:', postId);
		try {
			const response = await fetch('https://api.gregtech.eu/api/votes', {
				method: 'POST',
				headers: { 'Content-Type': 'application/json' },
				body: JSON.stringify({ post_id: postId })
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

<div class="text-center">
	<h1 class="text-center text-4xl">Lemvotes</h1>
	<p>A tool I made for getting information about who votes on which post</p>
	<div class="flex items-center justify-center">
		<div
			class="max-w-xs content-center justify-center overflow-auto rounded-2xl border-2 border-pink-400 p-4"
		>
			<form
				on:submit|preventDefault={fetchVotes}
				class="mt-2 flex flex-col flex-wrap justify-center gap-2"
			>
				<input
					type="number"
					bind:value={postId}
					placeholder="Enter Post ID"
					class="self-center rounded-md border-2 border-orange-500 text-center"
					required
				/>
				<button
					type="submit"
					class="cursor-pointer self-center rounded bg-blue-500 px-4 py-2 text-white"
				>
					Get Votes
				</button>
			</form>
			<div class="mt-2 text-center">
				<p>
					Make sure you get the post ID from <a href="gregtech.eu">gregtech.eu</a>. There is
					probably a better solution, if you have any ideas you can
					<a href="https://github.com/gragorther/votes">contribute</a>.
				</p>
			</div>
		</div>
	</div>
</div>
{#if error}
	<p class="mt-4 text-red-500">{error}</p>
{/if}

{#if votes.length}
	<div class="m-2 flex justify-center break-all">
		<ul class="mt-4 space-y-2">
			{#each [...votes].sort((a, b) => a.vote - b.vote) as vote}
				<li class="rounded border p-2">
					{vote.user}@{vote.instance}
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
