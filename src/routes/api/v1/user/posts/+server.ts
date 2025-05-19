import { error, json } from '@sveltejs/kit';
import {db} from '$lib/db';
import type { RequestHandler } from '../$types';
import { splitAtLast } from '$lib/splitAtLast';



export const GET: RequestHandler = async ({ url }) => {
  //validation
  const userParam = url.searchParams.get('q');
  if (!userParam) {
    throw error(400, 'Missing query parameter');
  }
  console.log(`Getting user post votes: ${userParam}`)

  const [name, instanceDomain] = splitAtLast(userParam, '@');

  const postLike = await db.person.findFirst({
    where: {
      name:{
        equals: name, 
        mode: 'insensitive'
      },
      instance: { domain:{equals: instanceDomain, mode: 'insensitive'} }, 
    },
    select: {
      post_like: {
        select: {
          score: true,
          published: true,
          post: { select: { ap_id: true } }
        },
        orderBy: { published: 'desc' }
      }
    }
  });

  if (!postLike) {
    throw error(404, `No such user: ${name}@${instanceDomain}`);
  }

  return json({
    votes: postLike.post_like.map(({ score, published, post }) => ({
      score,
      published,
      ap_id: post.ap_id
    }))
  });
};
