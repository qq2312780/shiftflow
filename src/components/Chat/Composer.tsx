import { useEffect, useRef, useState } from "react";
import { SendIcon, CornerDownLeftIcon } from "lucide-react";
import { useChatStore } from "../../store/chat";

const SUGGESTIONS = [
  { label: "介绍一下你自己", desc: "简介" },
  { label: "分析当前项目的代码结构", desc: "代码" },
  { label: "给我看看最近的内存记忆", desc: "记忆" },
  { label: "有哪些技能？挑三个解释一下", desc: "技能" },
];

const SLASH = [
  { label: "/skills", desc: "浏览已安装技能" },
  { label: "/memory", desc: "打开记忆时间线" },
  { label: "/live", desc: "打开实时事件流" },
  { label: "/new", desc: "新建一段对话" },
];

export function Composer({ conversationId }: { conversationId: string }) {
  const [value, setValue] = useState("");
  const [showPalette, setShowPalette] = useState(false);
  const textareaRef = useRef<HTMLTextAreaElement | null>(null);

  const isStreaming = useChatStore((s) => s.isStreaming);
  const newConversation = useChatStore((s) => s.newConversation);

  useEffect(() => {
    const ta = textareaRef.current;
    if (!ta) return;
    ta.style.height = "0px";
    ta.style.height = Math.min(ta.scrollHeight, 240) + "px";
  }, [value]);

  const send = () => {
    if (!value.trim() || isStreaming) return;
    const sendFn = (window as unknown as { __clawSend?: (t: string) => void }).__clawSend;
    if (sendFn) {
      sendFn(value);
      setValue("");
    }
  };

  const applySlash = (label: string) => {
    if (label === "/new") {
      newConversation();
      setValue("");
      return;
    }
    const promptMap: Record<string, string> = {
      "/skills": "把已安装的技能列表和每一项的一句话简介发给我。",
      "/memory": "总结一下我最近的记忆条目，按话题分组。",
      "/live": "实时事件流里有哪些最近的事件？简单列出。",
    };
    setValue(promptMap[label] ?? label.slice(1));
    setShowPalette(false);
    textareaRef.current?.focus();
  };

  const onKeyDown = (e: React.KeyboardEvent<HTMLTextAreaElement>) => {
    if (e.key === "Enter" && !e.shiftKey) {
      e.preventDefault();
      send();
      return;
    }
    if (e.key === "/" && value === "") {
      setShowPalette(true);
    }
    if (e.key === "Escape") setShowPalette(false);
  };

  return (
    <div className="border-t border-white/5 bg-ink-950/50 px-4 md:px-8 py-4">
      <div className="max-w-4xl mx-auto relative">
        {showPalette && (
          <div className="absolute bottom-full left-0 right-0 mb-3 pointer-events-none">
            <div className="panel pointer-events-auto p-2">
              <div className="text-[11px] uppercase tracking-widest text-bone-500/70 px-1 pb-1">
                快捷指令
              </div>
              <div className="flex flex-wrap gap-2">
                {SLASH.map((s) => (
                  <button
                    key={s.label}
                    onClick={() => applySlash(s.label)}
                    className="px-2.5 py-1 rounded-full text-xs bg-white/5 hover:bg-claw-500/15 text-bone-200 border border-white/10 hover:border-claw-500/30"
                  >
                    <span className="font-mono text-claw-300 mr-1.5">{s.label}</span>
                    <span className="text-bone-500/80">{s.desc}</span>
                  </button>
                ))}
              </div>
              <div className="text-[11px] uppercase tracking-widest text-bone-500/70 px-1 pt-3 pb-1">
                或尝试
              </div>
              <div className="flex flex-wrap gap-2">
                {SUGGESTIONS.map((s) => (
                  <button
                    key={s.label}
                    onClick={() => {
                      setValue(s.label);
                      setShowPalette(false);
                      textareaRef.current?.focus();
                    }}
                    className="px-2.5 py-1 rounded-full text-xs bg-white/5 hover:bg-teal/15 text-bone-200 border border-white/10 hover:border-teal/30"
                  >
                    {s.label}
                    <span className="text-bone-500/60 ml-1.5">· {s.desc}</span>
                  </button>
                ))}
              </div>
            </div>
          </div>
        )}

        <div
          className={`panel flex items-end gap-2 px-3 py-2.5 transition-colors ${
            isStreaming ? "border-claw-500/40" : ""
          }`}
        >
          <textarea
            ref={textareaRef}
            value={value}
            onChange={(e) => {
              setValue(e.target.value);
              setShowPalette(e.target.value === "");
            }}
            onKeyDown={onKeyDown}
            placeholder={`向 OpenClaw 提问${isStreaming ? "（思考中…）" : ""} — 输入 / 打开快捷指令`}
            className="flex-1 bg-transparent outline-none resize-none text-[14.5px] text-bone-100 placeholder:text-bone-500/60 py-1.5 px-1 leading-relaxed"
            rows={1}
            disabled={isStreaming}
          />

          <div className="flex items-center gap-1 shrink-0">
            <span className="hidden sm:flex items-center gap-1 text-[10.5px] text-bone-500/50 pr-2">
              <CornerDownLeftIcon size={12} />
              Enter 发送
              <span className="text-bone-500/40 mx-0.5">·</span>
              Shift+Enter 换行
            </span>

            <button
              onClick={send}
              disabled={!value.trim() || isStreaming}
              className={`flex items-center gap-1.5 px-3 py-1.5 rounded-full text-sm font-medium transition-all ${
                !value.trim() || isStreaming
                  ? "bg-white/5 text-bone-500/60 cursor-not-allowed border border-white/10"
                  : "bg-claw-500 text-ink-950 hover:bg-claw-400 shadow-glow"
              }`}
            >
              <SendIcon size={14} />
              {isStreaming ? "思考中" : "发送"}
            </button>
          </div>
        </div>
      </div>
      <span className="sr-only">对话 id: {conversationId}</span>
    </div>
  );
}
