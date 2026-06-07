# Protocol: Growth Areas

## Global growth area categories

These are company-wide categories derived from the Pandora principles. Use them as a first-pass menu to help the user orient before presenting level-specific exemplars.

| Principle | Categories |
|-----------|------------|
| Own It | Ownership, Prioritisation, Resourcefulness |
| Dive Deep | Data Fluency, Domain Depth, Execution Quality |
| Deliver Value Fast | Pace, Iteration, Adaptability |
| Raise the Bar | Standard Setting, Feedback, Team Growth |
| Bring Good Vibes | Collaboration, Empathy, Team Culture |
| Stay Humble | Self-reflection, Learning Agility, Open-mindedness |

## Interview

1. Read `user-cache.json` to get `level` and `job`.
2. Read `refs/framework-design-ic.md` — Growth Area Exemplars section — for the user's `level`.
3. **Present exactly four options** using AskUserQuestion (single-select):
   - **Options 1–3**: The top 3 most suitable growth areas for the user's level. For each, write a label (the growth area name) and a one-sentence description explaining why it is relevant at this level, referencing the level-specific exemplar from the framework.
   - **Option 4**: "Describe my own" — user will type a free-text area in the next turn.
   - **Option 5**: "Help me brainstorm" — signal to run a short collaborative exploration before anchoring.
4. If the user picks option 1–3, use that growth area as the anchor.
5. If the user picks "Describe my own", ask one follow-up question to sharpen the specific behaviour or gap, then use the answer as the anchor.
6. If the user picks "Help me brainstorm", ask two targeted questions: (a) what felt hardest or most effortful this review period, and (b) what kind of impact they want to have in the next one. Use the answers to recommend a single growth area and confirm with the user before anchoring.

## Designer-specific seed categories

Use these when `job` is a product designer role. When recommending, select from this list based on what is highest-priority for the user's level (see Growth Area Exemplars in `refs/framework-design-ic.md`). Do not present the full list — pick the 2–3 most relevant and explain why.

| Category | Short description |
|----------|------------------|
| **Craft depth** | Interaction design, visual quality, or end-to-end delivery rigour |
| **Product discovery** | Problem framing, opportunity sizing, and research before solutioning |
| **PM collaboration** | Shaping problem briefs, influencing prioritisation, navigating scope trade-offs |
| **Data fluency** | Using analytics, funnels, and experiment data to validate design decisions |
| **Design communication** | Storytelling, critique, and stakeholder negotiation |
| **Facilitation** | Running workshops, alignment sessions, and decision-making rituals |
| **AI-nativeness** | Using AI in the design workflow and designing AI-powered product surfaces |
| **Chapter contribution** | Shaping design team rituals, standards, or craft practice |
| **Engineering collaboration** | Resolving feasibility constraints early; handoff quality and QA |
| **Coaching & mentorship** | Developing junior designers through structured feedback and skill-building |

Store the selected growth area topic.

## Cross-check values

Read `refs/principles/principles-pandora.md` and `refs/principles/principles-design.md`. Match the growth area against each principle. List the matched items to the user.

## Draft paragraph

Read `refs/output-template.md` and `refs/framework-design-ic.md`. Use the Growth Area Exemplars section to calibrate framing by level. If `job` in `user-cache.json` is a product designer role, apply the level-specific scope, responsibility, and accountability expectations.

Generate one first-person paragraph:
- Apply STAR structure: Situation → Task → Action → Result.
- Anchor the Situation sentence to `review_period` (e.g. "During MYR 2026…").
- Frame as a development intention, not a failure — what was recognised, what is being built.
- Reference the matched principles from the cross-check.
- Cap at 15 lines.
