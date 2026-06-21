import type {
  ChatMessage,
  ConversationSummary,
  GatewayEvent,
  MemoryEntry,
  SkillCard,
} from "./types";
import {
  gatewayVersion,
  seedConversations,
  seedMemory,
  seedMessages,
  seedSkills,
} from "./fixtures";

function delay(ms: number): Promise<void> {
  return new Promise((r) => setTimeout(r, ms));
}

function toWords(text: string): string[] {
  const out: string[] = [];
  const re = /(\s+|\S+)/g;
  let m: RegExpExecArray | null;
  while ((m = re.exec(text)) !== null) {
    out.push(m[0]);
  }
  return out;
}

function cannedReply(userText: string): string {
  const lower = userText.toLowerCase();
  if (lower.includes("hello") || lower.includes("hi") || lower.includes("hey")) {
    return "Hey — welcome in. I can chat, run skills, and show you a live event stream. Want me to walk through the Skills tab, or just start by asking me anything?";
  }
  if (lower.includes("skill")) {
    return "Think of skills as reusable procedures. Your installed skills live in the **Skills** tab — click any card to see its full SKILL.md and try it. Recommendation: start with `git-repo-analyst`, which reads a local repo and writes a short report.";
  }
  if (lower.includes("memory")) {
    return "Memory is everything I persist across sessions: preferences, facts about your projects, topics you've explored. Open the **Memory** tab to see the timeline — it's fully readable and fully local.";
  }
  if (lower.includes("live") || lower.includes("event")) {
    return "The Live stream (right side of the chat) shows what I'm doing as I do it: thinking tokens, tool invocations, results, and errors. It's the debugging view — useful when a skill does something unexpected.";
  }
  if (lower.includes("repo") || lower.includes("git") || lower.includes("codebase")) {
    return "I can walk through a local git repo with the `git-repo-analyst` skill. Give me an absolute path and I'll produce a short markdown report covering commits, contributors, churn, branches, and the working-tree state. Want to pick a path, or should I start with `./`?";
  }
  if (lower.includes("thanks") || lower.includes("thank you")) {
    return "Anytime. Let me know when you want a fresh report, a new skill scaffolded, or just a second opinion.";
  }
  return (
    "That's an interesting question. Here's how I'd approach it:\n\n" +
    "1. **Clarify the goal** — what counts as a good outcome?\n" +
    "2. **Pick the smallest tool** that reaches it (local shell, a skill, nothing).\n" +
    "3. **Run it, report it** — live events stream to the right; final answer shows up here.\n\n" +
    "If you want, paste or describe a small concrete task and I'll run it end-to-end."
  );
}

export const gateway = {
  version(): string {
    return gatewayVersion;
  },

  listConversations(): Promise<ConversationSummary[]> {
    return Promise.resolve(
      [...seedConversations].sort((a, b) => b.updatedAt - a.updatedAt)
    );
  },

  listSkills(): Promise<SkillCard[]> {
    return Promise.resolve(seedSkills.slice());
  },

  listMemory(): Promise<MemoryEntry[]> {
    return Promise.resolve(
      [...seedMemory].sort((a, b) => b.createdAt - a.createdAt)
    );
  },

  getInitialMessages(conversationId: string): Promise<ChatMessage[]> {
    const list =
      (seedMessages as Record<string, ChatMessage[]>)[conversationId] ||
      [];
    return Promise.resolve(list.slice());
  },

  async *sendMessage(
    _conversationId: string,
    text: string
  ): AsyncIterable<GatewayEvent> {
    const base = Date.now();
    const reply = cannedReply(text);
    const words = toWords(reply);

    yield { type: "thinking", at: base, text: "Deciding how to reply…" };
    await delay(180);

    yield {
      type: "tool.call",
      at: base + 200,
      tool: "intent-classifier",
      payload: { intent: "reply-concise", context_length: text.length },
    };
    await delay(160);

    yield {
      type: "tool.result",
      at: base + 360,
      tool: "intent-classifier",
      ok: true,
      payload: { confidence: 0.87, words: words.length },
    };
    await delay(120);

    for (let i = 0; i < words.length; i++) {
      yield { type: "text", at: base + 380 + i * 18, delta: words[i] };
      await delay(18);
    }

    yield { type: "thinking", at: base + 800, text: "Done." };
  },
};
