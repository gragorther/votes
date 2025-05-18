<script lang="ts">
	import { formatDate } from '$lib/formatDate';
	let { time } = $props();
</script>

<time class="break-normal" datetime={time}>{formatDate(time)}</time>
