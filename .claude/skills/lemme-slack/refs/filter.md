# Filter: Project Scope Classification

Used by lemme-slack in two sequential stages:

- **Stage 1** runs during channel discovery (Step 3): classify each candidate channel and decide whether to load it.
- **Stage 2** runs during message collection (Step 4): classify each retrieved message and decide whether to keep it.

Discard early and discard aggressively. Every included message must earn its place with at least one scope signal. When in doubt, discard.

---

## Stage 1 — Channel Classification

**Output**: one of `PROJECT`, `FUNCTIONAL`, `SOCIAL`, or `UNKNOWN`.

```
Does the channel name match a known SOCIAL pattern?
├── YES → SOCIAL — do not load
│          └── Exception: apply Stage 2 scan if the channel appeared in a
│              keyword search result (the project topic surfaced there despite
│              the channel being social). Load only messages that pass Stage 2.
└── NO
    └── Does the channel name or description contain the project keyword?
        ├── YES → PROJECT — load; apply Stage 2 filter on messages
        └── NO
            └── Is the channel a functional team channel?
                ├── YES → FUNCTIONAL — load; apply Stage 2 filter strictly
                └── NO → UNKNOWN — skip
```

### SOCIAL name patterns (do not load)

A channel is SOCIAL if its name contains any of:

`random`, `fun`, `lunch`, `food`, `coffee`, `banter`, `memes`, `off-topic`,
`social`, `friday`, `celebration`, `shoutout`, `kudos`, `pets`, `sports`,
`music`, `gaming`, `travel`, `wellness`, `hobby`, `watercooler`, `vibes`,
`foodies`, `hangout`

Also classify as SOCIAL: `general` channels that are not the primary workspace announcements channel (i.e., member count < 50 or last 10 messages are non-work).

### PROJECT name patterns (load)

A channel is PROJECT if its name:
- Contains the project keyword or a close abbreviation (e.g., `#proj-checkout`, `#checkout-revamp`)
- Is named for a release, sprint, or milestone tied to the project (e.g., `#q3-release`, `#sprint-42`)
- Is an incident channel related to the project (e.g., `#inc-checkout-p0`, `#hotfix-payment`)

### FUNCTIONAL name patterns (load with strict Stage 2)

A channel is FUNCTIONAL if its name contains a team or discipline identifier:

`design`, `engineering`, `product`, `research`, `data`, `marketing`, `legal`,
`ops`, `platform`, `mobile`, `web`, `backend`, `frontend`, `infra`, `qa`

Functional channels are loaded because the project may be discussed there, but Stage 2 filtering must be applied strictly — functional channels carry high social noise.

---

## Stage 2 — Message Classification

**Output**: `INCLUDE` or `DISCARD`.

```
Is the message emoji-only or a bare Slack reaction?
├── YES → DISCARD
└── NO
    └── Is the message a greeting, farewell, or social opener?
        ├── YES → DISCARD
        └── NO
            └── Is the message social coordination or non-work scheduling?
                ├── YES → DISCARD
                └── NO
                    └── Is the message a generic affirmation with no project noun?
                        ├── YES → DISCARD
                        └── NO
                            └── Does the message contain at least one SCOPE signal?
                                ├── YES → INCLUDE
                                └── NO → DISCARD
```

### SCOPE signals — INCLUDE if any present

| Category | Signal examples |
|----------|----------------|
| Deliverable reference | Figma link, Jira/Linear/Asana ticket, PR URL, Google Doc link, prototype, spec, design file, handoff package, changelog |
| Technical work | Bug report, crash, API contract, implementation detail, build failure, release note, deploy, QA result, regression, test plan |
| Approval or disapproval | "approved", "rejected", "signed off", "not aligned", "blocked by", "we're going with", "confirmed", "not proceeding", "reverted" |
| Incident or emergency | "incident", "outage", "hotfix", "P0", "P1", "degraded", "rollback", "escalate", "on-call", "postmortem" |
| Unblocking or blocking | "unblocked", "blocking the", "waiting on you", "need this to move forward", "can you approve", "holding up the release", "dependency cleared" |
| Decision or direction | "we decided", "going with", "final call", "direction is", "stakeholder aligned", "from our sync", "action item", "we agreed", "next steps are" |
| Review or feedback on work | "reviewed the", "feedback on", "changes requested", "addressed your comments", "iteration on", "revised per", "updated the design" |

### DISCARD signals — discard if none of the above apply

| Category | Examples |
|----------|---------|
| Emoji-only | `👍`, `🎉`, `✅` as standalone messages (not in response to a work artifact) |
| Greetings / farewells | "Good morning", "Hey everyone", "gm", "bye", "have a good weekend", "see you tomorrow" |
| Social coordination | "Anyone up for lunch?", "WFH today", "OOO this afternoon", "grabbing coffee — back in 30", "who's joining the team dinner?" |
| Generic affirmations | "Sounds good", "Thanks!", "Got it", "Noted", "Cool", "Sure", "OK" — when standalone with no project noun attached |
| Banter / jokes | Off-topic humour, GIFs with no project relevance, meme shares |
| Non-work coordination | Birthday wishes, holiday messages, team-building invites, event RSVPs |
| Status with no content | "Still on it", "Working on it", "Will update soon" — when the update itself adds no new information |

---

## Edge Cases

### EC-1 — Ambiguous short affirmations ("LGTM", "✅", "👍")

**Problem**: "LGTM" is a common approval signal, but it can also be social (replying to a lunch suggestion).

**Rule**: Resolve via thread context.
- If the parent message is a deliverable reference, design share, or PR — classify the reply as `INCLUDE` (approval of work).
- If the parent message is social or the affirmation is standalone — classify as `DISCARD`.
- If thread context is unavailable, default to `DISCARD`.

### EC-2 — Slack reactions (emoji only)

**Rule**: Always `DISCARD` the reaction signal itself. However, do not let a reaction's presence cause you to skip the *parent message*. Classify the parent independently.

### EC-3 — Forwarded or linked content with no body text

**Problem**: A message that is only a URL or attachment, no text.

**Rule**: `INCLUDE` if the link is a recognisable deliverable type (Figma, Notion, Confluence, Jira, Linear, GitHub PR/issue, Google Docs, Loom). `DISCARD` otherwise (e.g., a YouTube video link in a social channel).

### EC-4 — Work request inside a SOCIAL channel

**Problem**: A message in `#foodies` that happens to contain an urgent work request.

**Rule**: Classify the *message* independently of the channel's Stage 1 outcome. If the message passes Stage 2 (contains a scope signal), `INCLUDE` it regardless of the channel being `SOCIAL`. Log it with a note: "sourced from social channel — validate relevance."

### EC-5 — Thread where the parent is DISCARD but replies are work

**Problem**: A social message spawns a thread that pivots to work discussion.

**Rule**: Classify each message in the thread independently. Replies that contain scope signals are `INCLUDE` even if the parent is `DISCARD`. When synthesising, represent the reply in isolation — do not include the parent's social framing as context.

### EC-6 — Functional channel with high social noise

**Problem**: `#design-team` has a mix of project work and team social chat.

**Rule**: Load the channel (`FUNCTIONAL`) but apply Stage 2 strictly. Only messages with explicit scope signals survive. Do not count message volume from a functional channel toward the 80-message target until after Stage 2 filtering has run.

### EC-7 — Status update with no new deliverable information

**Problem**: "Still working on the checkout flow, no update yet."

**Rule**: `DISCARD`. A status that contains no new decision, blocker, artifact, or outcome adds no evidence value. The project noun alone ("checkout flow") is not a scope signal if nothing actionable accompanies it.

---

## Exemplars

### Channel classification

| Channel | Classification | Reason |
|---------|---------------|--------|
| `#proj-checkout-redesign` | PROJECT | Name contains project keyword |
| `#checkout-p0-hotfix` | PROJECT | Incident channel tied to project |
| `#lunch-sg` | SOCIAL | Matches `lunch` pattern |
| `#random` | SOCIAL | Matches `random` pattern |
| `#design-platform` | FUNCTIONAL | Contains `design` — load with strict Stage 2 |
| `#q3-growth-initiative` | PROJECT | Named for a milestone; keyword match on "growth" |
| `#foodies` | SOCIAL | Matches `foodies` pattern |
| `#android-crash-incident` | PROJECT | Incident channel; contains technical keyword |
| `#general` | SOCIAL | High member count, predominantly non-work message mix |
| `#product-growth` | FUNCTIONAL | Contains `product` — load with strict Stage 2 |

### Message classification

| Message | Classification | Reason |
|---------|---------------|--------|
| "What time is lunch?" | DISCARD | Social coordination |
| "I've approved the final comps in Figma — please proceed to handoff" | INCLUDE | Approval + deliverable reference |
| "lol 😂" | DISCARD | No scope signal |
| "The crash is isolated to the payment widget — unblocking the release now" | INCLUDE | Incident + unblocking |
| "Good morning everyone!" | DISCARD | Greeting |
| "Updated the spec per Sarah's feedback, link in thread" | INCLUDE | Deliverable revision + feedback loop |
| "Still on it, no update" | DISCARD | Status with no new information |
| "We decided to drop the guest checkout flow for this sprint — confirmed with PM" | INCLUDE | Decision + stakeholder alignment |
| "sounds good 👍" (standalone, no thread context) | DISCARD | Generic affirmation, no project noun |
| "Thanks for the review!" (parent: PR comment thread) | INCLUDE | Acknowledges a work review — resolved via thread context (EC-1) |
| [Figma link only, no body text] | INCLUDE | Deliverable reference (EC-3) |

### Edge case exemplar — Work unblocking inside a social channel

**Channel**: `#foodies` (Stage 1 → `SOCIAL`)

**Message**:
> "Hey @andy — sorry to ping here, I know this is the food channel. Before you head to lunch: legal is blocking the data consent flow on checkout. I've looped in @sarah (Head of Legal) and @tom (PM Lead). Can you update the design and reshare by tomorrow EOD? This is holding up the sprint release."

**Stage 1 result**: `SOCIAL` — channel would normally be skipped.

**Stage 2 result**: `INCLUDE`
- Scope signals present: explicit blocker ("legal is blocking"), deliverable reference ("update the design"), decision-makers named (@sarah, @tom), deadline ("tomorrow EOD"), project dependency ("holding up the sprint release")
- EC-4 applies: message passes Stage 2 independently of the channel classification.

**Log note added**: "Sourced from social channel `#foodies` — validate relevance."

**Synthesis treatment**: Include @sarah and @tom as stakeholders (leadership update / cross-team collaboration). The message evidences the user being the design decision-maker for a legally-blocked flow under sprint pressure.

---

## Reference: How lemme-slack applies this filter

- **Step 3 (channel discovery)**: run Stage 1 on every candidate channel. Drop `SOCIAL` channels unless they surfaced via keyword search (EC-4 exception). Cap at 5 channels after filtering.
- **Step 4 (message collection)**: run Stage 2 on every retrieved message before adding it to the collection pool. Count only Stage-2-passing messages toward the 80-message target.
- **Step 5 (synthesis)**: reference only `INCLUDE` messages. Do not cite or paraphrase `DISCARD` messages even if they are topically adjacent.
