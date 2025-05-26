import { error, json } from '@sveltejs/kit';
import { db } from '$lib/db';
import type { RequestHandler } from './$types';
import { splitAtLast } from '$lib/splitAtLast';

export const GET: RequestHandler = async ({ url }) => {
	const userParam = url.searchParams.get('q');

	if (!userParam) throw error(400, 'Missing “q” query param');
	console.log(`Getting vote count for: ${userParam}`);
	const [name, instanceDomain] = splitAtLast(userParam, '@');

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

	if (!person) throw error(404, `User not found: ${userParam}`);

	const [postLikesCount, commentLikesCount] = await Promise.all([
		db.post_like.count({ where: { person_id: person.id } }),
		db.comment_like.count({ where: { person_id: person.id } })
	]);

	return json({ voteCount: postLikesCount + commentLikesCount });
};
