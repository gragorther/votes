import { db } from '$lib/db';
import { createFederation, Dislike, Like, Undo } from '@fedify/fedify';
import { fedifyHook } from '@fedify/fedify/x/sveltekit';
import { RedisKvStore, RedisMessageQueue } from '@fedify/redis';
import Redis from 'ioredis';

const redis = new Redis(); // Configure as needed
const federation = createFederation<string>({
	kv: new RedisKvStore(redis),
	queue: new RedisMessageQueue(() => new Redis())
});

federation.setInboxListeners('/users/{identifier}/inbox', '/inbox').on(Like, async (ctx, like) => {
	const actor = await like.getActor(ctx);
	const actorUri = actor?.id?.toString();
	const actorName = actor?.preferredUsername || 'unknown';
	const displayName = actor?.name || actorName;

	const objectUri =
		typeof like.objectId === 'string' ? like.objectId : (like.objectId as any)?.id?.toString();

	if (!actorUri || !objectUri) {
		console.warn('Invalid Like activity');
		return;
	}

	const user = await db.user.upsert({
		where: { Username: actorUri },
		update: { Name: displayName.toString() },
		create: {
			Name: displayName.toString(),
			Username: actorUri
		}
	});

	await db.like.create({
		data: {
			Url: objectUri,
			Actor: actorUri,
			Type: 'Like',
			userId: user.Id
		}
	});
});
// .on(Dislike, async (ctx, dislike) => {
// 	// TODO: handle downvote
// })
// .on(Undo, async (ctx, undo) => {
// 	// TODO: handle vote removal
// });

// This is the entry point to the Fedify hook from the SvelteKit framework:
export const handle = fedifyHook(federation, (req) => 'context data');
