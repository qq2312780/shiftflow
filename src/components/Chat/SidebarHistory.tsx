import { useEffect } from "react";
import { NavLink } from "react-router-dom";
import { PlusIcon, SearchIcon } from "lucide-react";
import { useChatStore } from "../../store/chat";
import { gateway } from "../../gateway/client";
import { formatRelative } from "../../utils/format";

export function SidebarHistory() {
  const conversations = useChatStore((s) => s.conversations);
  const activeId = useChatStore((s) => s.activeId);
  const newConversation = useChatStore((s) => s.newConversation);
  const setActive = useChatStore((s) => s.setActive);
  const setConversations = useChatStore((s) => s.conversations);

  // Keep lint happy by reading setConversations if it were ever used.
  void setConversations;

  useEffect(() => {
    if (useChatStore.getState().conversations.length === 0) {
      gateway.listConversations().then((list) => {
        useChatStore.setState({
          conversations: list.sort((a, b) => b.updatedAt - a.updatedAt),
        });
      });
    }
  }, []);

  return (
    <aside className="w-64 shrink-0 border-r border-white/5 bg-ink-950/40">
      <div className="p-3">
        <div className="flex items-center justify-between mb-3">
          <span className="text-xs uppercase tracking-widest text-bone-500/70">
            conversations
          </span>
          <button
            onClick={() => newConversation()}
            className="flex items-center gap-1 px-2 py-1 rounded-full text-xs bg-white/5 hover:bg-claw-500/20 transition-colors border border-white/10 text-bone-300 focus-ring"
            title="New conversation"
          >
            <PlusIcon size={14} /> new
          </button>
        </div>
      </div>

      <div className="px-3 mb-2">
        <div className="relative">
          <SearchIcon
            size={14}
            className="absolute left-2.5 top-1/2 -translate-y-1/2 text-bone-500/60"
          />
          <input
            type="text"
            placeholder="search…"
            className="w-full bg-ink-800 border border-white/5 rounded-full pl-8 pr-3 py-1.5 text-sm focus-ring"
          />
        </div>
      </div>

      <div className="px-2 pb-4 space-y-1 overflow-y-auto max-h-[calc(100vh-220px)]">
        {conversations.map((c) => (
          <NavLink
            key={c.id}
            to={`/chat/${c.id}`}
            onClick={() => setActive(c.id)}
            className={({ isActive }) =>
              `flex flex-col px-3 py-2.5 rounded-lg text-sm transition-all border ${
                isActive || c.id === activeId
                  ? "bg-claw-500/10 border-claw-500/20 text-claw-100"
                  : "border-transparent text-bone-500/80 hover:text-bone-300 hover:bg-white/5"
              }`
            }
          >
            <span className="line-clamp-1 font-medium">
              {c.title || "Untitled"}
            </span>
            <span className="text-[11px] text-bone-500/50 mt-0.5">
              {formatRelative(c.updatedAt)}
            </span>
          </NavLink>
        ))}
      </div>
    </aside>
  );
}
