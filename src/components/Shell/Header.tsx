import { useEffect, useState } from "react";
import { NavLink } from "react-router-dom";
import {
  MessagesSquareIcon,
  WrenchIcon,
  MemoryStickIcon,
  ZapIcon,
} from "lucide-react";
import { gateway } from "../../gateway/client";

function StatusDot({ status }: { status: "connected" | "thinking" | "idle" }) {
  const color =
    status === "connected"
      ? "bg-claw-500 animate-pulse-dot"
      : status === "thinking"
        ? "bg-teal animate-pulse-dot"
        : "bg-bone-500";
  return <span className={`inline-block w-2 h-2 rounded-full ${color}`} />;
}

type NavItem = {
  label: string;
  to: string;
  Icon: typeof MessagesSquareIcon;
};

const NAV: NavItem[] = [
  { label: "对话", to: "/", Icon: MessagesSquareIcon },
  { label: "技能", to: "/skills", Icon: WrenchIcon },
  { label: "记忆", to: "/memory", Icon: MemoryStickIcon },
  { label: "实时", to: "/live", Icon: ZapIcon },
];

export function Header() {
  const [version, setVersion] = useState<string>("—");

  useEffect(() => {
    setVersion(gateway.version());
  }, []);

  return (
    <header className="sticky top-0 z-30 border-b border-white/5 bg-ink-900/70 backdrop-blur-md">
      <div className="flex items-center justify-between px-6 py-3">
        <div className="flex items-center gap-3">
          <span className="inline-block w-6 h-6 rounded-full bg-gradient-to-br from-claw-300 to-claw-500 shadow-glow" />
          <span className="font-display text-2xl tracking-tight wordmark">
            OpenClaw
          </span>
          <span className="ml-2 text-xs text-bone-500/70">
            本地网关 · v{version}
          </span>
        </div>

        <nav className="hidden md:flex items-center gap-1">
          {NAV.map(({ to, label, Icon }) => (
            <NavLink
              key={to}
              to={to}
              end={to === "/"}
              className={({ isActive }) =>
                `group flex items-center gap-1.5 px-3 py-1.5 rounded-full text-sm transition-all ${
                  isActive
                    ? "bg-claw-500/15 text-claw-200 border border-claw-500/30"
                    : "text-bone-500/80 hover:text-bone-300 hover:bg-white/5 border border-transparent"
                }`
              }
            >
              <Icon size={15} />
              <span>{label}</span>
            </NavLink>
          ))}
        </nav>

        <div className="flex items-center gap-2 text-xs text-bone-500/70">
          <StatusDot status="connected" />
          <span className="hidden sm:inline">已连接</span>
        </div>
      </div>
    </header>
  );
}
