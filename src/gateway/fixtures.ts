import type {
  ConversationSummary,
  MemoryEntry,
  SkillCard,
} from "./types";

export const seedConversations: ConversationSummary[] = [
  {
    id: "welcome",
    title: "Welcome to OpenClaw",
    updatedAt: Date.now() - 1000 * 60 * 60 * 2,
  },
  {
    id: "automation",
    title: "Daily automation plan",
    updatedAt: Date.now() - 1000 * 60 * 60 * 26,
  },
  {
    id: "skills",
    title: "Skill recommendations",
    updatedAt: Date.now() - 1000 * 60 * 60 * 72,
  },
];

export const seedMessages = {
  welcome: [
    {
      id: "w1",
      role: "system" as const,
      content:
        "You are OpenClaw — a personal assistant running on this device. Speak concisely, show structured thinking. Never invent credentials.",
      createdAt: Date.now() - 1000 * 60 * 3,
    },
    {
      id: "w2",
      role: "user" as const,
      content: "Hey — what can you do right now, locally? Walk me through it.",
      createdAt: Date.now() - 1000 * 60 * 2,
    },
    {
      id: "w3",
      role: "agent" as const,
      content:
        "Right now, I can:\n\n- **Chat** with you in this pane, streaming token-by-token.\n- **Browse skills** — procedural extensions that teach me to act. Take a look at the Skills tab.\n- **Keep memory** across sessions — topics, notes, preferences you've mentioned.\n- **Show the live event stream** (thinking, tool calls, results) on the right side of the chat.\n\nEverything is local — no cloud account, no API keys beyond what you've set up yourself.\n\nWant to start with a question, explore a skill, or peek at the memory timeline?",
      createdAt: Date.now() - 1000 * 60,
    },
  ],
  automation: [
    {
      id: "a1",
      role: "user" as const,
      content: "Plan a simple Monday-morning automation.",
      createdAt: Date.now() - 1000 * 60 * 60 * 20,
    },
    {
      id: "a2",
      role: "agent" as const,
      content:
        "Here's a safe, minimal Monday-morning automation:\n\n1. `09:00` — Read the local git repo for commits from the weekend.\n2. `09:05` — Summarize the top 3 changes in a short bullet list.\n3. `09:10` — Write that summary into a file at `reports/monday.md`.\n\nNo network calls, no credentials, no external API. Ready to turn into a skill?",
      createdAt: Date.now() - 1000 * 60 * 60 * 19,
    },
  ],
  skills: [
    {
      id: "s1",
      role: "user" as const,
      content: "Recommend a couple of skills for a developer.",
      createdAt: Date.now() - 1000 * 60 * 60 * 60,
    },
    {
      id: "s2",
      role: "agent" as const,
      content:
        "Two to try first:\n\n- **git-repo-analyst** — turns a local repo into a readable report.\n- **skill-scaffolder** — helps you write a new skill from a template.\n\nBoth are in your Skills tab.",
      createdAt: Date.now() - 1000 * 60 * 60 * 59,
    },
  ],
};

const sampleSkillBody = (name: string, desc: string) => `# ${name}

${desc}

## What This Skill Does

Teach the agent a concrete, repeatable behavior. Each run produces a small, useful artifact: a report, a diff, or a file.

## Prerequisites

- A local environment with a shell available.
- Nothing else required by default. Some specialized skills may need an API key; this one does not.

## How to Use It

1. Trigger by name. The agent will ask for a single required input (usually a path or a short query).
2. The agent runs the workflow, streams events to the Live page, and replies with a structured result.
3. If the run fails, a short note appears in the response — no stack traces, no noise.

## Commands

- \`run ${name.toLowerCase()}\` — invoke the skill with the default input path.
- \`explain ${name.toLowerCase()}\` — have the agent describe its own workflow in plain language.

## Limitations

- Runs locally only. Does not push files to remote hosts or post to any API on its own.
- The agent may ask for clarification before running if the request is ambiguous.
- This skill is not a replacement for a CI job or a proper deployment pipeline — use it for one-shot exploratory runs.
`;

export const seedSkills: SkillCard[] = [
  {
    id: "git-repo-analyst",
    name: "git-repo-analyst",
    emoji: "📊",
    description:
      "Turn a local git repository into a structured engineering report — commits, churn, branches, working-tree state.",
    tags: ["git", "reporting", "engineering", "read-only"],
    body: sampleSkillBody(
      "git-repo-analyst",
      "Reads a local git repository and emits a markdown report summarizing recent activity, churn, contributors, and the state of the working tree."
    ),
    installedAt: Date.now() - 1000 * 60 * 60 * 12,
  },
  {
    id: "skill-scaffolder",
    name: "skill-scaffolder",
    emoji: "🦞",
    description:
      "Scaffolds a new skill from a small template: SKILL.md body, frontmatter, trigger phrases, and limitations sections.",
    tags: ["meta", "authoring", "templates"],
    body: sampleSkillBody(
      "skill-scaffolder",
      "Writes a new skill folder with the conventional sections and a placeholder command area, then opens it for editing."
    ),
    installedAt: Date.now() - 1000 * 60 * 60 * 50,
  },
  {
    id: "file-index",
    name: "file-index",
    emoji: "🗂️",
    description:
      "Walks a local directory tree and emits a compact file index, with optional filters by extension or last-modified window.",
    tags: ["filesystem", "indexing", "read-only"],
    body: sampleSkillBody(
      "file-index",
      "Walks a local directory tree, skipping common blacklisted folders (node_modules, .git), and writes an ordered index of files with size and last-modified timestamps."
    ),
    installedAt: Date.now() - 1000 * 60 * 60 * 96,
  },
  {
    id: "weekly-digest",
    name: "weekly-digest",
    emoji: "📰",
    description:
      "Produces a weekly markdown digest by re-reading recent memory entries and the most active conversations in the last 7 days.",
    tags: ["summary", "memory", "reports"],
    body: sampleSkillBody(
      "weekly-digest",
      "Scans the local memory timeline and recent conversations, then drafts a short weekly digest suitable for a handwritten log."
    ),
    installedAt: Date.now() - 1000 * 60 * 60 * 140,
  },
  {
    id: "spell-check",
    name: "spell-check",
    emoji: "🔤",
    description:
      "Runs a simple dictionary check on a single file, emitting a list of unknown words with line numbers for manual review.",
    tags: ["linting", "text"],
    body: sampleSkillBody(
      "spell-check",
      "Tokenizes a document, compares each word against a small English dictionary, and lists suspects with line numbers. Never edits the document on its own."
    ),
    installedAt: Date.now() - 1000 * 60 * 60 * 200,
  },
  {
    id: "time-capsule",
    name: "time-capsule",
    emoji: "⏳",
    description:
      "Writes a short note to the memory timeline with a prompt, to be surfaced again on a future date you choose.",
    tags: ["memory", "reminders"],
    body: sampleSkillBody(
      "time-capsule",
      "Captures a short note and a date, then stores it in memory so the agent will surface it again on the requested future date."
    ),
    installedAt: Date.now() - 1000 * 60 * 60 * 260,
  },
];

export const seedMemory: MemoryEntry[] = [
  {
    id: "m1",
    title: "User prefers short replies in chat",
    preview:
      "Default to 3-5 bullet answers, unless the user explicitly asks for prose. Keep code blocks focused.",
    body:
      "The user has repeatedly asked for shorter answers and flagged long replies as hard to scan. Default to 3-5 bullet points, with one sentence of context at the top. Only switch to prose when they say something like 'tell me the full story' or 'explain in detail'.",
    tags: ["preference", "style"],
    topic: "communication",
    createdAt: Date.now() - 1000 * 60 * 60 * 24 * 12,
  },
  {
    id: "m2",
    title: "Main project is a Flutter mobile app",
    preview:
      "Primary repo contains a mobile Flutter app with a Shift/Loop schedule screen. Platform-specific code in lib/screens.",
    body:
      "Most daily activity happens in the local Flutter project. Platform-targeted screens include lib/screens/home_screen.dart, lib/screens/shift_detail.dart, lib/screens/loop_setting.dart, and lib/screens/statistics_screen.dart. Database helpers live under lib/database. When discussing changes, always default to this project unless the user specifies another path.",
    tags: ["project", "flutter"],
    topic: "projects",
    createdAt: Date.now() - 1000 * 60 * 60 * 24 * 9,
  },
  {
    id: "m3",
    title: "OpenClaw skills should be read-only by default",
    preview:
      "A skill should not create files or run network calls unless the user opts in. Flag 'dangerous' skills with a prompt.",
    body:
      "The default posture for a new skill is read-only. If a skill wants to write to disk, post to an API, or execute an arbitrary shell command, the agent must prompt for confirmation first and describe the exact scope of the side effect. The user can then approve, scope-down, or cancel.",
    tags: ["policy", "safety"],
    topic: "skills",
    createdAt: Date.now() - 1000 * 60 * 60 * 24 * 6,
  },
  {
    id: "m4",
    title: "Working hours",
    preview:
      "Roughly 10:00 — 19:00 local time. Quiet before 10 and after 19:30; avoid unsolicited messages outside the window.",
    body:
      "User is reachable and active roughly between 10:00 and 19:00 local time. Outside of that window, don't send unsolicited proactive notifications; queue them instead for the next morning.",
    tags: ["preference", "schedule"],
    topic: "communication",
    createdAt: Date.now() - 1000 * 60 * 60 * 24 * 3,
  },
  {
    id: "m5",
    title: "Interesting topic — git history analysis",
    preview:
      "User has been exploring git history and churn reports. Surface relevant skills when they open new repo paths.",
    body:
      "Recent session focused on local git analytics. When the user points the assistant at a new repository, proactively offer a short 'at a glance' summary using the git-repo-analyst skill, then ask if they want the full report.",
    tags: ["topic", "git"],
    topic: "projects",
    createdAt: Date.now() - 1000 * 60 * 60 * 20,
  },
  {
    id: "m6",
    title: "Command palette quick-ref",
    preview:
      "Short `/command` names: /skills /memory /live /new. Keep them discoverable in the composer placeholder.",
    body:
      "Typing `/` in the composer surfaces a small inline palette of actions: /skills, /memory, /live, /new. These are navigational shortcuts only; they don't send a message.",
    tags: ["ui", "command"],
    topic: "ui",
    createdAt: Date.now() - 1000 * 60 * 60 * 24 * 5,
  },
];

export const gatewayVersion = "0.1.0-local";
