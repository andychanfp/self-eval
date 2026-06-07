---
name: Output Template
description: SBI sentence stems, hard rules, quality checklist, and exemplars for self-eval paragraph generation
type: reference
---

# Output Template

## Model: SBI

Every paragraph follows the SBI structure: **Situation → Behavior → Impact**. The paragraph is one continuous block of prose. SBI is the internal skeleton, not a visible label.

### Situation (1–2 sentences)

Name the specific moment, event, or setting where the behavior occurred. A reader who was there should be able to place themselves in it.

- "In the [sprint / review / handoff meeting] for [project], [describe the state or problem that made the moment significant]."
- "After [specific trigger — retro finding, PM escalation, research session], [describe what the context required]."
- "When [named event] surfaced [specific gap or problem], [describe what that meant for the work]."

**Not this**: "During MYR 2026, I worked on a project that..."
**This**: "In the March stakeholder review for Vendor Hub, the PM flagged that five consecutive sprints had ended with late-stage design revisions."

### Behavior (2–4 sentences)

State the specific actions you took. One sentence = one action. Each must be verifiable — something a colleague could confirm.

- "I [active verb] [specific artifact or output] and [active verb] [specific method or activity] to [specific end]."
- "I synthesised [specific input] into [specific output] and presented it to [named stakeholder or group]."
- "I iterated on [artifact] based on [specific feedback source or evidence] before [handoff / launch / review]."

**Not this**: "I played a key role in improving the experience."
**This**: "I redesigned the filter interaction, ran 6 usability sessions, and iterated on two prototype rounds before aligning with engineering on a feasible scope."

### Impact (1–2 sentences)

State what changed as a direct result. Lead with a metric if one exists. Draw the line from behavior to outcome explicitly.

- "This [metric] — [brief interpretation of what it means for the user or business]."
- "The [artifact / ritual / change] [describe the concrete downstream effect]."
- "I'm still developing this — my next step is [specific action] by [specific timeframe]."

**Not this**: "The project had a positive impact on the business."
**This**: "Conversion on the restaurant listing page increased from 2.1% to 2.7% within two weeks of launch — above the vertical benchmark."

---

## Hard rules

These rules are non-negotiable. Violating any one of them invalidates the paragraph — fix it before emitting.

1. **One block per moment.** Each SBI paragraph captures one specific moment or event. If the user is describing two different moments, draft two candidate blocks and ask which is stronger. Do not compress.

2. **Behavior from evidence only.** State only what the user demonstrably did — actions a colleague could confirm. Prohibited verbs and phrases: "contributed to", "played a key role in", "helped drive", "was involved in", "worked towards", "supported the team in".

3. **Grounded situation.** The situation must name a specific setting (a meeting, a sprint, a milestone, a named event). A time period alone ("During MYR 2026…") does not qualify. If the user cannot name a specific moment, ask: "Can you name the meeting, sprint, or event where this happened?"

4. **Traceable impact.** The impact must be directly caused by the stated behavior — not correlated, not team-attributed. If the line from behavior to impact is unclear, ask the user to draw it before drafting.

---

## Quality checklist

Run this silently before emitting. Fix every failure before showing the paragraph.

| # | Check | Pass condition |
|---|-------|---------------|
| 1 | Situation is grounded | Names a specific moment, event, or meeting — not just a time period |
| 2 | Behavior uses active verbs + specific objects | Every sentence in the behavior block names what the user did and to what |
| 3 | No prohibited phrases | None of: "contributed to", "played a key role", "helped drive", "was involved in", "worked towards", "was part of" |
| 4 | Impact traces to behavior | The outcome follows directly from at least one stated behavior |
| 5 | One moment per block | Paragraph does not compress multiple distinct events |
| 6 | No AI vocabulary | None of: delve, leverage, foster, underscore, holistic, streamline, elevate, robust, unlock, crucial |
| 7 | Principle-anchored | At least one Pandora or design principle is reflected (shown, not labelled) |
| 8 | Under 15 lines | Count lines; trim if over |
| 9 | First person, varied structure | No two consecutive sentences begin with "I" |

---

## Rules (style)

- Write in first person throughout. No "we" as the subject of an action you personally took.
- Do not start two consecutive sentences with "I". Vary the sentence structure.
- Do not use principle names as adjectives ("I demonstrated Dive Deep by..."). Show the behavior; let the reader draw the connection.
- If any SBI section has no content from the interview, ask the user for it. Do not invent.

---

## Accomplishment exemplars

### Exemplar A — Metric-backed

> In the March stakeholder review for the restaurant discovery project, the listing page had a 2.1% conversion rate — 0.8 points below the food vertical benchmark — and the PM had escalated it as the squad's top Q1 priority. I audited the current flow against session recordings and identified three friction points at the filter step. I redesigned the filter interaction, ran 6 usability sessions to pressure-test the new model, and iterated on two prototype rounds before aligning with engineering on a feasible scope. Conversion on the listing page increased to 2.7% within two weeks of launch, moving the squad above the vertical benchmark.

### Exemplar B — Process change, no direct GMV metric

> After the Vendor Hub team's Q4 retrospective, the PM flagged that five consecutive sprints had ended with late-stage design revisions — designs were changed after engineering had begun development, costing an estimated two sprint-days per cycle. I proposed a brief-and-align ritual: a written design brief shared 48 hours before kickoff, followed by a 30-minute sync with the PM and tech lead. I authored the brief template and ran it across four consecutive sprints, tracking the number of post-kickoff scope changes each time. Late-stage revisions dropped from an average of three per sprint to zero over the pilot; the PM adopted the ritual as a standing squad process.

---

## Growth area exemplars

### Exemplar A — Recognised gap, active steps taken

> In a Q2 design critique, the chapter lead noted that my presentation of the new onboarding flow focused on what the designs looked like rather than why I made the decisions I did — two PMs in the room echoed this. I started attaching a one-page decision log to every critique deck: each entry naming the option considered, the user rationale for the choice, and the trade-off accepted. I applied this on three consecutive projects and asked one PM and one engineer to review whether it addressed the gap they had raised. Both confirmed the log made the rationale easier to engage with; I am applying it as a default on all active workstreams and will assess whether it reduces post-critique questions at my next chapter presentation.

### Exemplar B — Data fluency gap, self-directed learning

> When reviewing my work at the start of Q1 2026, I noticed I had not independently pulled analytics data for any of the three projects I had shipped — I had relied on the PM to surface relevant metrics and tell me whether the design had worked. I completed the internal data fluency onboarding module and asked the squad's data analyst to walk me through the funnel dashboard for the restaurant listing project. I then pulled the post-launch session data myself and presented a brief findings summary in the next sprint retro. That surfaced one unexpected drop-off point the PM had not flagged, which is now on the backlog. My next step is to pull post-launch data independently for the checkout redesign shipping in July — without being prompted.
