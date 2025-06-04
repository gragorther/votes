import { error, json } from '@sveltejs/kit';
import { db } from '$lib/db';
import type { RequestHandler } from './$types';
import { getVotes } from '$lib/getVotes';

export const GET: RequestHandler = async ({ url }) => {
	const commentUrl = url.searchParams.get('q');

	if (!commentUrl) throw error(400, 'Missing “q” query param');
	console.log(`Getting comment: ${commentUrl}`);

	const response = await getVotes('comment', commentUrl);

	return json({ votes: response });
};
