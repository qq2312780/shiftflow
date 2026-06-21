import type {
  ConversationSummary,
  MemoryEntry,
  SkillCard,
} from "./types";

export const seedConversations: ConversationSummary[] = [
  {
    id: "welcome",
    title: "欢迎使用 OpenClaw",
    updatedAt: Date.now() - 1000 * 60 * 60 * 2,
  },
  {
    id: "automation",
    title: "每日自动化方案",
    updatedAt: Date.now() - 1000 * 60 * 60 * 26,
  },
  {
    id: "skills",
    title: "技能推荐与选型",
    updatedAt: Date.now() - 1000 * 60 * 60 * 72,
  },
];

export const seedMessages = {
  welcome: [
    {
      id: "w1",
      role: "system" as const,
      content:
        "你是运行在本机的 OpenClaw — 一个个人助手。回答要简洁，展示结构化的思考过程。绝不要编造凭证。",
      createdAt: Date.now() - 1000 * 60 * 3,
    },
    {
      id: "w2",
      role: "user" as const,
      content: "你好 — 你现在能在本机做些什么？带我走一遍。",
      createdAt: Date.now() - 1000 * 60 * 2,
    },
    {
      id: "w3",
      role: "agent" as const,
      content:
        "现在我可以：\n\n- **在此对话** 中与你交谈，并逐字流式输出回复；\n- **浏览技能** — 教会我如何行动的可复用流程，详见「技能」页；\n- **记录记忆** — 跨会话保留你提到过的偏好、笔记、话题；\n- **展示实时事件流**（思考、工具调用、结果等），位于对话右侧。\n\n一切都在本机运行 — 无需云端账号，也不需要额外的 API Key。\n\n想从一个问题开始，还是先看看某个技能，或者翻一翻记忆时间线？",
      createdAt: Date.now() - 1000 * 60,
    },
  ],
  automation: [
    {
      id: "a1",
      role: "user" as const,
      content: "给一个周一早晨的简单自动化方案。",
      createdAt: Date.now() - 1000 * 60 * 60 * 20,
    },
    {
      id: "a2",
      role: "agent" as const,
      content:
        "一个安全、最小化的周一早晨自动化：\n\n1. `09:00` — 读取本地 git 仓库，汇总周末提交；\n2. `09:05` — 以要点形式提炼 3 条最值得关注的变更；\n3. `09:10` — 将摘要写入 `reports/monday.md`。\n\n不访问网络，不使用凭证，也不调用任何外部 API。要把它写成一个技能吗？",
      createdAt: Date.now() - 1000 * 60 * 60 * 19,
    },
  ],
  skills: [
    {
      id: "s1",
      role: "user" as const,
      content: "给开发者推荐两三个技能。",
      createdAt: Date.now() - 1000 * 60 * 60 * 60,
    },
    {
      id: "s2",
      role: "agent" as const,
      content:
        "建议先尝试这两个：\n\n- **git-repo-analyst** — 把本地仓库变成一份可读的报告；\n- **skill-scaffolder** — 从模板出发，帮你搭建一个新技能。\n\n它们都在「技能」页里。",
      createdAt: Date.now() - 1000 * 60 * 60 * 59,
    },
  ],
};

const sampleSkillBody = (name: string, desc: string) => `# ${name}

${desc}

## 技能做什么

教会助手一个可重复执行的具体行为。每次运行都会产生一个小而有用的产物：一份报告、一个差异对比，或者一个文件。

## 运行前提

- 本机提供可用的 shell 环境；
- 默认不再需要其它东西。部分专业技能可能需要 API Key，但本技能不需要。

## 使用方式

1. 以名称或触发词唤起；助手会询问唯一的必填输入（通常是路径或一段简短查询）。
2. 助手执行工作流，将事件实时推送到「实时」页，并在此处给出结构化结果。
3. 若运行失败，回复中只会出现简短提示 — 不输出冗长的堆栈信息。

## 常用命令

- \`run ${name.toLowerCase()}\` — 使用默认输入路径执行该技能；
- \`explain ${name.toLowerCase()}\` — 让助手用平实语言描述它自己的工作流程。

## 限制

- 只在本机运行；不会主动向外部推送文件或调用 API。
- 如果请求存在歧义，助手可能会先询问你的意图再执行。
- 该技能不能替代正式的 CI 任务或发布流程 — 仅用于一次性探索性执行。
`;

export const seedSkills: SkillCard[] = [
  {
    id: "git-repo-analyst",
    name: "git-repo-analyst",
    emoji: "📊",
    description:
      "把本地 git 仓库变成一份结构化的工程报告：提交摘要、变更量、分支、工作区状态。",
    tags: ["git", "报告", "工程", "只读"],
    body: sampleSkillBody(
      "git-repo-analyst",
      "读取本地 git 仓库，生成一份 Markdown 报告，汇总近期活跃、文件变更量、贡献者与工作区状态。"
    ),
    installedAt: Date.now() - 1000 * 60 * 60 * 12,
  },
  {
    id: "skill-scaffolder",
    name: "skill-scaffolder",
    emoji: "🦞",
    description:
      "从最小模板搭建一个新技能：SKILL.md 正文、frontmatter、触发词以及限制说明。",
    tags: ["元技能", "编写", "模板"],
    body: sampleSkillBody(
      "skill-scaffolder",
      "按约定结构写入一个新技能文件夹，包含标准章节和可编辑的命令占位区域。"
    ),
    installedAt: Date.now() - 1000 * 60 * 60 * 50,
  },
  {
    id: "file-index",
    name: "file-index",
    emoji: "🗂️",
    description:
      "遍历本地目录树，生成紧凑的文件索引；可按扩展名或最近修改时间筛选。",
    tags: ["文件系统", "索引", "只读"],
    body: sampleSkillBody(
      "file-index",
      "遍历本地目录树，跳过常见黑名单目录（node_modules、.git），输出按大小与最近修改时间排序的文件清单。"
    ),
    installedAt: Date.now() - 1000 * 60 * 60 * 96,
  },
  {
    id: "weekly-digest",
    name: "weekly-digest",
    emoji: "📰",
    description:
      "重读最近 7 天的记忆条目与最活跃对话，生成一份周度 Markdown 摘要。",
    tags: ["摘要", "记忆", "报告"],
    body: sampleSkillBody(
      "weekly-digest",
      "扫描本地记忆时间线和近期对话，起草一份适合写入手账的简短周度总结。"
    ),
    installedAt: Date.now() - 1000 * 60 * 60 * 140,
  },
  {
    id: "spell-check",
    name: "spell-check",
    emoji: "🔤",
    description:
      "对单个文件执行简单的词典检查，输出可疑词的清单与所在行号，供人工复核。",
    tags: ["检查", "文本"],
    body: sampleSkillBody(
      "spell-check",
      "对文档进行分词，对照小型词典匹配未知词，并输出行号；绝不会自动修改原文。"
    ),
    installedAt: Date.now() - 1000 * 60 * 60 * 200,
  },
  {
    id: "time-capsule",
    name: "time-capsule",
    emoji: "⏳",
    description:
      "把一条短笔记连同提示信息一起写入记忆时间线，在你选择的未来日期再次出现。",
    tags: ["记忆", "提醒"],
    body: sampleSkillBody(
      "time-capsule",
      "记录一条短笔记和一个日期，存入记忆，以便助手在指定的未来日期再次提醒你。"
    ),
    installedAt: Date.now() - 1000 * 60 * 60 * 260,
  },
];

export const seedMemory: MemoryEntry[] = [
  {
    id: "m1",
    title: "聊天中偏好简短回复",
    preview:
      "默认使用 3-5 条要点回答，除非用户明确要求长文。代码片段要聚焦重点。",
    body:
      "用户多次表示喜欢简短回答，并认为过长的回复难以快速阅读。默认以 3-5 条要点组织，上方用一句话给出上下文。仅当用户说「详细讲一下」或「完整地告诉我」时，再切换为段落式叙述。",
    tags: ["偏好", "风格"],
    topic: "沟通方式",
    createdAt: Date.now() - 1000 * 60 * 60 * 24 * 12,
  },
  {
    id: "m2",
    title: "主要项目：Flutter 移动端应用",
    preview:
      "本地的主要仓库是一个 Flutter 移动应用，包含班次/循环排班页面。平台相关代码在 lib/screens。",
    body:
      "日常工作的主要对象是本地的 Flutter 项目。面向平台的页面主要集中在 lib/screens/home_screen.dart、lib/screens/shift_detail.dart、lib/screens/loop_setting.dart 以及 lib/screens/statistics_screen.dart，数据库辅助代码在 lib/database。讨论代码变更时，默认指向该项目，除非用户另行指定路径。",
    tags: ["项目", "flutter"],
    topic: "项目",
    createdAt: Date.now() - 1000 * 60 * 60 * 24 * 9,
  },
  {
    id: "m3",
    title: "新技能默认应是只读的",
    preview:
      "除非用户明确许可，否则技能不应创建文件或发起网络调用。对「有风险」的技能必须先提示。",
    body:
      "新技能的默认姿态是「只读」。当一个技能需要写入磁盘、调用外部 API 或执行任意 shell 命令时，助手必须先请求确认，并明确描述副作用的具体范围。用户可以选择同意、缩小范围或取消。",
    tags: ["规则", "安全"],
    topic: "技能",
    createdAt: Date.now() - 1000 * 60 * 60 * 24 * 6,
  },
  {
    id: "m4",
    title: "工作时间",
    preview:
      "大致在本地时间 10:00 — 19:00；10 点之前与 19:30 之后保持安静，避免主动发消息。",
    body:
      "用户在本地时间 10:00 到 19:00 之间比较活跃。在该时间范围之外，不要主动发送通知；可将它们加入队列，等到次日早上再推送。",
    tags: ["偏好", "时间"],
    topic: "沟通方式",
    createdAt: Date.now() - 1000 * 60 * 60 * 24 * 3,
  },
  {
    id: "m5",
    title: "有趣的话题：git 历史分析",
    preview:
      "用户近来在探索 git 历史与变更量报告。在打开新仓库路径时，主动推荐相关技能。",
    body:
      "最近的会话集中在本地 git 分析。当用户把助手指向一个新仓库时，先用 git-repo-analyst 技能给出一份「快速概览」，再询问是否需要完整报告。",
    tags: ["话题", "git"],
    topic: "项目",
    createdAt: Date.now() - 1000 * 60 * 60 * 20,
  },
  {
    id: "m6",
    title: "命令面板速查",
    preview:
      "简短命令：/skills /memory /live /new。在输入框的占位文本中保持可发现性。",
    body:
      "在输入框中键入 `/` 会弹出一个小的内联面板，列出动作：/skills、/memory、/live、/new。这些只是导航快捷方式，不会实际发送消息。",
    tags: ["界面", "命令"],
    topic: "界面",
    createdAt: Date.now() - 1000 * 60 * 60 * 24 * 5,
  },
];

export const gatewayVersion = "0.1.0-local";
