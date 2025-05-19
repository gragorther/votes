import { error } from '@sveltejs/kit';
import type { PageLoad } from './$types';

export const load: PageLoad = async ({ fetch, params }) => {

  const resPosts = await fetch(`/api/v1/user/posts?q=${params.username}`);
  const resComments = await fetch(`/api/v1/user/comments?q=${params.username}`)

  if (!resPosts.ok || !resComments.ok) {
    throw error(404, 'User not found');
  }

  const userPostVotes = await resPosts.json();
  const userCommentVotes = await resComments.json()

  return { postVotes: userPostVotes,commentVotes: userCommentVotes, username: params.username.toLowerCase() };
};