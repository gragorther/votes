import { createFederation } from '@fedify/fedify';
import { fedifyHook } from '@fedify/fedify/x/sveltekit';
import { RedisKvStore, RedisMessageQueue } from '@fedify/redis';
import Redis from 'ioredis';
const redis = new Redis(); // Configure as needed
const federation = createFederation<string>({
	kv: new RedisKvStore(redis),
	queue: new RedisMessageQueue(() => new Redis())
});

// This is the entry point to the Fedify hook from the SvelteKit framework:
export const handle = fedifyHook(federation, (req) => 'context data');
