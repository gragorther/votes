import type { Vote } from './types/vote.type';

/**
 * Sorts votes based on the chosen mode.
 * @param votes Array of votes
 * @param opts Sorting options
 *   - descending: If true, sorts in descending order (for published or score)
 *   - downvotesFirst: If true, sorts downvotes before upvotes, then by published date (descending or ascending based on 'descending')
 */
export function sortVotes(
	votes: Vote[],
	opts?: { descending?: boolean; downvotesFirst?: boolean }
): Vote[] {
	const { descending = false, downvotesFirst = false } = opts ?? {};
	if (downvotesFirst) {
		return [...votes].sort((a, b) => {
			if (a.score !== b.score) {
				return a.score - b.score;
			}
			// If same score, sort by published, respect descending
			const diff = new Date(b.published).getTime() - new Date(a.published).getTime();
			return descending ? diff : -diff;
		});
	}
	return [...votes].sort((a, b) => {
		const diff = new Date(b.published).getTime() - new Date(a.published).getTime();
		return descending ? diff : -diff;
	});
}
