<script lang="ts">
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
			const response = await fetch('http://api.gregtech.eu/api/votes', {
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
				class="self-center text-center"
				required
			/>
			<button
				type="submit"
				class="cursor-pointer self-center rounded bg-blue-500 px-4 py-2 text-white"
			>
				Get Votes
			</button>
		</form>
	</div>
</div>

{#if error}
	<p class="mt-4 text-red-500">{error}</p>
{/if}

{#if votes.length}
	<div class="m-2 flex justify-center break-all">
		<ul class="mt-4 space-y-2">
			{#each votes as vote}
				<li class=" rounded border p-2">
					{vote.user}@{vote.instance}: {vote.vote}
				</li>
			{/each}
		</ul>
	</div>
{/if}
