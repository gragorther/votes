import { error } from '@sveltejs/kit';
import type { PageLoad } from './$types';

export const load: PageLoad = async ({ fetch, params }) => {
	const res = await fetch(`/api/v1/post?q=https://${params.post_url}`);

	if (!res.ok) {
		throw error(404, 'Post not found');
	}

	const post = await res.json();

	return { post, post_url: params.post_url };
};
