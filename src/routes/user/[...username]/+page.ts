import type { PageLoad } from './$types';
import { error } from '@sveltejs/kit';

export const load: PageLoad = async ({ fetch, params }) => {
	const fetchWithError = async (url: string) => {
		const res = await fetch(url);
		if (!res.ok) {
			const msg = await res.json();
			throw error(res.status, msg);
		}
		return res.json();
	};

	const [postVotes, commentVotes, voteCount] = await Promise.all([
		fetchWithError(`/api/v1/user/posts?q=${params.username}`),
		fetchWithError(`/api/v1/user/comments?q=${params.username}`),
		fetchWithError(`/api/v1/user/voteCount?q=${params.username}`)
	]);

	return {
		postVotes,
		commentVotes,
		voteCount,
		username: params.username.toLowerCase()
	};
};
