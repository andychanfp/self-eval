# write-360 Protocol

## Progress emission

Emit `Step X/6 — <title>` at the start of each step, unconditionally.

---

## Step-by-step protocol

**Step 1 — Triage**

Ask the following questions in sequence, one at a time, waiting for each answer before asking the next:

1. **Who is this for?** — Ask for the colleague's name and role.
2. **Feedback type** — "Are you writing constructive feedback or highlighting a strength?" (select: Strength / Constructive)
3. **Specific feedback points** — "Do you have specific feedback points or examples in mind?" (free-text prose; OK to leave blank)
4. **Slack scan** — "Should I scan Slack for context on [name]?" (Yes / No)

Produce: a filled triage record — `name`, `role`, `type`, `examples` (may be empty), `slack_scan` (bool).

---

**Step 2 — Slack scan (conditional)**

If `slack_scan` is true: invoke `/lemme-slack` with the colleague's name as the argument. Collect the output and append it to `examples`.

If `slack_scan` is false: skip this step.

Produce: enriched examples (original prose + any Slack evidence).

---

**Step 3 — Check refusal conditions**

Scan the triage record and examples for:

- **Protected characteristic**: any mention of age, gender, ethnicity, religion, health, family status, or similar
- **No specific behaviour**: only trait labels ("difficult", "quiet", "negative") with no named action in a named context
- **Personal attack**: language that characterises the person rather than describing what they did

If any condition fires: stop. Name the condition, quote the offending phrase, and ask the user to provide a concrete situation and observed behaviour. Do not proceed to Step 4 until the input is corrected.

Produce: cleared status or refusal notice.

---

**Step 4 — Surface feedback points**

Load `refs/template.md` for the SBI model and Pandora principles anchor table. Load the appropriate framework file from `refs/framework/` based on role (design IC → `framework-design-ic.md`, eng IC → `framework-eng-ic.md`, EM → `framework-eng-em.md`).

Analyse the examples and any Slack evidence. Generate a table of 3–6 potential feedback points:

| # | Situation | Behaviour | Potential impact |
|---|-----------|-----------|-----------------|
| 1 | … | … | … |

Ask: "Which of these would you like to build the paragraph from? Select by number, rephrase a row, or add your own."

Produce: user-selected or user-revised feedback points.

---

**Step 5 — Draft the SBI paragraph**

Using the selected feedback points, draft a 3–5 sentence feedback paragraph following SBI structure:

- **Situation**: when and in what project or context
- **Behaviour**: what the person did or said, specifically — not what they are
- **Impact**: effect on the team, the customer, or the product; reflect a Pandora principle through the behaviour (show, don't label)

For `strength` feedback: name what went well and why it mattered.
For `constructive` feedback: acknowledge what the person did well → name the specific gap → open a forward path using "even more" or "even better" framing toward a concrete outcome.

Produce: draft feedback paragraph.

---

**Step 6 — Gate and finalize**

Emit the formatted output block:

```
Name: <name>
Role: <role>
Type: <type>

<paragraph>
```

Ask: "Approve, or would you like one revision?"

- If approved → the block above is the final output
- If revision requested → take the user's note, redraft incorporating it, emit the updated block as final (no further revision)

If called by another skill, return the final block as the handoff payload.
