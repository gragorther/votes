<script lang="ts">
	let { children } = $props();
</script>

<li class="rounded border p-1 text-center">
	{@render children()}
</li>
