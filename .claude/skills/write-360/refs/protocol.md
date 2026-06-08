# write-360 Protocol

## Progress emission

Emit `Step X/6 — <title>` at the start of each step, unconditionally.

---

## Step-by-step protocol

**Step 1 — Collect inputs** `[model: sonnet]`

Read `name`, `role`, `type`, and `examples` from the invocation message or the calling skill's payload. If any required field (`name`, `role`, `type`) is missing, ask for it before proceeding. Produce: a filled input record.

**Step 2 — Check refusal conditions** `[model: sonnet]`

Scan the input record and examples for three conditions:

- **Protected characteristic**: any mention of age, gender, ethnicity, religion, health, family status, or similar
- **No specific behaviour**: only trait labels ("difficult", "quiet", "negative") with no named action in a named context
- **Personal attack**: language that characterises the person rather than describing what they did

If any condition fires, stop. Name the condition, quote the offending phrase, and ask the user to provide a concrete situation and observed behaviour. Do not proceed to Step 3 until the input is corrected. Produce: cleared status or refusal notice.

**Step 3 — Draft the SBI paragraph** `[model: sonnet]`

Load the appropriate Pandora framework file from `refs/framework/` based on the colleague's role (design IC → `framework-design-ic.md`, eng IC → `framework-eng-ic.md`, EM → `framework-eng-em.md`). Draft a 3–5 sentence feedback paragraph following SBI structure:

- **Situation**: when and in what project or context
- **Behaviour**: what the person did or said, specifically — not what they are
- **Impact**: effect on the team, the customer, or the product

For `strength` feedback: name what went well and why it mattered.
For `constructive` feedback: name the gap, the observed behaviour that created it, and a concrete direction to improve.

Anchor language to the Pandora framework where relevant — ownership, craft, customer focus, collaboration. Produce: draft feedback paragraph.

**Step 4 — Present draft and gate on approval** `[model: sonnet]`

Emit the formatted output block:

```
Name: <name>
Role: <role>
Type: <type>

<paragraph>
```

Ask: "Approve, or would you like one revision?"

- If approved → skip to Step 6
- If revision requested → Step 5

**Step 5 — Redraft with user's note** `[model: sonnet]`

Take the user's revision note. Redraft the paragraph incorporating the note. Emit the updated output block. This is the final draft — no further revision. Produce: revised feedback paragraph.

**Step 6 — Emit final output** `[model: sonnet]`

Emit the approved or revised formatted block as the final output. If called by another skill, return the block as the handoff payload.
