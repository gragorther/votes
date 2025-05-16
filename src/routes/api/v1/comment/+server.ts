import { error, json } from '@sveltejs/kit';
import {db} from '$lib/db';
import type { RequestHandler } from './$types';
import { compile } from 'svelte/compiler';

export const GET: RequestHandler = async ({ url }) => {
  const commentUrl =  url.searchParams.get('q');
  if (!commentUrl) throw error(400, 'Missing “q” query param');

  const commentId = new URL(commentUrl).pathname.split('/').at(-1)
  const instance = new URL(commentUrl).host.toString()
  const response = await fetch(`https://${instance}/api/v3/comment?id=${commentId}`)
  const responseJson = await response.json()
  const apId = responseJson.comment_view?.comment?.ap_id;

  const commentWithLikes = await db.comment.findFirst({
    where: { ap_id: apId },
    select: {
      ap_id: true,
      comment_like: {
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

  if (!commentWithLikes) throw error(404, `comment not found: ${apId}`);

  return json({ likes: commentWithLikes.comment_like, apId: apId });
};
