# Analysis Types

This document defines the full set of metrics the agent collects when running `git-repo-analyst`. Each section includes the exact command, the expected output format, and a one-line interpretation guide.

All commands assume:

- `<repo>` is the absolute path to a local git repository.
- `<days>` is the analysis window in days (default 30).

## 1. Repository Identity

```bash
git -C "<repo>" rev-parse --is-inside-work-tree
git -C "<repo>" remote -v
git -C "<repo>" rev-parse --abbrev-ref HEAD
```

Captures: whether the path is a git repo, remotes, current branch.

## 2. Commit Activity

### Total commits in window

```bash
git -C "<repo>" rev-list --count --no-merges HEAD --since="<days> days ago"
```

### Commits per day

```bash
git -C "<repo>" log --since="<days> days ago" --pretty=format:"%ad" --date=short --no-merges \
  | awk '{print $1}' \
  | sort | uniq -c | sort -rn
```

Output: `<count> <YYYY-MM-DD>` lines, descending by count.

### Date range covered

```bash
git -C "<repo>" log --since="<days> days ago" --pretty=format:"%ad" --date=short --no-merges \
  | tail -1
git -C "<repo>" log --since="<days> days ago" --pretty=format:"%ad" --date=short --no-merges \
  | head -1
```

The newest commit date and the oldest commit date in the window.

### Active days

```bash
git -C "<repo>" log --since="<days> days ago" --pretty=format:"%ad" --date=short --no-merges \
  | awk '{print $1}' | sort -u | wc -l
```

Number of distinct calendar days with at least one commit.

## 3. Contributors

### Top contributors (commit count)

```bash
git -C "<repo>" shortlog -sn --no-merges --since="<days> days ago"
```

Output: `<count> <Name> (<email>)` lines, descending.

### Top contributors (lines added/removed)

```bash
git -C "<repo>" log --since="<days> days ago" --no-merges --pretty=tformat:"" --numstat \
  | awk '{add+=$1; del+=$2} END {print add+0, del+0, "total"}'
```

Optional — single line summarizing the window's total churn.

## 4. File Churn

```bash
git -C "<repo>" log --since="<days> days ago" --no-merges --name-only --pretty=format: \
  | grep -v '^$' | sort | uniq -c | sort -rn | head -20
```

Output: `<count> <path>` lines. Counts each file's appearance across commits.

## 5. Branches

```bash
git -C "<repo>" branch -a
```

All local and remote-tracking branches. The agent groups them into `local` and `remote` for the report.

```bash
git -C "<repo>" branch -a | wc -l
```

Total branch count.

## 6. Working Tree

```bash
git -C "<repo>" status --short
git -C "<repo>" status --short | wc -l
```

The full short status and the count of dirty entries.

```bash
git -C "<repo>" diff --stat
```

Stat summary of unstaged changes, if any.

## 7. Largest Tracked Files

```bash
git -C "<repo>" ls-files | xargs -I {} sh -c 'wc -l "{}" 2>/dev/null' \
  | sort -rn | head -10
```

Top 10 tracked files by line count. Skips binary files (which report `0` from `wc -l`).

## 8. Language Breakdown

```bash
git -C "<repo>" ls-files \
  | awk -F. '{print $NF}' | sort | uniq -c | sort -rn | head -15
```

Counts files by extension. This is a rough language indicator — it conflates `.js` source with `.js` config, treats no-extension files as one bucket, etc. The report should label this section as "approximate".

## 9. Tags and Releases

```bash
git -C "<repo>" tag --sort=-creatordate | head -10
```

The 10 most recent tags, with their dates. Useful for understanding release cadence.

## Error Handling

For each command:

- If the command exits non-zero, capture stderr, mark the metric as `n/a` in the report, and continue.
- Never abort the whole report because one metric failed.
- Common failure modes: empty repo, shallow clone, missing `--since` history. Report the failure reason in the Notes section.

## Performance Notes

- On large repos (>100k commits), prefer `--since` to bound history scans.
- For the per-file churn, `--name-only` is faster than `--name-status` because it does not resolve renames.
- Avoid `git log --follow` in this skill — it walks history per file and is O(files × history).
