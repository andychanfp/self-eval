# lemme-slack Protocol Router

## Mode detection

Before executing any step, check the raw argument string for mode signals:

- `--feedback`, "for feedback", "how [name] works", "what [name] has done", "review [name]" → `mode = feedback`
- `--self-eval`, "for my self-eval", "accomplishment", "growth area", no flag, or context passed from `/self-eval` → `mode = self-eval`

Then read and execute the appropriate protocol file **from Step 1**:

| Mode | Protocol file |
|------|--------------|
| `self-eval` (default) | `refs/protocol-self-eval.md` |
| `feedback` | `refs/protocol-feedback.md` |

Both files are fully self-contained — do not return to this file after dispatching.
