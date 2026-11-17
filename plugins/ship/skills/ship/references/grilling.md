# Grilling

Map the request as a **design tree**, then ask it in **rounds**: a round puts the
whole **frontier** — every decision whose prerequisites are settled — to the
user, numbered, each with your recommended answer, phrased so "yes" accepts it.
Answers push the frontier outward; ask the next round only after they arrive.

- **Facts are your job; decisions are the user's.** Look up anything the repo,
  the tools, or a versioned doc can answer. Never ask for it.
- Done when the frontier is empty: no branch unvisited, nothing silently assumed.

Ship's intake caps this at three rounds and records what is left under
**Assumed** in `brief.md` — one answer session, not an interrogation.
