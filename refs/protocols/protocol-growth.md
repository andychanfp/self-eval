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
2. Read the appropriate framework ref for the user's `job` and `level`:
   - Product designer → `refs/framework/framework-design-ic.md` (Growth Area Exemplars section)
   - Software engineer (IC) → `refs/framework/framework-eng-ic.md` (Growth Area Exemplars section)
   - Engineering manager → `refs/framework/framework-eng-em.md` (Growth Area Exemplars section)
3. **Present exactly four options** using AskUserQuestion (single-select):
   - **Options 1–3**: The top 3 most suitable growth areas for the user's level. For each, write a label (the growth area name) and a one-sentence description explaining why it is relevant at this level, referencing the level-specific exemplar from the framework.
   - **Option 4**: "Describe my own" — user will type a free-text area in the next turn.
   - **Option 5**: "Help me brainstorm" — signal to run a short collaborative exploration before anchoring.
4. If the user picks option 1–3, use that growth area as the anchor.
5. If the user picks "Describe my own", ask one follow-up question to sharpen the specific behaviour or gap, then use the answer as the anchor.
6. If the user picks "Help me brainstorm", ask two targeted questions: (a) what felt hardest or most effortful this review period, and (b) what kind of impact they want to have in the next one. Use the answers to recommend a single growth area and confirm with the user before anchoring.

## Designer-specific seed categories

Use these when `job` is a product designer role. When recommending, select from this list based on what is highest-priority for the user's level (see Growth Area Exemplars in the appropriate framework ref). Do not present the full list — pick the 2–3 most relevant and explain why.

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

Read `refs/template.md` and the appropriate framework ref for the user's `job` (see Interview step 2). Use the Growth Area Exemplars section to calibrate framing by level. Apply the level-specific scope, responsibility, and accountability expectations.

Generate one first-person paragraph:
- Apply SBI structure: Situation → Behavior → Impact.
- Situation must name the specific moment when the gap was noticed or surfaced — a critique, a retro, a piece of feedback, a self-review. Not just a time period.
- Behavior sentences must state the concrete steps taken to address the gap — with active verbs and specific objects. Apply hard rule 2: no "worked on improving", "focused on developing", "made efforts to".
- Impact names what has concretely changed, or — if still in progress — the specific next step and timeframe.
- Frame as a development intention, not a failure — what was recognised, what is being built.
- Reference the matched principles from the cross-check (show them; do not name-drop).
- Apply the quality checklist from `refs/template.md` before emitting.
- Cap at 15 lines.
