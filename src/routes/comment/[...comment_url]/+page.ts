import type { PageLoad } from './$types';

export const load: PageLoad = async ({ fetch, params }) => {

  const res = await fetch(`/api/v1/comment?q=${params.comment_url}`);

  if (!res.ok) {
    throw new Error(`Failed to fetch comment: ${res.status}`);
  }

  const comment = await res.json();

  return { comment, comment_url: params.comment_url };
};
