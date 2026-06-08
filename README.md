<div align="center">
<img src="./asset/readme.jpg">

# ✍🏻 self-eval

Writing self-evaluations is easy — but good self-evaluations are hard, especially when you're already busy enough. Sitting in front of a blank Google Docs, checking through your past projects, copy-pasting into Gemini and ChatGPT and hoping it makes you look good... sounds familiar?

Relieve your pain with a simple Claude skill that helps you scaffold either your accomplishment or a growth area, scoped into individual topics.

`self-eval` ships with `lemme-slack`: another lightweight skill that checks Slack (using Slack MCP) for past interactions to bolster your self-eval and refresh your memory. Adapted loosely on [Joan Chiang](https://github.com/joan-chiangwq)'s [slackback](https://github.com/joan-chiangwq/skillmaxxing/tree/main/.claude/skills/slackback) skill.

It also ships with `write-360`: a peer feedback skill that drafts strength or constructive feedback paragraphs for a named colleague in SBI format (Situation → Behaviour → Impact), anchored to the Pandora career framework.

</div>

## ⚒️ Usage

### self-eval

| Command | Usage |
| -- | -- |
| `/self-eval` | Runs the full interview and drafts a paragraph |
| `/self-eval --accomplishment` | Skips the output-type question; goes straight to accomplishment mode |
| `/self-eval --growth` | Skips the output-type question; goes straight to growth area mode |
| `/self-eval --reset` | Clears your cached role and level so you can re-enter them |

### lemme-slack

A standalone sub-skill that scans your Slack history to surface evidence before writing. Also called automatically inside `/self-eval` at Step 2.5.

| Command | Usage |
| -- | -- |
| `/lemme-slack` | Guided search — you'll be asked for the project or topic |
| `/lemme-slack <project>` | Searches Slack for the named project directly |
| `/lemme-slack <project> colleague: @name` | Filters to messages from a specific colleague |
| `/lemme-slack <project> period: "Q1 2025"` | Restricts results to a date range |
| `/lemme-slack <project> channels: #chan1 #chan2` | Skips channel discovery; searches those channels only |
| `/lemme-slack --feedback colleague: @name` | Feedback mode — surfaces what a colleague did with you; outputs strengths + improvement areas |
| `/lemme-slack Feedback for <name> from <period>` | Same feedback mode, parsed from prose |

### write-360

A standalone sub-skill that drafts SBI-format peer feedback paragraphs anchored to the Pandora career framework. Pairs with `/lemme-slack --feedback` to pull Slack evidence before drafting.

| Command | Usage |
| -- | -- |
| `/write-360` | Guided flow — prompts for colleague name, role, and feedback type |
| `/write-360 strength for <name> (<role>)` | Drafts a strength paragraph directly |
| `/write-360 constructive for <name> (<role>)` | Drafts a constructive feedback paragraph directly |

**Tip**: run `/lemme-slack --feedback colleague: @name` first and paste the output into your `/write-360` prompt as examples. The skill will use the Slack evidence to ground the SBI paragraph.

## 🚀 Installation

**Install both `self-eval` and `lemme-slack`**

```bash
curl -fsSL https://raw.githubusercontent.com/andychanfp/self-eval/main/install.sh | bash
```

**Install `lemme-slack` only**

```bash
curl -fsSL https://raw.githubusercontent.com/andychanfp/self-eval/main/install.sh | bash -s -- --skill=lemme-slack
```

**Install `write-360` only**

```bash
curl -fsSL https://raw.githubusercontent.com/andychanfp/self-eval/main/install.sh | bash -s -- --skill=write-360
```

To update, rerun the same command. The `--skill=` flags clone the source to `~/.claude/.self-eval-src/` (hidden) so only the requested skill is exposed.

## 🔎 How it works

1. **Identify yourself** — on first run, the skill asks for your job function and level. Cached for future runs.
2. **Pick the review period and output type** — MYR or EOY, accomplishment or growth area. Skipped if you passed a flag.
3. **Optionally pull Slack context** — the skill can scan your Slack history via `/lemme-slack` to surface stakeholder names, interaction examples, and concrete evidence before drafting. You choose whether to run it.
4. **Go through the interview** — the skill asks targeted questions to gather the specific moment, actions, and outcomes needed for an SBI paragraph (Situation → Behavior → Impact).
5. **Quality gate** — before showing you the result, the skill runs a silent self-check: grounded situation, behavior from evidence, traceable impact, no AI vocabulary or filler phrases.
6. **Approve, revise, or escalate** — accept the paragraph, ask for a rewrite, or trigger an adversarial sub-agent that reviews it against the Pandora career framework and design principles, then redrafts.

## ❓ FAQ

1. **Why not write self-evaluations manually?** You can. This just saves some time in the cold start.
2. **Will I get promoted with the AI self-evaluation?** This skill helps you write, not do your job. 
3. **What if I can't remember what I did?** Please try.
4. **Is it cheap to run this skill?** Takes about <3K tokens to complete one paragraph.

## 🙏🏻 Thank you

A huge thank you to Joan for building the [slackback](https://github.com/joan-chiangwq/skillmaxxing/tree/main/.claude/skills/slackback) skill, which formed the base of the supplementary skill to this repo. [Slackback](https://github.com/joan-chiangwq/skillmaxxing/tree/main/.claude/skills/slackback) functions differently: it's a lighter-weight deep dive, whereas `lemme-slack` focuses on summarisation and peer feedback synthesis.