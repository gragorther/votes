<script lang="ts">
	import { goto } from '$app/navigation';
	import { Loader } from 'lucide-svelte';
	let query: string = $state('');
	let query_type = $state('post');

	let input_placeholder = $derived.by(() => {
		//sets the input placeholder when query_type changes
		switch (query_type) {
			case 'post':
				return 'https://lemmy.world/post/12345';
			case 'comment':
				return 'https://lemmy.world/comment/12345';
			case 'user':
				return 'foo@bar.com';
		}
	});

	let redirectUrl = $derived(`/${query_type}/${query}`.replace(/https:\/\//g, ''));

	let loading = $state(false);
	let buttonColor = $state('bg-blue-500');

	function onSubmit(event: any) {
		buttonColor = 'bg-gray-400';
		loading = true;
	}
</script>

<div class="flex items-center justify-center">
	<div
		class="max-w-xl content-center justify-center overflow-auto rounded-2xl border-2 border-pink-400 p-4"
	>
		<p>Use the following form to get votes</p>
		<form
			class="mt-2 flex flex-col flex-wrap justify-center gap-2 select-none"
			action={redirectUrl}
			method="GET"
			onsubmit={onSubmit}
		>
			<fieldset disabled={loading}>
				<input
					type="text"
					bind:value={query}
					placeholder={input_placeholder}
					class="self-stretch rounded-md border-2 border-orange-500 text-center"
					onfocus={(e) => {
						const input = e.target as HTMLInputElement | null;
						if (input) {
							input.select();
						}
					}}
					required
				/><span>
					<fieldset>
						<input
							type="radio"
							id="post"
							name="submit-type"
							value="post"
							checked
							bind:group={query_type}
						/>
						<label for="post">Post</label>
						<input
							type="radio"
							id="comment"
							name="submit-type"
							value="comment"
							bind:group={query_type}
						/>
						<label for="comment">Comment</label>
						<input type="radio" id="user" name="submit-type" value="user" bind:group={query_type} />
						<label for="user">User</label>
					</fieldset>
				</span>
				<button
					type="submit"
					class="cursor-pointer self-center rounded {buttonColor} px-4 py-2 text-white"
				>
					Get Votes
				</button>
				{#if loading}
					<Loader class="inline animate-spin" />
				{/if}
			</fieldset>
		</form>
	</div>
</div>
