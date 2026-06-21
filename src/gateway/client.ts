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
  const text = userText.toLowerCase();
  if (
    text.includes("你好") ||
    text.includes("hi") ||
    text.includes("hey") ||
    text.includes("hello")
  ) {
    return "你好 — 欢迎来到 OpenClaw。我可以和你对话、执行技能，并且实时展示事件流。想先看一遍「技能」页，还是直接向我提问？";
  }
  if (text.includes("技能") || text.includes("skill")) {
    return "可以把技能理解为可复用的流程。已安装的技能都在「**技能**」页 — 点击任意卡片可查看完整的 SKILL.md 并上手。推荐先试试 `git-repo-analyst`：它会读取本地仓库，写出一份简短报告。";
  }
  if (text.includes("记忆") || text.includes("memory")) {
    return "记忆是跨会话持久保存的信息：偏好、项目事实、你探索过的话题。打开「**记忆**」页可看到完整的时间线 — 完全可读，也完全本地化。";
  }
  if (text.includes("实时") || text.includes("事件") || text.includes("live") || text.includes("event")) {
    return "「实时事件流」位于对话右侧，会在我做事的同时展示：思考过程、工具调用、结果、错误。它相当于调试视图 — 在某个技能出现意外行为时特别有用。";
  }
  if (text.includes("仓库") || text.includes("git") || text.includes("代码库")) {
    return "我可以通过 `git-repo-analyst` 技能遍历本地 git 仓库。请给我一个绝对路径，我会生成一份简短的 Markdown 报告，涵盖提交、贡献者、文件变更量、分支以及工作区状态。你想指定一个路径，还是先从 `./` 开始？";
  }
  if (text.includes("谢谢") || text.includes("thanks") || text.includes("感谢")) {
    return "随时开口。当你需要一份新报告、搭建一个新技能，或者只想听听第二意见时，告诉我就行。";
  }
  return (
    "这是一个有意思的问题。我的建议思路如下：\n\n" +
    "1. **明确目标** — 对「好结果」的定义是什么？\n" +
    "2. **选择最小可用工具**（本地 shell、某个技能，或者什么都不需要）。\n" +
    "3. **运行并报告** — 右侧会实时推送事件；最终答案会出现在这里。\n\n" +
    "如果你愿意，可以粘贴或描述一个具体的小任务，我会从头到尾把它跑一遍。"
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

    yield { type: "thinking", at: base, text: "正在决定如何回答…" };
    await delay(180);

    yield {
      type: "tool.call",
      at: base + 200,
      tool: "意图分类器",
      payload: { intent: "简洁回答", context_length: text.length },
    };
    await delay(160);

    yield {
      type: "tool.result",
      at: base + 360,
      tool: "意图分类器",
      ok: true,
      payload: { confidence: 0.87, words: words.length },
    };
    await delay(120);

    for (let i = 0; i < words.length; i++) {
      yield { type: "text", at: base + 380 + i * 18, delta: words[i] };
      await delay(18);
    }

    yield { type: "thinking", at: base + 800, text: "回答完成。" };
  },
};
