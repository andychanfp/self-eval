#!/usr/bin/env bash
set -euo pipefail

REPO="https://github.com/andychanfp/self-eval.git"
SKILL_NAME="self-eval"
SKILLS_DIR="${HOME}/.claude/skills"
DEST="${SKILLS_DIR}/${SKILL_NAME}"
USER_CACHE="${DEST}/refs/user-cache.json"

# Sub-skills bundled in the repo under .claude/skills/
SUB_SKILLS=("lemme-slack")

# ── helpers ───────────────────────────────────────────────────────────────────
info()  { printf '\033[0;34m[info]\033[0m  %s\n' "$*"; }
ok()    { printf '\033[0;32m[ok]\033[0m    %s\n' "$*"; }
die()   { printf '\033[0;31m[error]\033[0m %s\n' "$*" >&2; exit 1; }

# ── preflight ─────────────────────────────────────────────────────────────────
command -v git    >/dev/null 2>&1 || die "git is required but not found"
command -v claude >/dev/null 2>&1 || die "Claude Code CLI (claude) is required but not found"

# ── install / update ──────────────────────────────────────────────────────────
mkdir -p "${SKILLS_DIR}"

if [[ -d "${DEST}/.git" ]]; then
  info "Skill already installed — pulling latest..."

  # Preserve user-cache.json if it has been populated
  cache_backup=""
  if [[ -f "${USER_CACHE}" ]] && grep -qv '""' "${USER_CACHE}" 2>/dev/null; then
    cache_backup="$(cat "${USER_CACHE}")"
    info "Preserving existing user-cache.json..."
  fi

  git -C "${DEST}" pull --ff-only

  # Restore the user's cache if it was overwritten by the pull
  if [[ -n "${cache_backup}" ]]; then
    echo "${cache_backup}" > "${USER_CACHE}"
    ok "user-cache.json restored"
  fi
else
  info "Cloning ${REPO}..."
  git clone "${REPO}" "${DEST}"
fi

ok "Skill files ready at ${DEST}"

# ── symlink sub-skills ────────────────────────────────────────────────────────
for sub in "${SUB_SKILLS[@]}"; do
  src="${DEST}/.claude/skills/${sub}"
  link="${SKILLS_DIR}/${sub}"
  if [[ ! -d "${src}" ]]; then
    info "Sub-skill source not found, skipping: ${src}"
    continue
  fi
  if [[ -L "${link}" ]]; then
    info "/${sub} symlink already exists — skipping"
  elif [[ -e "${link}" ]]; then
    die "/${sub} exists at ${link} but is not a symlink — remove it manually and re-run"
  else
    ln -s "${src}" "${link}"
    ok "/${sub} symlinked at ${link}"
  fi
done

# ── done ─────────────────────────────────────────────────────────────────────
printf '\n'
ok "Installation complete! You can now run /self-eval and kickstart the process or run /lemme-slack to create a summary of work done based on your Slack (requires MCP)."
