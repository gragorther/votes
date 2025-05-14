import { error, json } from '@sveltejs/kit';
import db from '$lib/db';
import type { RequestHandler } from './$types';

function splitAtLastAt(str: string): [string, string] {
  const idx = str.lastIndexOf('@');
  if (idx === -1) {
    return [str, ''];
  }
  return [str.slice(0, idx), str.slice(idx + 1)];
}

export const GET: RequestHandler = async ({ url }) => {
  //validation
  const userParam = url.searchParams.get('user');
  if (!userParam) {
    throw error(400, 'Missing user parameter');
  }

  const [name, instanceDomain] = splitAtLastAt(userParam);

  const postLike = await db.person.findFirst({
    where: {
      name,
      instance: { domain: instanceDomain }
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
