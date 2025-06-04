import { db } from '$lib/db';
import { splitAtLast } from '$lib/splitAtLast';
import { error } from '@sveltejs/kit';

type VoteType = 'comment_like' | 'post_like';
type RelatedField = 'comment' | 'post';

export async function getUserVotes(
	username: string,
	voteType: VoteType,
	relatedField: RelatedField
) {
	const [name, instanceDomain] = splitAtLast(username, '@');

	const user = await db.person.findFirst({
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
			[voteType]: {
				select: {
					score: true,
					published: true,
					[relatedField]: {
						select: {
							ap_id: true
						}
					}
				},
				orderBy: {
					published: 'desc'
				}
			}
		}
	});

	if (!user) {
		return error(404, 'user not found');
	}

	return user[voteType].map((vote) => ({
		score: vote.score,
		published: vote.published,
		//@ts-ignore
		ap_id: vote[relatedField].ap_id
	}));
}
