<script lang="ts">
	let { children } = $props();
</script>

<li class="rounded border break-normal p-1 text-center">
	{@render children()}
</li>
