import { error, json } from '@sveltejs/kit';
import type { RequestHandler } from './$types';
import { getVotes } from '$lib/getVotes';
import { env } from '$env/dynamic/public';

export const GET: RequestHandler = async ({ url }) => {
	const commentUrl = url.searchParams.get('q');

	if (!commentUrl) throw error(400, 'Missing “q” query param');
	console.log(`Getting comment: ${commentUrl}`);

	const urlthing = new URL(commentUrl);
	const hostname = urlthing.hostname;
	const excluded = env.PUBLIC_EXCLUDED_INSTANCES
		? env.PUBLIC_EXCLUDED_INSTANCES.split(',').map((h) => h.trim())
		: [];
	console.log({ hostname, excluded });

	if (excluded.includes(hostname)) {
		console.log('Excluded hostname matched:', hostname);
		throw error(401, 'this instance is excluded from search results');
	}

	const response = await getVotes('comment', commentUrl);

	return json({ votes: response });
};
