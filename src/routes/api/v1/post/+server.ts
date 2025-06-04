import { error, json } from '@sveltejs/kit';
import type { RequestHandler } from './$types';
import { getVotes } from '$lib/getVotes';

export const GET: RequestHandler = async ({ url }) => {
	const postUrl = url.searchParams.get('q');

	if (!postUrl) throw error(400, 'Missing “q” query param');
	console.log(`Getting post: ${postUrl}`);

	const response = await getVotes('post', postUrl);

	return json({ votes: response });
};
