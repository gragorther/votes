import type { PageLoad } from './$types';
import { error } from '@sveltejs/kit';

export const load: PageLoad = async ({ fetch, params }) => {
	const res = await fetch(`/api/v1/comment?q=https://${params.comment_url}`);

	if (!res.ok) {
		throw error(res.status, res.json());
	}

	const comment = await res.json();

	return { comment, comment_url: params.comment_url };
};
