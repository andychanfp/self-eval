# Protocol: Accomplishments

## Interview

Ask the following questions in sequence. If an answer is vague, ask once for a concrete example before moving on.

1. **Project name.**
2. **Description of work done** — what the designer specifically did, not what the team delivered.
3. **Current status** — estimated or actual launch date.
4. **GMV impact** — "Did this project have a direct GMV impact? If yes, what was the figure or estimated range?" If unknown or not applicable, note it and proceed without blocking.
5. **Other metrics** — "Are there other metrics that capture the impact? (e.g. user satisfaction score, error rate, time saved, conversion rate, NPS, task completion rate)" — accept all they name.

Produce a filled project record: `name`, `description`, `status`, `gmv_impact` (value or null), `metrics` (list or empty).

## Cross-check values

Read `refs/principles/principles-pandora.md` and `refs/principles/principles-design.md`. Match the project record against each principle. List the matched items to the user.

## Draft paragraph

Read `refs/output-template.md`. If `job` in `user-cache.json` is a product designer role (e.g. "product designer", "associate product designer", "senior product designer"), also read `refs/framework-design-ic.md` and apply the framing rules for the user's `level` — scope, responsibility, and accountability must match the level description.

Generate one first-person paragraph:
- Apply STAR structure: Situation → Task → Action → Result.
- Anchor the Situation sentence to `review_period` (e.g. "During MYR 2026…").
- Reference the matched principles from the cross-check.
- Cap at 15 lines.
