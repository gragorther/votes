import { error, json } from '@sveltejs/kit';
import {db} from '$lib/db';
import type { RequestHandler } from './$types';
import { compile } from 'svelte/compiler';

export const GET: RequestHandler = async ({ url }) => {
  const postUrl =  url.searchParams.get('q');
  if (!postUrl) throw error(400, 'Missing “q” query param');
  console.log(`Getting post: ${postUrl}`)

  const postId = new URL(postUrl).pathname.split('/').at(-1)
  const instance = new URL(postUrl).host.toString()
  const response = await fetch(`https://${instance}/api/v3/post?id=${postId}`)
  const responseJson = await response.json()
  const apId = responseJson.post_view?.post?.ap_id;

  const postWithLikes = await db.post.findFirst({
    where: { ap_id: apId },
    select: {
      ap_id: true,
      post_like: {
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

  if (!postWithLikes) throw error(404, `post not found: ${apId}`);

  return json({ likes: postWithLikes.post_like, apId: apId });
};
