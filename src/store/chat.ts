import type { ChatMessage, ConversationSummary } from "../gateway/types";
import { create } from "zustand";

type ChatState = {
  activeId: string;
  conversations: ConversationSummary[];
  messagesByConversation: Record<string, ChatMessage[]>;
  isStreaming: boolean;

  setActive: (id: string) => void;
  newConversation: () => string;
  appendMessage: (conversationId: string, message: ChatMessage) => void;
  updateLast: (
    conversationId: string,
    update: (msg: ChatMessage) => ChatMessage
  ) => void;
  setStreaming: (v: boolean) => void;
  ensureLoaded: (conversationId: string, messages: ChatMessage[]) => void;
};

const STORAGE_KEY = "openclaw-ui-state-v1";

type Persisted = {
  activeId: string;
  conversations: ConversationSummary[];
  messagesByConversation: Record<string, ChatMessage[]>;
};

function loadPersisted(): Persisted | null {
  if (typeof window === "undefined") return null;
  try {
    const raw = window.localStorage.getItem(STORAGE_KEY);
    if (!raw) return null;
    const parsed = JSON.parse(raw);
    if (parsed && typeof parsed === "object" && "activeId" in parsed) {
      return parsed as Persisted;
    }
  } catch {
    /* ignore */
  }
  return null;
}

function persist(s: Pick<ChatState, "activeId" | "conversations" | "messagesByConversation">) {
  if (typeof window === "undefined") return;
  try {
    const payload: Persisted = {
      activeId: s.activeId,
      conversations: s.conversations,
      messagesByConversation: s.messagesByConversation,
    };
    window.localStorage.setItem(STORAGE_KEY, JSON.stringify(payload));
  } catch {
    /* ignore */
  }
}

const initial = loadPersisted();

export const useChatStore = create<ChatState>((set, get) => ({
  activeId: initial?.activeId ?? "welcome",
  conversations:
    initial?.conversations ?? [
      { id: "welcome", title: "Welcome", updatedAt: Date.now() },
    ],
  messagesByConversation: initial?.messagesByConversation ?? {},
  isStreaming: false,

  setActive: (id) => {
    set({ activeId: id });
    persist({
      activeId: id,
      conversations: get().conversations,
      messagesByConversation: get().messagesByConversation,
    });
  },

  newConversation: () => {
    const id = "c_" + Math.random().toString(36).slice(2, 9);
    const conv: ConversationSummary = {
      id,
      title: "New conversation",
      updatedAt: Date.now(),
    };
    set((s) => ({
      activeId: id,
      conversations: [conv, ...s.conversations],
      messagesByConversation: { ...s.messagesByConversation, [id]: [] },
    }));
    persist({
      activeId: id,
      conversations: [conv, ...get().conversations],
      messagesByConversation: { ...get().messagesByConversation, [id]: [] },
    });
    return id;
  },

  appendMessage: (conversationId, message) => {
    set((s) => {
      const list = s.messagesByConversation[conversationId] ?? [];
      const next = [...list, message];
      const titleFromUser =
        message.role === "user" && list.length <= 1
          ? message.content.slice(0, 56)
          : undefined;
      const convs = s.conversations.map((c) =>
        c.id === conversationId
          ? {
              ...c,
              updatedAt: message.createdAt,
              title: titleFromUser ?? c.title,
            }
          : c
      );
      return {
        messagesByConversation: {
          ...s.messagesByConversation,
          [conversationId]: next,
        },
        conversations: convs,
      };
    });
    persist({
      activeId: get().activeId,
      conversations: get().conversations,
      messagesByConversation: get().messagesByConversation,
    });
  },

  updateLast: (conversationId, update) => {
    set((s) => {
      const list = s.messagesByConversation[conversationId] ?? [];
      if (list.length === 0) return {};
      const next = list.slice();
      next[next.length - 1] = update(next[next.length - 1]);
      return {
        messagesByConversation: {
          ...s.messagesByConversation,
          [conversationId]: next,
        },
      };
    });
  },

  setStreaming: (v) => set({ isStreaming: v }),

  ensureLoaded: (conversationId, messages) => {
    set((s) => {
      if (s.messagesByConversation[conversationId]) return {};
      return {
        messagesByConversation: {
          ...s.messagesByConversation,
          [conversationId]: messages,
        },
      };
    });
  },
}));
