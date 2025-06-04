import { db } from '$lib/db';
import { error } from '@sveltejs/kit';

type TableName = 'comment' | 'post';

export async function getVotes(tableName: TableName, apId: string) {
	const relatedField = `${tableName}_like`;

	//@ts-ignore

	const response = await db[tableName].findFirst({
		where: { ap_id: apId },
		select: {
			ap_id: true,
			[relatedField]: {
				select: {
					score: true,
					published: true,
					person: {
						select: { name: true, instance: { select: { domain: true } } }
					}
				},
				orderBy: { published: 'desc' }
			}
		}
	});
	if (!response) {
		throw error(404, 'post not found');
	}
	return response[relatedField];
}
