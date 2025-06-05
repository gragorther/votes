import type { Vote } from './types/vote.type';

/**
 * Sorts votes based on the chosen mode.
 * @param votes Array of votes
 * @param opts Sorting options
 *   - by: "published" | "score"
 *   - descending: If true, sorts in descending order (for published or score)
 *   - downvotesFirst: If true, sorts downvotes before upvotes, then by published date (descending)
 */
export function sortVotes(
	votes: Vote[],
	opts?: { by?: 'published' | 'score'; descending?: boolean; downvotesFirst?: boolean }
): Vote[] {
	if (opts?.downvotesFirst) {
		return [...votes].sort((a, b) => {
			if (a.score !== b.score) {
				return a.score - b.score;
			}
			// If same score, newest first
			return new Date(b.published).getTime() - new Date(a.published).getTime();
		});
	}
	const { by = 'published', descending = false } = opts ?? {};
	return [...votes].sort((a, b) => {
		if (by === 'score') {
			return descending ? b.score - a.score : a.score - b.score;
		} else {
			const diff = new Date(b.published).getTime() - new Date(a.published).getTime();
			return descending ? -diff : diff;
		}
	});
}
