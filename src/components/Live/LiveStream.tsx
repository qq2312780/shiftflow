import { useState } from "react";
import {
  BrainCircuitIcon,
  WrenchIcon,
  AlertTriangleIcon,
  TypeIcon,
  ChevronDownIcon,
  ChevronRightIcon,
  TrashIcon,
} from "lucide-react";
import { useLiveStore } from "../../store/live";
import type { GatewayEvent } from "../../gateway/types";
import { formatMilliseconds } from "../../utils/format";

function eventMeta(e: GatewayEvent) {
  switch (e.type) {
    case "thinking":
      return {
        label: "思考中",
        Icon: BrainCircuitIcon,
        accent: "border-teal/30 bg-teal/10 text-teal",
        body: e.text,
      };
    case "text":
      return {
        label: "文本",
        Icon: TypeIcon,
        accent: "border-claw-500/30 bg-claw-500/10 text-claw-200",
        body: e.delta,
      };
    case "tool.call":
      return {
        label: "工具·调用",
        Icon: WrenchIcon,
        accent: "border-teal/30 bg-teal/5 text-teal",
        body: `${e.tool} — ${JSON.stringify(e.payload)}`,
      };
    case "tool.result":
      return {
        label: "工具·结果",
        Icon: WrenchIcon,
        accent: "border-teal/40 bg-teal/10 text-bone-200",
        body: `${e.tool} ${e.ok ? "成功" : "失败"} — ${JSON.stringify(e.payload)}`,
      };
    case "error":
      return {
        label: "错误",
        Icon: AlertTriangleIcon,
        accent: "border-red-500/30 bg-red-500/10 text-red-300",
        body: e.message,
      };
  }
}

function EventRow({ event, index }: { event: GatewayEvent; index: number }) {
  const [open, setOpen] = useState(false);
  const meta = eventMeta(event);
  const { Icon, label, accent, body } = meta;
  const isTool =
    event.type === "tool.call" || event.type === "tool.result" || event.type === "error";
  const payload = isTool
    ? "payload" in event
      ? event.payload
      : null
    : null;

  return (
    <div className="group flex gap-2 text-xs animate-fade-in-up" style={{ animationDelay: `${Math.min(index * 12, 180)}ms` }}>
      <span className="w-20 shrink-0 font-mono text-bone-500/60 text-[11px] pt-1 text-right select-none">
        {formatMilliseconds(event.at)}
      </span>

      <div className="flex-1 min-w-0">
        <button
          onClick={() => setOpen((v) => !v)}
          className="flex items-center gap-1.5 px-2 py-0.5 rounded-full border hover:brightness-125 transition-all"
        >
          {isTool ? (open ? <ChevronDownIcon size={11} /> : <ChevronRightIcon size={11} />) : null}
          <Icon size={11} />
          <span className={accent.split(" ").slice(-1)[0]}>{label}</span>
        </button>

        <div className="mt-1.5 pl-1.5 border-l border-white/5 text-bone-300/90 whitespace-pre-wrap break-words">
          {body}
        </div>

        {isTool && open && payload && (
          <pre className="mt-2 text-[11px] font-mono text-bone-500/80 bg-black/30 rounded-lg p-2 border border-white/5 overflow-x-auto">
{JSON.stringify(payload, null, 2)}
          </pre>
        )}
      </div>
    </div>
  );
}

export function LiveStream({ compact = false }: { compact?: boolean }) {
  const events = useLiveStore((s) => s.events);
  const clear = useLiveStore((s) => s.clear);

  return (
    <div className={`panel flex flex-col h-full ${compact ? "max-h-full" : ""}`}>
      <div className="flex items-center justify-between px-4 py-2 border-b border-white/5">
        <div className="flex items-center gap-2">
          <span className="inline-block w-1.5 h-1.5 rounded-full bg-teal animate-pulse-dot" />
          <span className="text-xs font-medium text-bone-200">实时事件</span>
          <span className="text-[11px] text-bone-500/60">
            缓冲区 {events.length} 条
          </span>
        </div>
        <button
          onClick={clear}
          className="text-[11px] text-bone-500/70 hover:text-bone-200 flex items-center gap-1 px-2 py-0.5 rounded-full border border-white/5 hover:border-claw-500/30"
          title="清空事件"
        >
          <TrashIcon size={11} />
          清空
        </button>
      </div>

      <div className="flex-1 overflow-y-auto p-3 space-y-2 min-h-[200px]">
        {events.length === 0 ? (
          <div className="text-center text-xs text-bone-500/60 py-8">
            <p className="font-display text-base text-bone-300/80 mb-1">
              暂无事件
            </p>
            <p>在对话中发送消息 — 每条回复的事件会在这里实时显示</p>
          </div>
        ) : (
          events.map((e, i) => <EventRow key={i} event={e} index={i} />)
        )}
      </div>
    </div>
  );
}
