<script lang="ts">
	let { children } = $props();
</script>

<div class="m-2 flex justify-center break-all">
	<ul class="mt-4 space-y-2">
		{@render children()}
	</ul>
</div>
