// src/routes/api/comment-votes/+server.ts
import { error, json } from '@sveltejs/kit';
import { getUserVotes } from '$lib/getUserVotes';
import type { RequestHandler } from './$types';

export const GET: RequestHandler = async ({ url }) => {
	const userParam = url.searchParams.get('q');
	if (!userParam) {
		throw error(400, 'Missing query parameter');
	}

	const votes = await getUserVotes(userParam, 'comment_like', 'comment');

	if (!votes) {
		throw error(404, `No such user: ${userParam}`);
	}

	return json({ votes });
};
