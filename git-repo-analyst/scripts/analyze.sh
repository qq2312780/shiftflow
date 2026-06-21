#!/usr/bin/env bash
#
# analyze.sh — Run all git-repo-analyst metrics against a local repository
# and emit a single JSON object on stdout.
#
# Usage:
#   bash scripts/analyze.sh <repo-path> [days]
#
# Output:
#   A single JSON object on stdout. All metrics are best-effort; any failure
#   produces `"n/a"` for that field. The script never modifies the repository.
#
# Requires: git, awk, sort, uniq, wc, find, jq

set -u

REPO="${1:-}"
DAYS="${2:-30}"

if [[ -z "$REPO" ]]; then
  echo '{"error":"missing repo path"}' >&2
  exit 2
fi

if [[ ! -d "$REPO/.git" ]]; then
  echo "{\"error\":\"not a git repository: $REPO\"}" >&2
  exit 2
fi

# Guard: every command runs in a subshell so a failure does not abort the script.
g() {
  git -C "$REPO" "$@" 2>/dev/null
}

# JSON-escape a string.
j() {
  # Naive escape: backslashes, double quotes, newlines. Sufficient for the
  # values produced by this script.
  local s="$1"
  s="${s//\\/\\\\}"
  s="${s//\"/\\\"}"
  s="${s//$'\n'/ }"
  printf '"%s"' "$s"
}

# Build commit-activity rows.
commit_activity_json=""
while IFS=$'\t' read -r count date; do
  [[ -z "$date" ]] && continue
  commit_activity_json+="{\"date\":\"$date\",\"count\":$count},"
done < <(g log --since="$DAYS days ago" --pretty=format:"%ad" --date=short --no-merges \
        | awk '{print $1}' \
        | sort | uniq -c | sort -rn \
        | awk '{printf "%s\t%s\n", $1, $2}')
commit_activity_json="${commit_activity_json%,}"

# Build contributors.
contributors_json=""
while IFS=$'\t' read -r count name; do
  [[ -z "$name" ]] && continue
  contributors_json+="{\"commits\":$count,\"name\":$(j "$name")},"
done < <(g shortlog -sn --no-merges --since="$DAYS days ago" \
        | sed 's/^[[:space:]]*[0-9]*[[:space:]]*//' \
        | awk -F'\t' '{count=$1; $1=""; sub(/^[\t ]*/,""); printf "%s\t%s\n", count, $0}')
# shortlog output is "  N  Name <email>" — simpler approach:
contributors_json=""
while IFS= read -r line; do
  [[ -z "$line" ]] && continue
  # Extract leading integer and the rest.
  count=$(echo "$line" | awk '{print $1}')
  rest=$(echo "$line" | awk '{$1=""; sub(/^ /,""); print}')
  contributors_json+="{\"commits\":$count,\"name\":$(j "$rest")},"
done < <(g shortlog -sn --no-merges --since="$DAYS days ago")
contributors_json="${contributors_json%,}"

# File churn.
churn_json=""
while IFS= read -r line; do
  [[ -z "$line" ]] && continue
  count=$(echo "$line" | awk '{print $1}')
  path=$(echo "$line" | awk '{$1=""; sub(/^ /,""); print}')
  churn_json+="{\"changes\":$count,\"path\":$(j "$path")},"
done < <(g log --since="$DAYS days ago" --no-merges --name-only --pretty=format: \
        | grep -v '^$' | sort | uniq -c | sort -rn | head -20)
churn_json="${churn_json%,}"

# Branches.
branches_json=""
while IFS= read -r b; do
  [[ -z "$b" ]] && continue
  # strip leading markers like "* " (current) or "remotes/"
  clean=$(echo "$b" | sed -E 's/^[\* ]+//; s|^remotes/||; s|^origin/||')
  branches_json+="$(j "$clean"),"
done < <(g branch -a)
branches_json="${branches_json%,}"

# Working tree status.
wt_status=$(g status --short)
if [[ -z "$wt_status" ]]; then
  wt_status="clean"
  wt_count=0
else
  wt_count=$(printf '%s' "$wt_status" | grep -c . 2>/dev/null || true)
  wt_count=${wt_count:-0}
fi

# Largest files.
largest_json=""
while IFS= read -r line; do
  [[ -z "$line" ]] && continue
  # wc -l output: "  N path"
  count=$(echo "$line" | awk '{print $1}')
  path=$(echo "$line" | awk '{$1=""; sub(/^ /,""); print}')
  [[ "$count" -eq 0 ]] && continue
  largest_json+="{\"lines\":$count,\"path\":$(j "$path")},"
done < <(g ls-files | xargs -I {} sh -c 'wc -l "{}" 2>/dev/null' | sort -rn | head -10)
largest_json="${largest_json%,}"

# Language breakdown.
languages_json=""
while IFS= read -r line; do
  [[ -z "$line" ]] && continue
  count=$(echo "$line" | awk '{print $1}')
  ext=$(echo "$line" | awk '{print $2}')
  languages_json+="{\"files\":$count,\"extension\":$(j "$ext")},"
done < <(g ls-files | awk -F. '{print $NF}' | sort | uniq -c | sort -rn | head -15)
languages_json="${languages_json%,}"

# Recent tags.
tags_json=""
while IFS= read -r t; do
  [[ -z "$t" ]] && continue
  tags_json+="$(j "$t"),"
done < <(g tag --sort=-creatordate | head -10)
tags_json="${tags_json%,}"

# Totals.
total_commits=$(g rev-list --count --no-merges HEAD --since="$DAYS days ago")
[[ -z "$total_commits" ]] && total_commits=0

active_days=$(g log --since="$DAYS days ago" --pretty=format:"%ad" --date=short --no-merges \
              | awk '{print $1}' | sort -u | wc -l)
[[ -z "$active_days" ]] && active_days=0

# Assemble.
cat <<EOF
{
  "repo": $(j "$REPO"),
  "days": $DAYS,
  "total_commits": ${total_commits:-0},
  "active_days": ${active_days:-0},
  "commit_activity": [${commit_activity_json}],
  "contributors": [${contributors_json}],
  "file_churn": [${churn_json}],
  "branches": [${branches_json}],
  "working_tree": {
    "status": $(j "${wt_status:-clean}"),
    "dirty_count": ${wt_count:-0}
  },
  "largest_files": [${largest_json}],
  "languages": [${languages_json}],
  "tags": [${tags_json}]
}
EOF
