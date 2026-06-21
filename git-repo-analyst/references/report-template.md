# Report Template

The agent renders the analysis output by filling this template. Replace every `{{placeholder}}` with a concrete value. If a metric could not be computed, write `n/a`.

---

# Git Repository Report

**Repository:** `{{repo_path}}`
**Window:** last {{days}} days ({{since_date}} → {{until_date}})
**Generated:** {{generated_at}}

## Summary

{{summary_paragraph}}

Plain-prose paragraph, 2–4 sentences. Cover: total commits, active contributors, dominant file(s) by churn, working-tree state.

## Commit Activity

| Day | Commits |
| --- | ------- |
{{commit_activity_rows}}

Visual bar (one `#` per commit, capped at 40):

```
{{commit_activity_bars}}
```

**Total commits (no merges):** {{total_commits}}
**Active days:** {{active_days}} of {{days}}

## Top Contributors

| Commits | Name | Email |
| ------- | ---- | ----- |
{{contributor_rows}}

Total contributors in window: {{contributor_count}}

## File Churn

| Changes | Path |
| ------- | ---- |
{{churn_rows}}

Top {{churn_count}} files by commit-touch count. Files that change often are candidates for refactoring, splitting, or extra test coverage.

## Branches

**Total branches:** {{branch_count}} ({{local_count}} local, {{remote_count}} remote)

{{branch_list}}

## Working Tree

**Status:** {{working_tree_status}}

{{working_tree_detail}}

If clean, write `Working tree clean — no uncommitted changes.`

## Largest Tracked Files

| Lines | Path |
| ----- | ---- |
{{largest_file_rows}}

Binary files are skipped from line counts.

## Language Breakdown (approximate)

| Files | Extension |
| ----- | --------- |
{{language_rows}}

Counts files by extension only — does not parse contents.

## Recent Tags

{{tag_list}}

If there are no tags, write `No tags found in this repository.`

## Notes

{{notes}}

Free text. Capture: anything that failed, anything the user should know, suggested follow-up analyses.

---

## Placeholder Reference

| Placeholder | Type | Source |
| --- | --- | --- |
| `{{repo_path}}` | string | user input |
| `{{days}}` | int | user input or 30 |
| `{{since_date}}` | `YYYY-MM-DD` | oldest commit in window |
| `{{until_date}}` | `YYYY-MM-DD` | newest commit in window |
| `{{generated_at}}` | ISO 8601 | now() |
| `{{summary_paragraph}}` | prose | composed from metrics |
| `{{commit_activity_rows}}` | markdown rows | per-day counts |
| `{{commit_activity_bars}}` | text block | `#`-per-commit bars |
| `{{total_commits}}` | int | `rev-list --count` |
| `{{active_days}}` | int | distinct dates |
| `{{contributor_rows}}` | markdown rows | `shortlog -sn` |
| `{{contributor_count}}` | int | length of `shortlog` |
| `{{churn_rows}}` | markdown rows | per-file touch count |
| `{{churn_count}}` | int | ≤ 20 |
| `{{branch_count}}` | int | `branch -a \| wc -l` |
| `{{local_count}}` | int | local branches |
| `{{remote_count}}` | int | remote-tracking branches |
| `{{branch_list}}` | bullet list | branch names grouped by kind |
| `{{working_tree_status}}` | short string | clean / N modified / etc. |
| `{{working_tree_detail}}` | code block or empty | `status --short` output |
| `{{largest_file_rows}}` | markdown rows | top 10 by `wc -l` |
| `{{language_rows}}` | markdown rows | extension counts |
| `{{tag_list}}` | bullet list or `n/a` | recent tags |
| `{{notes}}` | prose | free text |
