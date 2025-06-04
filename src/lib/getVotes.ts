import { db } from '$lib/db';

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
	return response[relatedField];
}
