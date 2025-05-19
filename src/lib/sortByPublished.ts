import type { Vote } from "./types/vote.type";

export function sortByPublished(votes: Vote[], opts?: { descendingTime?: boolean }): Vote[] {
  const { descendingTime = false } = opts ?? {};
  return [...votes].sort((a, b) => {
    if (a.score !== b.score) {
      return a.score - b.score;
    }
    const diff = new Date(a.published).getTime()
               - new Date(b.published).getTime();
    return descendingTime ? -diff : diff;
  });
}
