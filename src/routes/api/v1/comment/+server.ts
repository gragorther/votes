import { error, json } from '@sveltejs/kit';
import db from '$lib/db';
import type { RequestHandler } from './$types';
import type { ResolveObject } from "lemmy-js-client";
import { LemmyHttp } from 'lemmy-js-client';
export const GET: RequestHandler = async ({ url }) => {
    const commentParam = url.searchParams.get('q');
    if(!commentParam){
        throw error(400, 'missing query parameter')
    }

    const instanceDomain = new URL(commentParam).host

    const 

    const commentLike = db.post.findFirst({
      where:{

      }  
    })

}