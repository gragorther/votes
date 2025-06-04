<script lang="ts">
	import { Loader } from 'lucide-svelte';
	let query: string = $state('');
	let query_type: 'post' | 'comment' | 'user' = $state('post');

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

<svelte:head><title>Lemvotes</title></svelte:head>

<div class=" mt-6 flex items-center justify-center">
	<div
		class="w-full max-w-md content-center justify-center overflow-auto rounded-2xl border-2 border-pink-400 p-4"
	>
		<p
			class="{query_type == 'comment' || query_type == 'post'
				? 'text-justify'
				: 'text-center'} md:h-29"
		>
			Use the following form to get votes{#if query_type == 'comment' || query_type == 'post'}
				, make sure the {query_type} URL is from the {query_type}er's instance. You can do that in
				the official Lemmy UI by clicking on the
				<img
					class="inline h-6 w-auto"
					src="https://upload.wikimedia.org/wikipedia/commons/thumb/9/93/Fediverse_logo_proposal.svg/1024px-Fediverse_logo_proposal.svg.png"
					alt="fediverse logo"
				/>
				icon. The {query_type} URL can be from any fediverse software, not just Lemmy.
			{/if}
		</p>
		<form
			class="mt-2 flex flex-col flex-wrap justify-center select-none"
			action={redirectUrl}
			method="GET"
			onsubmit={onSubmit}
		>
			<fieldset disabled={loading} class="flex flex-col gap-1.5">
				<input
					type="text"
					bind:value={query}
					placeholder={input_placeholder}
					class="w-full self-stretch rounded-md border-2 border-orange-500 text-center"
					onfocus={(e) => {
						const input = e.target as HTMLInputElement | null;
						if (input) {
							input.select();
						}
					}}
					required
				/>
				<fieldset class="my-1 flex flex-row items-center justify-center gap-2">
					{#each ['post', 'comment', 'user'] as type}
						<div>
							<input
								type="radio"
								id={type}
								name="submit-type"
								value={type}
								bind:group={query_type}
								checked={type === 'post'}
								class="peer sr-only"
							/>
							<label
								for={type}
								class="cursor-pointer rounded-full px-4 py-2 text-sm font-medium text-gray-300 transition-all duration-300 ease-in-out peer-checked:bg-blue-600 peer-checked:text-white"
							>
								{type.charAt(0).toUpperCase() + type.slice(1)}
							</label>
						</div>
					{/each}
				</fieldset>
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
