import { error } from '@sveltejs/kit';
import type { PageLoad } from './$types';

export const load: PageLoad = async ({ fetch, params }) => {

  const res = await fetch(`/api/v1/user?q=${params.username}`);

  if (!res.ok) {
    throw error(404, 'User not found');
  }

  const user = await res.json();

  return { user, username: params.username };
};