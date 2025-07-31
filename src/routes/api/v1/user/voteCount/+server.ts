import { error, json } from '@sveltejs/kit';
import { db } from '$lib/db';
import type { RequestHandler } from './$types';
import { splitAtLast } from '$lib/splitAtLast';
import { env } from '$env/dynamic/public';

export const GET: RequestHandler = async ({ url }) => {
	const userParam = url.searchParams.get('q');

	if (!userParam) throw error(400, 'Missing “q” query param');
	console.log(`Getting total vote count for: ${userParam}`);
	const [name, instanceDomain] = splitAtLast(userParam, '@');

	if (env.PUBLIC_EXCLUDED_INSTANCES.split(',').includes(instanceDomain)) {
		throw error(401, "user's instance has been excluded from search results");
	}

	const person = await db.person.findFirst({
		where: {
			name: {
				equals: name,
				mode: 'insensitive'
			},
			instance: {
				domain: {
					equals: instanceDomain,
					mode: 'insensitive'
				}
			}
		},
		select: {
			id: true
		}
	});
	if (!person) {
		throw error(404, 'User not found');
	}

	// downvotes
	const downvotedPosts = await db.post_like.count({
		where: {
			person_id: person.id,
			score: -1
		}
	});

	//upvotes
	const upvotedPosts = await db.post_like.count({
		where: {
			person_id: person.id,
			score: 1
		}
	});

	const downvotedComments = await db.comment_like.count({
		where: {
			person_id: person.id,
			score: -1
		}
	});

	const upvotedComments = await db.comment_like.count({
		where: {
			person_id: person.id,
			score: 1
		}
	});

	return json({
		posts: { upvotes: upvotedPosts, downvotes: downvotedPosts },
		comments: { upvotes: upvotedComments, downvotes: downvotedComments }
	});
};
