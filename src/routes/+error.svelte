<script lang="ts">
	import { page } from '$app/state';
</script>

<svelte:head>
	<title>Lemvotes - {page.error!.message}</title>
</svelte:head>
<div class="mt-2 flex flex-col justify-center">
	<h2 class="text-2xl">{page.error!.message}</h2>
	<img
		class="self-center"
		src="https://http.cat/{page.status}"
		alt="Error: {page.error!.message}, {page.status}"
	/>
</div>
