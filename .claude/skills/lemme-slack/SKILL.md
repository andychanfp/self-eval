---
name: lemme-slack
description: >
  Scans the user's Slack history to surface project context, stakeholders, and
  concrete message examples. Run before writing a self-eval paragraph to provide
  evidence for accomplishments or growth areas. Invoke with /lemme-slack
  (standalone) or called automatically by /self-eval after the user selects
  accomplishment or growth area. Accepts optional args to narrow the search:
  colleague name, time period, or specific channels.
argument-hint: '"project name" [colleague: @name] [role: "product manager"] [period: "last 3 months"] [channels: #chan1] — or plain prose: "Check my Slacks with Kelvin Tan the PM from Jan to Jun, only DMs"'
model: claude-sonnet-4-6
allowedTools: [AskUserQuestion, Bash]
---

## Usage

**Standalone**: `/lemme-slack` — you will be asked for the project name or growth area, then receive a Slack evidence summary. At the end you can optionally hand off to `/self-eval` to draft the paragraph.

**With structured args**: pass any combination of optional filters inline:
- `/lemme-slack checkout redesign` — sets the project name directly
- `/lemme-slack checkout colleague: @john` — also filters to messages from John
- `/lemme-slack checkout period: "Q1 2025"` — restricts to that date range
- `/lemme-slack checkout channels: #proj-checkout #design-team` — skips channel discovery
- `/lemme-slack checkout colleague: @john role: "product manager"` — disambiguates if multiple Johns exist

**With prose**: describe your request naturally — fields are extracted automatically:
- `/lemme-slack Check my Slack conversations with Kelvin Tan the PM from Jan 2026 to Jun 2026, only DMs`
- `/lemme-slack checkout redesign with Sarah since Q1, skip channels`

**Feedback mode**: reviews what a colleague has done with you and surfaces strengths + improvement areas:
- `/lemme-slack --feedback colleague: @kelvin period: "last 6 months"`
- `/lemme-slack Feedback for Kelvin Tan the product manager from Jan to Jun 2026`

**Embedded**: invoked by `/self-eval`; receives `project_or_area` and `output_type` from that session and returns its output as evidence context for the draft.

## Inputs

| Name | Format | Source |
|------|--------|--------|
| project_or_area | string — project name or growth area topic | arg, passed from self-eval, or asked |
| output_type | "accomplishment" or "growth area" | passed from self-eval, or asked |
| colleague _(optional)_ | Slack display name or @mention | arg or asked |
| colleague_role _(optional)_ | job title or team to disambiguate — e.g. "product manager", "engineering" | arg (prose) or keyword `role:` |
| period _(optional)_ | natural language date range, e.g. "last 3 months", "Q1 2025" | arg or asked |
| channels _(optional)_ | space- or comma-separated channel names, e.g. `#proj-x #design` | arg or asked |
| dm_scope _(optional)_ | `dm_only` or `channels_only` — extracted from prose or keyword `scope:` | arg (prose) or keyword |
| mode _(optional)_ | `self-eval` (default) or `feedback` — changes the synthesis lens | flag `--self-eval` / `--feedback` or prose |

## Outputs

| Mode | Output format | Destination |
|------|--------------|-------------|
| `self-eval` | 10–15 line context summary + stakeholder table | shown inline; returned as evidence context to self-eval caller |
| `feedback` | Strengths bullets + Improvement areas bullets + evidence table | shown inline; optionally handed off to self-eval as growth area context |

## Protocol

Read `refs/router.md` to detect mode, then execute the appropriate protocol file.

## References

- `refs/router.md` — mode detection and dispatch (self-eval vs feedback)
- `refs/protocol-self-eval.md` — Steps 1–6 for self-eval mode
- `refs/protocol-feedback.md` — Steps 1–6 for feedback mode
- `refs/filter.md` — Stage 1 channel classification and Stage 2 message classification decision trees; loaded at Step 3

## Caching

Slack API responses are not cached. Re-run `/lemme-slack` to refresh if significant time has passed or if you want to search different terms.

**DM permission cache**: The answer to "Can I also search your private DMs?" is stored in `~/.claude/lemme-slack-prefs.json` under the key `allow_dm_search`. This is asked at most once and never again. To reset, delete that file or set the key to `null`.

## Error handling

- If a channel search or message fetch returns a rate-limit error, wait briefly and retry once before reporting the failure.
- If the Slack MCP returns partial results (some channels accessible, some not), proceed with what is available and note the limitation in the output.
- Never silently drop a failure — always surface it to the user in one sentence before continuing or terminating.
