<div align="center">
<img src="./asset/readme.jpg">

# ✍🏻 self-eval

Writing self-evaluations is easy — but good self-evaluations are hard, especially when you're already busy enough. Sitting in front of a blank Google Docs, checking through your past projects, copy-pasting into Gemini and ChatGPT and hoping it makes you look good... sounds familiar?

Relieve your pain with a simple Claude skill that helps you scaffold either your accomplishment or a growth area, scoped into individual topics.

</div>

## ⚒️ Usage

| Command | Usage |
| -- | -- |
| `/self-eval` | Runs the skill in entirety |
| `/self-eval --reset` | Resets the cache. For example, you might want to change your level |

## 🚀 Installation

**One-time installation**

```bash
curl -fsSL https://raw.githubusercontent.com/andychanfp/self-eval/main/install.sh | bash
```

To update, rerun the script above.

## 🔎 How it works

1. Run the skill
2. Choose either _accomplishment_ or _growth area_
3. Go through the protocol
4. Before the final result, the skill will run a check against a few boundaries to ensure conciseness, quality
5. Approve, revise, or ask to run an adversarial review with another agent

## ❓ FAQ

1. **Why not write self-evaluations manually?** You can. This just saves some time in the cold start.
2. **Will I get promoted with the AI self-evaluation?** This skill helps you write, not do your job. 
3. **What if I can't remember what I did?** Please try.
4. **Is it cheap to run this skill?** Takes about <3K tokens to complete one paragraph.