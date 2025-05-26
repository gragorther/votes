import type { PageLoad } from './$types';

export const load: PageLoad = async ({ fetch, params }) => {
	const postVotesPromise = fetch(`/api/v1/user/posts?q=${params.username}`).then((res) => {
		if (!res.ok) throw new Error('Failed to fetch post votes');
		return res.json();
	});

	const commentVotesPromise = fetch(`/api/v1/user/comments?q=${params.username}`).then((res) => {
		if (!res.ok) throw new Error('Failed to fetch comment votes');
		return res.json();
	});

	const voteCountPromise = fetch(`/api/v1/user/voteCount?q=${params.username}`).then((res) => {
		if (!res.ok) throw new Error('Failed to fetch total vote count');

		return res.json();
	});

	return {
		postVotes: postVotesPromise,
		commentVotes: commentVotesPromise,
		username: params.username.toLowerCase(),
		voteCount: voteCountPromise
	};
};
