import { error } from '@sveltejs/kit';
import db from '$lib/db';
import type { RequestHandler } from './$types';

export const GET: RequestHandler = async ({ url }) => {
	const min = Number(url.searchParams.get('min') ?? '0');
	const max = Number(url.searchParams.get('max') ?? '1');

    const username = url.searchParams.get('user')
    const findUser = await db.post_like.findFirst({
        where: {
          posts: {
            some: {
              likes: {
                gt: 100,
              },
            },
          },
        },
        orderBy: {
          id: 'desc',
        },
      })
    
    return new Response(user)
};