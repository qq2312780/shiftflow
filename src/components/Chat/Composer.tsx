import { useEffect, useRef, useState } from "react";
import { SendIcon, CornerDownLeftIcon } from "lucide-react";
import { useChatStore } from "../../store/chat";

const SUGGESTIONS = [
  { label: "/skills", desc: "browse installed skills" },
  { label: "/memory", desc: "open the memory timeline" },
  { label: "/live", desc: "show the live event stream" },
  { label: "/new", desc: "start a new conversation" },
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
    // The /skills /memory /live labels are just friendly prompts.
    const promptMap: Record<string, string> = {
      "/skills": "Recommend a few skills from the ones currently installed.",
      "/memory": "Show me a short summary of what's in my memory timeline.",
      "/live": "Summarize the live event stream and explain what it's showing.",
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
            <div className="panel pointer-events-auto p-2 flex flex-wrap gap-2">
              <span className="text-[11px] uppercase tracking-widest text-bone-500/70 px-1 py-1">
                quick prompts
              </span>
              {SUGGESTIONS.map((s) => (
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
            placeholder={`Message OpenClaw${isStreaming ? " (thinking…)" : ""}  —  type / for quick prompts`}
            className="flex-1 bg-transparent outline-none resize-none text-[14.5px] text-bone-100 placeholder:text-bone-500/60 py-1.5 px-1 leading-relaxed"
            rows={1}
            disabled={isStreaming}
          />

          <div className="flex items-center gap-1 shrink-0">
            <span className="hidden sm:flex items-center gap-1 text-[10.5px] text-bone-500/50 pr-2">
              <CornerDownLeftIcon size={12} />
              Enter
              <span className="text-bone-500/40 mx-0.5">·</span>
              Shift+Enter for newline
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
              {isStreaming ? "…" : "Send"}
            </button>
          </div>
        </div>
      </div>
      <span className="sr-only">conversation id: {conversationId}</span>
    </div>
  );
}
