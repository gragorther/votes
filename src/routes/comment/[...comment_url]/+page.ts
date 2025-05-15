// src/routes/your-route/+page.ts
import type { PageLoad } from './$types';

export const load: PageLoad = async ({ fetch, params }) => {


  const encoded = encodeURIComponent(params.comment_url);

  // 3. Fetch your backend endpoint:
  const res = await fetch(`/api/v1/comment/${encoded}`);

  if (!res.ok) {
    throw new Error(`Failed to fetch comment: ${res.status}`);
  }

  // 4. Parse JSON (or text, whatever your API returns)
  const comment = await res.json();

  return { comment };
};
