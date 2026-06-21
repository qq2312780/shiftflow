import { useEffect, useMemo, useRef, useState } from "react";
import ReactMarkdown from "react-markdown";
import remarkGfm from "remark-gfm";
import { CopyIcon, CheckIcon } from "lucide-react";
import { useChatStore } from "../../store/chat";
import { useLiveStore } from "../../store/live";
import { gateway } from "../../gateway/client";
import type { ChatMessage, GatewayEvent } from "../../gateway/types";
import { formatTime } from "../../utils/format";
import { roleAccent, roleIcon, roleLabel } from "../../utils/roles";

function roleLabelZh(role: string): string {
  switch (role) {
    case "agent": return "助手";
    case "tool": return "工具";
    case "system": return "系统";
    case "user": return "你";
    default: return role;
  }
}

function MessageBubble({ message }: { message: ChatMessage }) {
  const [copied, setCopied] = useState(false);
  const Icon = roleIcon(message.role);
  const isUser = message.role === "user";

  const copy = async () => {
    try {
      await navigator.clipboard.writeText(message.content);
      setCopied(true);
      setTimeout(() => setCopied(false), 1500);
    } catch {
      /* ignore */
    }
  };

  return (
    <div className={`flex ${isUser ? "justify-end" : "justify-start"}`}>
      <div
        className={`group relative max-w-[85%] md:max-w-[78%]`}
      >
        <div
          className={`flex items-center gap-2 text-[11px] mb-1 ${
            isUser ? "justify-end" : "justify-start"
          }`}
        >
          <span
            className={`inline-flex items-center gap-1.5 px-2 py-0.5 rounded-full border ${roleAccent(
              message.role
            )}`}
          >
            <Icon size={11} />
            {roleLabelZh(message.role)}
          </span>
          <span className="text-bone-500/60">{formatTime(message.createdAt)}</span>
        </div>

        <div
          className={`panel px-4 py-3 rounded-2xl text-[14.5px] leading-relaxed ${
            isUser
              ? "bg-claw-500/10 border-claw-500/25 rounded-tr-sm"
              : message.role === "tool"
                ? "bg-teal/10 border-teal/30 rounded-tl-sm"
                : message.role === "system"
                  ? "bg-white/[0.03] border-white/10 rounded-tl-sm italic text-bone-400/90"
                  : "bg-white/[0.02] border-white/10 rounded-tl-sm"
          }`}
        >
          <div className="markdown">
            <ReactMarkdown remarkPlugins={[remarkGfm]}>
              {message.content || (message.streaming ? "…" : "")}
            </ReactMarkdown>
          </div>

          {message.streaming && (
            <span className="inline-block w-1.5 h-4 translate-y-[2px] bg-claw-400/80 animate-pulse ml-1 align-middle rounded-sm" />
          )}

          <button
            onClick={copy}
            className="absolute top-2 right-2 opacity-0 group-hover:opacity-100 transition-opacity text-bone-500/70 hover:text-bone-200 text-xs flex items-center gap-1"
            title="复制"
          >
            {copied ? <CheckIcon size={12} /> : <CopyIcon size={12} />}
          </button>
        </div>
      </div>
    </div>
  );
}

export function ConversationPane({
  conversationId,
}: {
  conversationId: string;
}) {
  const messagesByConversation = useChatStore((s) => s.messagesByConversation);
  const appendMessage = useChatStore((s) => s.appendMessage);
  const updateLast = useChatStore((s) => s.updateLast);
  const ensureLoaded = useChatStore((s) => s.ensureLoaded);
  const setStreaming = useChatStore((s) => s.setStreaming);
  const isStreaming = useChatStore((s) => s.isStreaming);
  const pushLive = useLiveStore((s) => s.push);

  const scrollRef = useRef<HTMLDivElement | null>(null);
  const messages = messagesByConversation[conversationId] ?? [];

  useEffect(() => {
    if (!messagesByConversation[conversationId]) {
      gateway.getInitialMessages(conversationId).then((list) => {
        ensureLoaded(conversationId, list);
      });
    }
  }, [conversationId, ensureLoaded, messagesByConversation]);

  useEffect(() => {
    const el = scrollRef.current;
    if (el) el.scrollTop = el.scrollHeight;
  }, [messages.length, isStreaming, messages.map((m) => m.content.length).join(",")]);

  const send = useMemo(
    () => async (text: string) => {
      if (!text.trim() || isStreaming) return;
      const userMsg: ChatMessage = {
        id: "u_" + Math.random().toString(36).slice(2, 9),
        role: "user",
        content: text.trim(),
        createdAt: Date.now(),
      };
      appendMessage(conversationId, userMsg);

      const agentId = "a_" + Math.random().toString(36).slice(2, 9);
      const seed: ChatMessage = {
        id: agentId,
        role: "agent",
        content: "",
        createdAt: Date.now(),
        streaming: true,
      };
      appendMessage(conversationId, seed);
      setStreaming(true);

      try {
        for await (const ev of gateway.sendMessage(conversationId, text)) {
          pushLive(ev);
          if (ev.type === "text") {
            updateLast(conversationId, (m) => ({
              ...m,
              content: (m.content ?? "") + ev.delta,
            }));
          }
        }
      } catch (err) {
        const e: GatewayEvent = {
          type: "error",
          at: Date.now(),
          message:
            err instanceof Error ? err.message : "未知错误",
        };
        pushLive(e);
      } finally {
        updateLast(conversationId, (m) => ({
          ...m,
          streaming: false,
          tokens: (m.content ?? "").split(/\s+/).filter(Boolean).length,
        }));
        setStreaming(false);
      }
    },
    [appendMessage, conversationId, isStreaming, pushLive, setStreaming, updateLast]
  );

  useEffect(() => {
    (window as unknown as { __clawSend?: (t: string) => void }).__clawSend = send;
    return () => {
      const w = window as unknown as { __clawSend?: (t: string) => void };
      if (w.__clawSend === send) delete w.__clawSend;
    };
  }, [send]);

  return (
    <div
      ref={scrollRef}
      className="flex-1 overflow-y-auto px-6 md:px-10 py-6 space-y-5 scroll-smooth"
    >
      {messages.length === 0 && (
        <div className="text-center text-bone-500/60 text-sm pt-16">
          <p className="font-display text-3xl text-bone-200 mb-2">
            欢迎使用 OpenClaw
          </p>
          <p>在下方输入你的问题，或试试输入 <code>/</code> 打开快捷指令</p>
        </div>
      )}

      {messages.map((m) => (
        <MessageBubble key={m.id} message={m} />
      ))}
    </div>
  );
}
