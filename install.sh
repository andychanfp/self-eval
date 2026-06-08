#!/usr/bin/env bash
set -euo pipefail

REPO="https://github.com/andychanfp/self-eval.git"
SKILL_NAME="self-eval"
SKILLS_DIR="${HOME}/.claude/skills"

# Sub-skills bundled in the repo under .claude/skills/
SUB_SKILLS=("lemme-slack")

# ── helpers ───────────────────────────────────────────────────────────────────
info()  { printf '\033[0;34m[info]\033[0m  %s\n' "$*"; }
ok()    { printf '\033[0;32m[ok]\033[0m    %s\n' "$*"; }
die()   { printf '\033[0;31m[error]\033[0m %s\n' "$*" >&2; exit 1; }

# ── parse args ────────────────────────────────────────────────────────────────
INSTALL_MODE="all"  # "all" | "lemme-slack"

for arg in "$@"; do
  case "${arg}" in
    --skill=lemme-slack) INSTALL_MODE="lemme-slack" ;;
    --skill=*)           die "Unknown skill: ${arg#--skill=}. Available: lemme-slack" ;;
    *)                   die "Unknown argument: ${arg}" ;;
  esac
done

# In lemme-slack-only mode, clone to a hidden source dir so self-eval is not
# exposed as a skill. In full mode, clone directly into the skills directory.
if [[ "${INSTALL_MODE}" == "lemme-slack" ]]; then
  DEST="${HOME}/.claude/.self-eval-src"
  USER_CACHE=""
else
  DEST="${SKILLS_DIR}/${SKILL_NAME}"
  USER_CACHE="${DEST}/refs/user-cache.json"
fi

# ── preflight ─────────────────────────────────────────────────────────────────
command -v git    >/dev/null 2>&1 || die "git is required but not found"
command -v claude >/dev/null 2>&1 || die "Claude Code CLI (claude) is required but not found"

# ── install / update ──────────────────────────────────────────────────────────
mkdir -p "${SKILLS_DIR}"

if [[ -d "${DEST}/.git" ]]; then
  info "Source already installed — pulling latest..."

  # Preserve user-cache.json if it has been populated (full install only)
  cache_backup=""
  if [[ -n "${USER_CACHE}" && -f "${USER_CACHE}" ]] && grep -qE '"(job|role|level)": "[^"]' "${USER_CACHE}" 2>/dev/null; then
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

ok "Source files ready at ${DEST}"

# ── symlink sub-skills ────────────────────────────────────────────────────────
for sub in "${SUB_SKILLS[@]}"; do
  src="${DEST}/.claude/skills/${sub}"
  link="${SKILLS_DIR}/${sub}"
  if [[ ! -d "${src}" ]]; then
    info "Sub-skill source not found, skipping: ${src}"
    continue
  fi
  if [[ -e "${link}" && ! -L "${link}" ]]; then
    die "/${sub} exists at ${link} but is not a symlink — remove it manually and re-run"
  fi
  # Remove stale or existing symlink so re-installs always get a fresh link
  [[ -L "${link}" ]] && rm "${link}"
  ln -s "${src}" "${link}"
  ok "/${sub} symlinked at ${link}"
done

# ── done ─────────────────────────────────────────────────────────────────────
printf '\n'
if [[ "${INSTALL_MODE}" == "lemme-slack" ]]; then
  ok "Installation complete! You can now run /lemme-slack (requires Slack MCP)."
else
  ok "Installation complete! You can now run /self-eval and kickstart the process or run /lemme-slack to create a summary of work done based on your Slack (requires MCP)."
fi
