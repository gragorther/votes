import { error, json } from '@sveltejs/kit';
import db from '$lib/db';
import type { RequestHandler } from './$types';

export const GET: RequestHandler = async ({ url }) => {
  const apId = url.searchParams.get('q');
  if (!apId) throw error(400, 'Missing “q” query param');

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

  return json({ likes: postWithLikes.post_like });
};
