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
  console.log(`Getting user comment votes: ${userParam}`)

  const [name, instanceDomain] = splitAtLast(userParam, '@');

  const commentLike = await db.person.findFirst({
    where: {
      name:{
        equals: name, 
        mode: 'insensitive'
      },
      instance: { domain:{equals: instanceDomain, mode: 'insensitive'} }, 
    },
    select: {   
      comment_like: {
        select: {
          score: true,
          published: true,
          comment: { select: { ap_id: true } }
        },
        orderBy: { published: 'desc' }
      }
    }
  });

  if (!commentLike) {
    throw error(404, `No such user: ${name}@${instanceDomain}`);
  }

  return json({
    votes: commentLike.comment_like.map(({ score, published, comment }) => ({
      score,
      published,
      ap_id: comment.ap_id
    }))
  });
};
