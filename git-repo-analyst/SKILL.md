---
name: git-repo-analyst
description: >
  Analyzes a local git repository and produces a structured markdown report
  covering commit activity, file churn, contributor statistics, branch state,
  and basic code health signals. Use when: the user asks to analyze, audit,
  summarize, or report on a local git repo, codebase health, recent activity,
  contributor stats, file churn, or engineering velocity. Reads only — never
  modifies the repo.
metadata:
  openclaw:
    requires:
      bins:
        - git
        - awk
        - sort
        - uniq
        - wc
        - find
      env: []
    primaryEnv: null
    category: developer-tools
    tags:
      - git
      - analytics
      - code-analysis
      - reporting
    version: 1.0.0
  license: MIT
allowed-tools:
  - read
  - bash
  - glob
  - grep
---

# git-repo-analyst

Turn a local git repository into a structured engineering report — commit activity, file churn, contributor stats, and branch health — without pushing anything anywhere.

## What This Skill Does

Given a path to a local git repository, this skill:

1. Inspects the repository's git history (read-only).
2. Computes a fixed set of metrics: commit volume by day, top contributors, hot-spot files (by churn), branch list, working-tree status, largest files, and basic language breakdown.
3. Renders a markdown report following `references/report-template.md`.

The agent runs everything locally. Nothing is sent over the network. The repository is never modified.

## Prerequisites

- A local git repository reachable from the agent's working directory.
- Standard Unix tools available on `PATH`: `git`, `awk`, `sort`, `uniq`, `wc`, `find`.
- No API keys, no network access, no GitHub/GitLab credentials.

## When to Activate

Activate this skill when the user's request matches any of:

- "Analyze this repo", "audit this codebase", "summarize recent activity"
- "Who are the top contributors?", "What's the file churn?"
- "Generate a weekly engineering report from this git repo"
- "How active is this project?", "Code health check"
- "Show me commit volume / branch state / working tree status"

Do **not** activate for: editing commits, pushing, branch creation, or any write operations. This skill is strictly read-only.

## Quick Start

```
User: Analyze the repo at /workspace/my-project over the last 30 days.

Agent: [activates git-repo-analyst]
       1. Verifies /workspace/my-project is a git repo
       2. Runs the metrics in references/analysis-types.md
       3. Renders the report from references/report-template.md
       4. Returns the markdown report
```

## How to Use It

### Step 1 — Locate the repository

Ask the user for an absolute path if not provided. Verify it is a git repository:

```bash
test -d "<repo-path>/.git" && echo "OK"
```

If not, stop and report that the path is not a git repo.

### Step 2 — Decide the time window

Default to the last **30 days** if the user does not specify. Accept these forms:

- `last 7 days` → `--since="7 days ago"`
- `last 30 days` (default) → `--since="30 days ago"`
- `last N days` → `--since="N days ago"`
- `since YYYY-MM-DD` → `--since="YYYY-MM-DD"`
- `all time` → no `--since` filter

### Step 3 — Collect metrics

Run the commands in `references/analysis-types.md`. Each section has a one-line `git` or shell command. Run them in parallel when possible. Capture stdout; ignore stderr unless the command fails entirely.

### Step 4 — Render the report

Fill in `references/report-template.md` with the collected values. Replace every `{{placeholder}}` with the actual data. If a metric could not be computed (e.g., no commits in window), write `n/a` rather than omitting the section.

### Step 5 — Deliver

Print the final markdown report directly in the conversation. Do not write it to a file unless the user asks.

## Commands

### Verify the repo

```bash
test -d "<repo-path>/.git" && echo "valid git repo" || echo "not a git repo"
```

### Commit count and date range

```bash
git -C "<repo-path>" log --since="30 days ago" --pretty=format:"%h|%ai|%an|%s" --no-merges
```

### Commits per day (last 30 days)

```bash
git -C "<repo-path>" log --since="30 days ago" --pretty=format:"%ad" --date=short --no-merges \
  | awk '{print $1}' \
  | sort | uniq -c | sort -rn
```

### Top contributors

```bash
git -C "<repo-path>" shortlog -sn --no-merges --since="30 days ago"
```

### File churn (top 20 files by changes)

```bash
git -C "<repo-path>" log --since="30 days ago" --no-merges --name-only --pretty=format: \
  | grep -v '^$' | sort | uniq -c | sort -rn | head -20
```

### Branch list

```bash
git -C "<repo-path>" branch -a
```

### Working tree status

```bash
git -C "<repo-path>" status --short
git -C "<repo-path>" status --short | wc -l
```

### Largest files (current tree)

```bash
git -C "<repo-path>" ls-files | xargs -I {} sh -c 'wc -l "{}" 2>/dev/null' \
  | sort -rn | head -10
```

### Language breakdown (rough)

```bash
git -C "<repo-path>" ls-files \
  | awk -F. '{print $NF}' | sort | uniq -c | sort -rn | head -15
```

### Bundled helper script

For convenience, a wrapper that runs every metric and prints a JSON object is included at `scripts/analyze.sh`:

```bash
bash scripts/analyze.sh "<repo-path>" 30
```

The script writes a single JSON object to stdout with all metrics. The agent then fills the report template from that JSON.

## Configuration

This skill has no configuration. There are no environment variables, no config files, no per-user state.

If the user wants a different time window, pass it as a parameter when invoking the skill (the agent handles `--since` translation).

## Output Format

Always markdown. Always uses the structure in `references/report-template.md`. Sections in order:

1. Header (repo path, time window, generated-at timestamp)
2. Summary (one paragraph of plain prose)
3. Commit activity (table + sparkline-style ASCII bar)
4. Top contributors (table)
5. File churn (table)
6. Branches (list)
7. Working tree (summary line)
8. Language breakdown (table)
9. Notes / caveats (free text)

## Limitations

- **Read-only.** This skill never modifies the repo. It will not create branches, amend commits, push, or clean the working tree.
- **Local only.** Works only with repositories on the local filesystem. For GitHub/GitLab repos, clone them first.
- **No semantic analysis.** Counts lines, commits, and files. Does not parse code, detect bugs, or assess architecture.
- **No blame analytics.** "Bus factor" and ownership concentration are out of scope — would need `git blame` over the full history, which is expensive on large repos.
- **Time-zone naive.** Commit dates are reported in the author's local zone as recorded by git, not normalized.
- **Binary files.** Line counts exclude binary files. Churn counts include them.

## Files

- `SKILL.md` — this file
- `_meta.json` — registry metadata
- `LICENSE.txt` — MIT license
- `references/analysis-types.md` — full list of metrics and exact commands
- `references/report-template.md` — the report structure to render
- `scripts/analyze.sh` — optional helper that emits all metrics as JSON

## Credits

Built as a generic, no-credentials workflow template for ClawHub.
