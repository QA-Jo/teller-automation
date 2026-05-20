#!/bin/bash
# ============================================================
# publish_reports.sh — Push Robot Framework reports to GitHub Pages
#
# Usage:
#   bash publish_reports.sh                        # publishes most recent results/ run
#   bash publish_reports.sh --timestamp 2026-04-20_10-30-00
#
# Reports are published to the gh-pages branch and served at:
#   https://pvillados-nmblr.github.io/teller-automation/
# ============================================================

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
PAGES_URL="https://pvillados-nmblr.github.io/teller-automation"
WORKTREE_PATH="/tmp/gh-pages-work"

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

info()    { echo -e "  ${CYAN}[INFO]${NC}   $*"; }
success() { echo -e "  ${GREEN}[DONE]${NC}   $*"; }
err()     { echo -e "  ${RED}[ERROR]${NC}  $*" >&2; exit 1; }

# ── Argument parsing ──────────────────────────────────────
TIMESTAMP=""
while [[ $# -gt 0 ]]; do
  case $1 in
    --timestamp) TIMESTAMP="$2"; shift 2 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

# ── Resolve timestamp ─────────────────────────────────────
if [[ -z "$TIMESTAMP" ]]; then
  TIMESTAMP=$(ls -1 "${REPO_ROOT}/results/" 2>/dev/null | sort -r | head -1)
  [[ -z "$TIMESTAMP" ]] && err "No runs found in results/ — run tests first."
fi

RESULTS_DIR="${REPO_ROOT}/results/${TIMESTAMP}"
[[ -d "$RESULTS_DIR" ]] || err "Results directory not found: ${RESULTS_DIR}"

# Verify at least one report.html exists
REPORT_COUNT=$(find "$RESULTS_DIR" -name "report.html" | wc -l | tr -d ' ')
[[ "$REPORT_COUNT" -gt 0 ]] || err "No report.html files found in ${RESULTS_DIR}"

info "Publishing ${REPORT_COUNT} report(s) from run: ${TIMESTAMP}"

# ── Ensure gh-pages branch exists ────────────────────────
cd "$REPO_ROOT"

if ! git ls-remote --heads origin gh-pages | grep -q gh-pages; then
  info "Creating gh-pages branch..."
  git checkout --orphan gh-pages
  git reset --hard
  echo "# Teller Automation — Test Reports" > index.html
  git add index.html
  git commit -m "init: gh-pages branch"
  git push origin gh-pages
  git checkout -
fi

# ── Set up worktree ───────────────────────────────────────
cleanup() {
  if git worktree list | grep -q "$WORKTREE_PATH"; then
    git worktree remove --force "$WORKTREE_PATH" 2>/dev/null || true
  fi
}
trap cleanup EXIT

info "Setting up gh-pages worktree..."
# Remove any stale worktree at the fixed path before adding
if git worktree list | grep -q "$WORKTREE_PATH"; then
  git worktree remove --force "$WORKTREE_PATH" 2>/dev/null || true
fi
rm -rf "$WORKTREE_PATH"
git fetch origin gh-pages
# Update local gh-pages to match remote before adding worktree
git branch -f gh-pages origin/gh-pages 2>/dev/null || true
git worktree add "$WORKTREE_PATH" gh-pages 2>/dev/null \
  || git worktree add "$WORKTREE_PATH" --track -b gh-pages origin/gh-pages 2>/dev/null \
  || { cleanup; git worktree add "$WORKTREE_PATH" gh-pages; }

# ── Copy reports ──────────────────────────────────────────
DEST_RUN="${WORKTREE_PATH}/reports/${TIMESTAMP}"
DEST_LATEST="${WORKTREE_PATH}/reports/latest"

info "Copying reports to gh-pages..."
mkdir -p "$DEST_RUN"
cp -R "${RESULTS_DIR}/." "$DEST_RUN/"

# Remove output.xml (large, not needed for viewing)
find "$DEST_RUN" -name "output.xml" -delete

# Update latest/ alias
rm -rf "$DEST_LATEST"
mkdir -p "$DEST_LATEST"
cp -R "${RESULTS_DIR}/." "$DEST_LATEST/"
find "$DEST_LATEST" -name "output.xml" -delete

# ── Regenerate index.html ─────────────────────────────────
info "Regenerating index..."

RUNS_DIR="${WORKTREE_PATH}/reports"
INDEX_FILE="${WORKTREE_PATH}/index.html"

# Collect all timestamped run dirs (exclude latest/)
RUN_DIRS=()
while IFS= read -r line; do
  RUN_DIRS+=("$line")
done < <(ls -1 "$RUNS_DIR" 2>/dev/null | grep -v '^latest$' | sort -r)

{
  cat <<'HTML'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Teller Automation — Test Reports</title>
<style>
  body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif; margin: 0; background: #f5f5f5; color: #222; }
  header { background: #1a1a2e; color: #fff; padding: 24px 32px; }
  header h1 { margin: 0; font-size: 1.4rem; font-weight: 600; }
  header p  { margin: 4px 0 0; font-size: 0.85rem; opacity: 0.7; }
  main { max-width: 960px; margin: 32px auto; padding: 0 24px; }
  .run-card { background: #fff; border-radius: 8px; margin-bottom: 20px; box-shadow: 0 1px 4px rgba(0,0,0,.08); overflow: hidden; }
  .run-header { padding: 14px 20px; background: #16213e; color: #fff; display: flex; align-items: center; gap: 12px; }
  .run-header .ts { font-size: 0.95rem; font-weight: 600; }
  .run-header .badge { font-size: 0.75rem; background: #e8f5e9; color: #2e7d32; border-radius: 4px; padding: 2px 8px; }
  .run-header .badge.latest { background: #fff3e0; color: #e65100; }
  .reports-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(220px, 1fr)); gap: 1px; background: #eee; }
  .report-link { background: #fff; padding: 12px 16px; text-decoration: none; color: #1565c0; font-size: 0.88rem; display: flex; flex-direction: column; gap: 2px; }
  .report-link:hover { background: #e3f2fd; }
  .report-link .bank { font-weight: 600; color: #222; font-size: 0.82rem; }
  .report-link .module { color: #555; }
  .no-reports { padding: 12px 20px; color: #888; font-size: 0.9rem; }
  .latest-banner { background: #fff8e1; border-left: 4px solid #f9a825; padding: 12px 20px; margin-bottom: 24px; border-radius: 4px; font-size: 0.9rem; }
  .latest-banner a { color: #1565c0; }
</style>
</head>
<body>
<header>
  <h1>Teller Automation — Test Reports</h1>
  <p>Robot Framework results published automatically after each local run</p>
</header>
<main>
HTML

  # Latest banner
  if [[ ${#RUN_DIRS[@]} -gt 0 ]]; then
    LATEST_TS="${RUN_DIRS[0]}"
    echo "  <div class=\"latest-banner\">Latest run: <strong>${LATEST_TS}</strong> &nbsp;·&nbsp; <a href=\"reports/latest/\">Jump to latest reports &rarr;</a></div>"
  fi

  for ts in "${RUN_DIRS[@]}"; do
    echo "  <div class=\"run-card\">"
    if [[ "$ts" == "${RUN_DIRS[0]}" ]]; then
      echo "    <div class=\"run-header\"><span class=\"ts\">${ts}</span><span class=\"badge latest\">latest</span></div>"
    else
      echo "    <div class=\"run-header\"><span class=\"ts\">${ts}</span></div>"
    fi
    echo "    <div class=\"reports-grid\">"

    # Find all report.html files in this run
    REPORTS=()
    while IFS= read -r line; do
      REPORTS+=("$line")
    done < <(find "${RUNS_DIR}/${ts}" -name "report.html" | sort)

    if [[ ${#REPORTS[@]} -eq 0 ]]; then
      echo "      <div class=\"no-reports\">No reports found.</div>"
    else
      for report in "${REPORTS[@]}"; do
        # Get relative path from the run dir
        rel="${report#${RUNS_DIR}/${ts}/}"
        # Extract bank and module from path (bank/module/report.html)
        bank=$(echo "$rel" | cut -d'/' -f1)
        module=$(echo "$rel" | cut -d'/' -f2)
        link="reports/${ts}/${rel}"
        echo "      <a class=\"report-link\" href=\"${link}\">"
        echo "        <span class=\"bank\">${bank}</span>"
        echo "        <span class=\"module\">${module}</span>"
        echo "      </a>"
      done
    fi

    echo "    </div>"
    echo "  </div>"
  done

  cat <<'HTML'
</main>
</body>
</html>
HTML
} > "$INDEX_FILE"

# Run-specific index for easy browsing
for ts in "${RUN_DIRS[@]}"; do
  RUN_INDEX="${WORKTREE_PATH}/reports/${ts}/index.html"
  REPORTS=()
  while IFS= read -r line; do
    REPORTS+=("$line")
  done < <(find "${WORKTREE_PATH}/reports/${ts}" -name "report.html" | sort)
  {
    echo "<!DOCTYPE html><html><head><meta charset='UTF-8'><title>Run: ${ts}</title>"
    echo "<style>body{font-family:sans-serif;margin:32px;} a{display:block;margin:8px 0;font-size:1rem;}</style></head><body>"
    echo "<h2>Run: ${ts}</h2><p><a href='../../'>← All runs</a></p>"
    for r in "${REPORTS[@]}"; do
      rel="${r#${WORKTREE_PATH}/reports/${ts}/}"
      echo "<a href='${rel}'>${rel}</a>"
    done
    echo "</body></html>"
  } > "$RUN_INDEX"
done

# ── Commit and push ───────────────────────────────────────
info "Committing and pushing to gh-pages..."
git -C "$WORKTREE_PATH" add -A
git -C "$WORKTREE_PATH" commit -m "reports: ${TIMESTAMP} (${REPORT_COUNT} report(s))" \
  || { info "Nothing new to commit."; exit 0; }
git -C "$WORKTREE_PATH" push origin gh-pages

echo ""
echo "  ╔══════════════════════════════════════════════════════════╗"
echo -e "  ║  ${GREEN}${BOLD}Reports published!${NC}                                       ║"
echo "  ║                                                          ║"
echo "  ║  Index   : ${PAGES_URL}/                       ║"
echo "  ║  Latest  : ${PAGES_URL}/reports/latest/        ║"
echo "  ║  This run: ${PAGES_URL}/reports/${TIMESTAMP}/  ║"
echo "  ╚══════════════════════════════════════════════════════════╝"
echo ""
success "GitHub Pages update may take ~30s to go live."
