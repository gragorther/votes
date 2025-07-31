import { error, json } from '@sveltejs/kit';
import { getUserVotes } from '$lib/getUserVotes';
import type { RequestHandler } from './$types';
import { env } from '$env/dynamic/public';
import { splitAtLast } from '$lib/splitAtLast';

export const GET: RequestHandler = async ({ url }) => {
	const userParam = url.searchParams.get('q');
	if (!userParam) {
		throw error(400, 'Missing query parameter');
	}

	const [username, instancedomain] = splitAtLast(userParam, '@');

	if (env.PUBLIC_EXCLUDED_INSTANCES.split(',').includes(instancedomain)) {
		throw error(401, "user's instance has been excluded from search results");
	}

	const votes = await getUserVotes(userParam, 'post_like', 'post');

	if (!votes) {
		throw error(404, `No such user: ${userParam}`);
	}

	return json({ votes });
};
