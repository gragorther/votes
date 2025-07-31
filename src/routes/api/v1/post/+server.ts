import { error, json } from '@sveltejs/kit';
import type { RequestHandler } from './$types';
import { getVotes } from '$lib/getVotes';

import { env } from '$env/dynamic/public';
export const GET: RequestHandler = async ({ url }) => {
	const postUrl = url.searchParams.get('q');

	if (!postUrl) throw error(400, 'Missing “q” query param');

	const urlthing = new URL(postUrl);

	const hostname = urlthing.hostname;
	const excluded = env.PUBLIC_EXCLUDED_INSTANCES
		? env.PUBLIC_EXCLUDED_INSTANCES.split(',').map((h) => h.trim())
		: [];
	console.log({ hostname, excluded });

	if (excluded.includes(hostname)) {
		console.log('Excluded hostname matched:', hostname);
		throw error(401, 'this instance is excluded from search results');
	}

	console.log(`Getting post: ${postUrl}`);

	const response = await getVotes('post', postUrl);

	return json({ votes: response });
};
