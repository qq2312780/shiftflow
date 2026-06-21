export type Role = "user" | "agent" | "system" | "tool";

export type ChatMessage = {
  id: string;
  role: Role;
  content: string;
  createdAt: number;
  tokens?: number;
  streaming?: boolean;
};

export type ConversationSummary = {
  id: string;
  title: string;
  updatedAt: number;
};

export type GatewayEvent =
  | { type: "thinking"; at: number; text: string }
  | { type: "text"; at: number; delta: string }
  | { type: "tool.call"; at: number; tool: string; payload: Record<string, unknown> }
  | { type: "tool.result"; at: number; tool: string; ok: boolean; payload: Record<string, unknown> }
  | { type: "error"; at: number; message: string };

export type SkillCard = {
  id: string;
  name: string;
  description: string;
  emoji: string;
  tags: string[];
  body: string;
  installedAt: number;
};

export type MemoryEntry = {
  id: string;
  title: string;
  preview: string;
  body: string;
  tags: string[];
  topic: string;
  createdAt: number;
};
