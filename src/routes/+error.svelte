<script lang="ts">
	import { page } from '$app/state';
</script>

<title>Lemvotes - {page.error!.message}</title>
<img
	class="self-center"
	src="https://http.cat/{page.status}"
	alt="Error: {page.error!.message}, {page.status}"
/>
