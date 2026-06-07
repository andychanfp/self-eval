---
name: lemme-slack
description: >
  Scans the user's Slack history to surface project context, stakeholders, and
  concrete message examples. Run before writing a self-eval paragraph to provide
  evidence for accomplishments or growth areas. Invoke with /lemme-slack
  (standalone) or called automatically by /self-eval after the user selects
  accomplishment or growth area. Accepts optional args to narrow the search:
  colleague name, time period, or specific channels.
argument-hint: '"project name" [colleague: @name] [period: "last 3 months"] [channels: #chan1 #chan2]'
model: claude-sonnet-4-6
allowedTools: [AskUserQuestion]
---

## Usage

**Standalone**: `/lemme-slack` — you will be asked for the project name or growth area, then receive a Slack evidence summary. At the end you can optionally hand off to `/self-eval` to draft the paragraph.

**With args**: pass any combination of optional filters inline:
- `/lemme-slack checkout redesign` — sets the project name directly
- `/lemme-slack checkout colleague: @john` — also filters to messages from John
- `/lemme-slack checkout period: "Q1 2025"` — restricts to that date range
- `/lemme-slack checkout channels: #proj-checkout #design-team` — skips channel discovery

**Embedded**: invoked by `/self-eval`; receives `project_or_area` and `output_type` from that session and returns its output as evidence context for the draft.

## Inputs

| Name | Format | Source |
|------|--------|--------|
| project_or_area | string — project name or growth area topic | arg, passed from self-eval, or asked |
| output_type | "accomplishment" or "growth area" | passed from self-eval, or asked |
| colleague _(optional)_ | Slack display name or @mention | arg or asked |
| period _(optional)_ | natural language date range, e.g. "last 3 months", "Q1 2025" | arg or asked |
| channels _(optional)_ | space- or comma-separated channel names, e.g. `#proj-x #design` | arg or asked |

## Outputs

| Name | Format | Destination |
|------|--------|-------------|
| slack_context | 10–15 line paragraph + stakeholder table | shown inline; returned as evidence context to self-eval caller |

## Protocol

Read and follow `refs/protocol.md` exactly.

## References

- `refs/protocol.md` — step-by-step execution protocol (Steps 1–6), persona, and output format
- `refs/filter.md` — Stage 1 channel classification and Stage 2 message classification decision trees; loaded at Step 3

## Caching

Slack API responses are not cached. Re-run `/lemme-slack` to refresh if significant time has passed or if you want to search different terms.

## Error handling

- If a channel search or message fetch returns a rate-limit error, wait briefly and retry once before reporting the failure.
- If the Slack MCP returns partial results (some channels accessible, some not), proceed with what is available and note the limitation in the output.
- Never silently drop a failure — always surface it to the user in one sentence before continuing or terminating.
