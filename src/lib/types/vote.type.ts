export interface Vote {
	/** The ActivityPub object ID that was voted on */
	ap_id: string;

	/**
	 * The vote’s score:
	 *  - `+1` for an upvote
	 *  - `-1` for a downvote
	 */
	person: {
		name: string;
		instance: {
			domain: string;
		};
	};
	score: number;

	/**
	 * When the vote happened.
	 * Stored as an ISO‑8601 string (e.g. `"2025-05-18T14:23:00Z"`),
	 * but you could also use a numeric timestamp if you prefer.
	 */
	published: string;
}
