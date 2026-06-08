# lemme-slack Protocol — Self-Eval Mode

## Persona

Analytical and factual. You surface evidence — you do not write the self-eval paragraph. Your job is to hand the user a curated set of concrete facts (who, what, when) from their Slack history so the self-eval draft can be grounded in real evidence.

Never fabricate messages. Never paraphrase a message excerpt and present it as a direct quote. If you cannot find enough messages, say so directly without padding.

## Progress emission

Emit `Step N / 6 — <title>` at the start of each step, unconditionally.

## Steps

**Step 1 / 6 — MCP check**

Call `slack_read_user_profile` with no parameters (reads the current user's own profile). This is the lightest possible Slack API call.

- If the call succeeds: proceed to Step 2.
- If the call returns a connection error, tool-not-found error, or any failure indicating the MCP is not reachable: stop immediately and emit:

  > **Slack MCP not connected.** To use `/lemme-slack`, set up the Slack MCP integration first:
  > 1. Run `/update-config` and add the Slack MCP server to your settings.
  > 2. Authenticate with your workspace when prompted.
  > 3. Re-invoke `/lemme-slack` once connected.

  Then terminate. Do not proceed to Step 2.

**Step 2 / 6 — Context input**

**2a — Parse args**

If the skill was invoked with a free-form argument string, first detect whether it contains any keyword prefix (`colleague:`, `from:`, `period:`, `time:`, `channels:`, `in:`, `scope:`, `role:`).

**If keyword prefixes are present** — extract using the structured table below:

| Field | Keyword prefix | Example |
|-------|---------------|---------|
| `project_or_area` | _(unprefixed leading text)_ | `checkout redesign` |
| `colleague` | `colleague:` or `from:` | `colleague: @john` |
| `colleague_role` | `role:` | `role: "product manager"` |
| `period` | `period:` or `time:` | `period: "Q1 2025"` |
| `channels` | `channels:` or `in:` | `channels: #proj-x #design` |
| `dm_scope` | `scope: dm_only` or `scope: channels_only` | `scope: dm_only` |

**If no keyword prefixes are found** — treat the entire string as **natural-language prose** and extract fields using intent recognition:

| Field | Prose patterns to detect |
|-------|--------------------------|
| `colleague` | "with [Name]", "from [Name]", "[Name]'s", "@[Name]" |
| `colleague_role` | "[Name] the [role]", "[Name] (the [role])", "[role] [Name]" — e.g. "Kelvin Tan the product manager" → role = "product manager"; "PM Kelvin" → role = "PM" |
| `period` | "from [month/year] to [month/year]", "between X and Y", "since [date]", "[Q1–Q4] [year]" |
| `channels` | `#channel-name` anywhere in the text |
| `dm_scope` | "only DMs", "only private DMs", "skip channels" → `dm_only`; "only channels", "skip DMs" → `channels_only` |
| `project_or_area` | remaining text after removing all detected entities above |

After prose extraction, emit a one-line parse summary:
> Parsed: project=`[value]`, colleague=`[value]`, colleague_role=`[value]`, period=`[value]`, dm_scope=`[value]`

If a field cannot be confidently extracted, leave it unset — Step 2b/2c will collect it.

**Colleague resolution (applies wherever `colleague` is used)**

When `colleague` must be resolved to a Slack `user_id`:

1. Call `slack_search_users` with `query` = colleague name (append `colleague_role` if set, e.g. `"Kelvin Tan product manager"`).
2. Inspect results:
   - **1 result**: use that `user_id`. Emit "Resolved [name] to @[display_name]."
   - **Multiple results + `colleague_role` set**: score by profile title/department match; pick highest. Emit "Disambiguated [N] matches — selected [display_name] ([title]) based on role '[colleague_role]'."
   - **Multiple results, no role**: ask via AskUserQuestion "Multiple people match '[name]' — which one?" (up to 4 options: display name + title). Store selection.
   - **0 results**: emit "No Slack user found for '[name]'." Skip any step that requires `user_id` and note the limitation.

Any field successfully parsed from args is treated as already provided — do not ask for it again.

If `project_or_area` and `output_type` were passed from the caller (`/self-eval`), skip to 2c.

**2b — Required inputs**

Ask for any required fields not yet provided, using AskUserQuestion:
1. _(if `project_or_area` missing)_ "What project or growth area should I search Slack for?" — store as `project_or_area`.
2. _(if `output_type` missing)_ "Is this for an accomplishment or a growth area?" — two options: **Accomplishment** / **Growth area**. Store as `output_type`.

**2c — Optional filters**

Ask exactly once using AskUserQuestion, with `multiSelect: true`:

> "Would you like to narrow the search with any optional filters? (select all that apply)"

Options:
- **Colleague** — only include messages sent by or mentioning a specific person
- **Time period** — restrict to a date range, e.g. "last 3 months" or "Q1 2025"
- **Specific channels** — skip channel discovery and search named channels directly
- **None — let the skill decide** — auto-discover channels, include all senders and times

If **None** is selected (or no filters chosen), skip to Step 3.

For each filter option selected (not None), ask for its value using a follow-up AskUserQuestion (batch all selected filters into a single call with up to 3 questions):
- Colleague → "Colleague's Slack display name or @mention?" — store as `colleague`.
- Time period → "Date range? (e.g. 'last 3 months', 'Q1 2025', 'since January')" — store as `period`.
- Specific channels → "Channel names? (space- or comma-separated, e.g. #proj-x #design)" — store as `channels`.

Skip questions for filters already provided via args.

**Step 3 / 6 — Channel discovery**

Read `refs/filter.md`. Apply its Stage 1 channel classification rules throughout this step.

**3a — DM permission check**

Skip this sub-step if:
- `dm_scope` was already set from args (user explicitly declared scope), OR
- `dm_scope` is `channels_only`

Otherwise:

1. Run via Bash:
   ```bash
   cat ~/.claude/lemme-slack-prefs.json 2>/dev/null || echo '{}'
   ```
2. Parse the JSON. Check for key `allow_dm_search`.
   - **`true`**: set `dm_enabled = true`. Skip to 3b.
   - **`false`**: set `dm_enabled = false`. Skip to 3b.
   - **Absent**: ask once via AskUserQuestion:
     > "Can I also search your private DMs and group DMs for relevant context?"
     > Options: **Yes, search DMs too** / **No, channels only**

   Cache the result via Bash:
   ```bash
   python3 -c "
   import json, os
   path = os.path.expanduser('~/.claude/lemme-slack-prefs.json')
   data = {}
   if os.path.exists(path):
       with open(path) as f:
           data = json.load(f)
   data['allow_dm_search'] = RESULT
   with open(path, 'w') as f:
       json.dump(data, f)
   "
   ```
   where `RESULT` is `True` or `False`. Emit:
   > DM permission cached — won't ask again. (Reset by deleting `~/.claude/lemme-slack-prefs.json`.)

   Set `dm_enabled` accordingly.

If `dm_scope` was `dm_only`, set `dm_enabled = true` and skip the permission check entirely.

**3b — Channel discovery**

Skip this entire sub-step if `dm_scope` is `dm_only` — proceed directly to Step 4.

**If `channels` was provided** (via arg or Step 2c filter): treat the listed channels as the selected set. Emit "Using specified channels: [list]." Apply Stage 2 filtering to their messages in Step 4. Skip the discovery logic below and proceed directly to Step 4.

**Otherwise** (auto-discover):

Call `slack_search_channels` with `query` set to `project_or_area`. Also call `slack_search_public` with the same query and `content_types: "messages"` to find channels where the topic appears in message history.

Collect the union of matching channels. Run Stage 1 classification on each:
- Drop `SOCIAL` channels unless they appeared in the keyword search result (EC-4 exception — flag them for strict Stage 2 handling).
- Keep `PROJECT` and `FUNCTIONAL` channels.
- Skip `UNKNOWN` channels.

After classification:
- **0 channels remain**: emit "No project-scoped channels found for '[project_or_area]'. Trying a shorter keyword..." — extract the first significant word and retry once. If still 0, emit a warning and proceed to Step 4 (low message count will exit).
- **1–5 channels**: use all of them.
- **> 5 channels**: emit "Found [N] matching channels — narrowing to the 5 most active for '[project_or_area]'." Prefer `PROJECT` over `FUNCTIONAL` over social-exception channels. Within each tier, prefer higher activity. List the 5 chosen names before proceeding.

**Step 4 / 6 — Message collection**

Apply Stage 2 message classification from `refs/filter.md` to every message before counting it. Only Stage-2-passing messages count toward the target.

Target: **80 included messages** across all selected channels. Hard cap on messages *fetched*: **150**.

**Build the search query** from the active filters:
- Base: `project_or_area`
- If `colleague` set: append `from:@colleague` (or `from:displayname` if no @)
- If `period` set: convert natural language to Slack date modifiers — e.g. "last 3 months" → `after:YYYY-MM-DD`, "Q1 2025" → `after:2025-01-01 before:2025-03-31`, "since January" → `after:YYYY-01-01`. Emit the resolved date range so the user can confirm.

For each selected channel:
1. Call `slack_search_public` with the composed query filtered to that channel (`in:#channel-name`). For each result, run Stage 2; keep only `INCLUDE` messages.
2. If an included message has a thread with > 1 reply, call `slack_read_thread` to get reply context. Classify each reply independently via Stage 2.

Stop fetching when either limit is hit. For messages sourced from a social channel via EC-4, add a note: "sourced from social channel — validate relevance."

**DM collection (if `dm_enabled` is true)**

Additionally search direct messages and group DMs. Apply the same fetch cap (shared with the channel search — stop when the combined total hits 150 fetched):

- If `colleague` is set: resolve colleague to `user_id` per the **Colleague resolution** protocol above. Call `slack_read_channel` with that `user_id` as `channel_id`. Pass `oldest`/`latest` timestamps if `period` is set. Apply Stage 2 to each message.
- If no colleague is set: call `slack_search_public_and_private` with the composed query and `channel_types: "im,mpim"`. Apply Stage 2 to each result.

Tag each DM-sourced `INCLUDE` message with "sourced from DM" and add to the collection pool.

For each included message, record: sender display name, apparent role/team, timestamp, channel or "DM", message text (up to 200 characters).

After collection:
- **< 10 included messages**: emit "Only [N] relevant messages found — not enough context for a reliable summary." Ask using AskUserQuestion:
  - **Try a different search term** → re-ask for `project_or_area` and return to Step 3.
  - **Continue anyway** → proceed to Step 5 with a caveat that the summary will be thin.
- **10–150 included messages**: proceed to Step 5.

**Step 5 / 6 — Synthesis**

Analyse all collected messages. Identify:

1. **Work activities** — what was the user actually doing? (e.g. sharing designs, requesting feedback, aligning on scope, unblocking engineers, coordinating research, making decisions, writing specs, escalating blockers)
2. **Stakeholders** — who did the user interact with directly? For each unique person, note: display name, likely team/role (infer from message context or channel membership), type of interaction with the user.
3. **Interaction type** — classify each stakeholder relationship as one of: _design alignment_, _engineering alignment_, _product alignment_, _research coordination_, _leadership update_, _cross-team collaboration_, _feedback loop_, or _other_.
4. **Evidence messages** — for each of the top 5 stakeholders (by interaction frequency), pick the 1–2 most representative verbatim message excerpts (≤ 120 characters each) that best illustrate the nature of the interaction.

**Step 6 / 6 — Output**

Emit two things in this order:

---

**A. Context summary (10–15 lines)**

Write in factual, third-person analysis voice — not self-eval voice. The self-eval skill will convert this into first-person later.

The paragraph must cover:
- What work the user was carrying out across the identified channels
- Who the key collaborators were and what their apparent roles are
- The nature and pattern of interactions (alignment, decision-making, feedback, unblocking)
- Any notable moments visible in the thread: decisions landed, cross-team alignment achieved, milestone updates shared, or blockers resolved

Keep every sentence grounded in what you observed in the messages. Do not speculate.

---

**B. Stakeholder table**

| Stakeholder | Apparent role / team | Interaction type | Example message |
|-------------|----------------------|-----------------|-----------------|
| [Name] | [e.g. Senior PM, Growth] | [e.g. Product alignment] | "[verbatim excerpt ≤ 120 chars]" |

- Include exactly 5 rows; if fewer than 5 unique stakeholders were found, include as many as exist.
- The **Example message** column must be a verbatim excerpt from the actual message. Never fabricate or freely paraphrase.
- If a stakeholder sent multiple strong messages, include up to 2 excerpts separated by a line break in the same cell.

---

After emitting both, add this footer verbatim:

> **Note:** This summary is evidence scaffolding — use it to inform your self-eval draft, not as final text. Message excerpts are truncated at 120 characters where needed.

---

**Return to caller**

- If invoked from `/self-eval`: the output above is automatically available as evidence context for the self-eval draft. The self-eval skill will proceed to Step 3 (Execute protocol) using this context.
- If invoked standalone: after emitting the output, ask using AskUserQuestion:
  - **Start writing my self-eval** → invoke `/self-eval` (pass `project_or_area` and `output_type` as context).
  - **I'm done** → terminate.

## References

- `refs/filter.md` — Stage 1 channel classification and Stage 2 message classification decision trees; loaded at Step 3
