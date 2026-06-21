import { useMemo, useState } from "react";
import { SearchIcon, TagIcon, ChevronDownIcon, ChevronRightIcon } from "lucide-react";
import { useMemoryStore } from "../../store/memory";
import { formatDateTime } from "../../utils/format";

function zhRelative(ts: number): string {
  const diff = Date.now() - ts;
  const min = Math.floor(diff / 60000);
  if (min < 1) return "刚刚";
  if (min < 60) return `${min} 分钟前`;
  const hours = Math.floor(min / 60);
  if (hours < 24) return `${hours} 小时前`;
  const days = Math.floor(hours / 24);
  if (days < 30) return `${days} 天前`;
  return new Date(ts).toLocaleDateString("zh-CN");
}

type MemoryEntry = ReturnType<typeof useMemoryStore.getState>["entries"][number];

function groupByDate(entries: MemoryEntry[]) {
  const groups: { title: string; entries: MemoryEntry[] }[] = [
    { title: "今天", entries: [] },
    { title: "昨天", entries: [] },
    { title: "最近一周", entries: [] },
    { title: "最近一月", entries: [] },
    { title: "更早", entries: [] },
  ];

  const now = new Date();
  const today = new Date(now.toDateString()).getTime();
  const yesterday = today - 86400000;
  const week = today - 7 * 86400000;
  const month = today - 30 * 86400000;

  for (const e of entries) {
    if (e.createdAt >= today) groups[0].entries.push(e);
    else if (e.createdAt >= yesterday) groups[1].entries.push(e);
    else if (e.createdAt >= week) groups[2].entries.push(e);
    else if (e.createdAt >= month) groups[3].entries.push(e);
    else groups[4].entries.push(e);
  }

  return groups.filter((g) => g.entries.length > 0);
}

export function MemoryTimeline() {
  const entries = useMemoryStore((s) => s.entries);
  const query = useMemoryStore((s) => s.query);
  const setQuery = useMemoryStore((s) => s.setQuery);
  const topicFilter = useMemoryStore((s) => s.topicFilter);
  const setTopic = useMemoryStore((s) => s.setTopic);
  const [openId, setOpenId] = useState<string | null>(null);

  const filtered = useMemo(() => {
    return entries
      .filter((e) => (topicFilter ? e.topic === topicFilter : true))
      .filter((e) => {
        if (!query.trim()) return true;
        const q = query.toLowerCase();
        return (
          e.title.toLowerCase().includes(q) ||
          e.body.toLowerCase().includes(q) ||
          e.preview.toLowerCase().includes(q) ||
          e.tags.some((t) => t.toLowerCase().includes(q))
        );
      })
      .sort((a, b) => b.createdAt - a.createdAt);
  }, [entries, query, topicFilter]);

  const topics = useMemo(() => {
    const map = new Map<string, number>();
    for (const e of entries) {
      map.set(e.topic, (map.get(e.topic) ?? 0) + 1);
    }
    return Array.from(map.entries())
      .map(([name, count]) => ({ name, count }))
      .sort((a, b) => b.count - a.count);
  }, [entries]);

  const groups = groupByDate(filtered);

  return (
    <div className="max-w-4xl mx-auto">
      <div className="flex items-end justify-between mb-4">
        <div>
          <h2 className="font-display text-3xl text-bone-100">记忆</h2>
          <p className="text-bone-500/70 text-sm mt-1">
            {entries.length} 条条目 · {topics.length} 个话题
          </p>
        </div>
        <div className="relative">
          <SearchIcon
            size={14}
            className="absolute left-3 top-1/2 -translate-y-1/2 text-bone-500/60"
          />
          <input
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            placeholder="搜索记忆…"
            className="bg-ink-800 border border-white/5 rounded-full pl-9 pr-4 py-2 text-sm focus-ring w-64"
          />
        </div>
      </div>

      <div className="panel p-4 mb-6">
        <div className="flex items-center gap-2 text-[11px] uppercase tracking-widest text-bone-500/70 mb-3">
          <TagIcon size={12} />
          <span>话题</span>
        </div>
        <div className="flex flex-wrap gap-2">
          <button
            onClick={() => setTopic(null)}
            className={`px-2.5 py-1 rounded-full text-xs border transition-all ${
              topicFilter === null
                ? "bg-claw-500/15 border-claw-500/30 text-claw-200"
                : "bg-white/5 border-white/10 text-bone-400 hover:bg-white/10"
            }`}
          >
            全部
          </button>
          {topics.map((t) => (
            <button
              key={t.name}
              onClick={() => setTopic(t.name === topicFilter ? null : t.name)}
              className={`px-3 py-1 rounded-full border text-xs transition-all ${
                topicFilter === t.name
                  ? "bg-teal/15 border-teal/40 text-teal"
                  : "bg-white/5 border-white/10 text-bone-400 hover:bg-white/10"
              }`}
            >
              {t.name}
              <span className="ml-1.5 text-bone-500/60 text-[10px] align-top">
                {t.count}
              </span>
            </button>
          ))}
        </div>
      </div>

      <div className="space-y-8">
        {groups.map((g) => (
          <section key={g.title}>
            <div className="flex items-center gap-3 mb-3">
              <h3 className="text-[11px] uppercase tracking-widest text-bone-500/70">
                {g.title}
              </h3>
              <span className="text-[11px] text-bone-500/60">· {g.entries.length}</span>
              <div className="h-px flex-1 bg-gradient-to-r from-white/10 to-transparent" />
            </div>

            <div className="relative pl-8">
              <div className="absolute left-[14px] top-2 bottom-2 w-px bg-gradient-to-b from-white/10 via-white/5 to-transparent" />

              <div className="space-y-3">
                {g.entries.map((e) => {
                  const isOpen = openId === e.id;
                  return (
                    <div key={e.id} className="relative">
                      <span className="absolute -left-[6px] top-3 w-2.5 h-2.5 rounded-full bg-claw-500/80 border border-claw-300/40" />
                      <div className="panel">
                        <button
                          onClick={() => setOpenId(isOpen ? null : e.id)}
                          className="w-full text-left p-4 flex items-start gap-3"
                        >
                          <span className="text-teal mt-1">
                            {isOpen ? (
                              <ChevronDownIcon size={14} />
                            ) : (
                              <ChevronRightIcon size={14} />
                            )}
                          </span>
                          <div className="flex-1">
                            <div className="flex items-start justify-between gap-4">
                              <h4 className="font-display text-lg text-bone-100 leading-tight">
                                {e.title}
                              </h4>
                              <span className="text-[11px] text-bone-500/60 whitespace-nowrap">
                                {zhRelative(e.createdAt)}
                              </span>
                            </div>
                            <p className="text-[13px] text-bone-400/90 leading-relaxed mt-1 line-clamp-3">
                              {e.preview}
                            </p>
                            <div className="flex flex-wrap gap-1.5 mt-2.5">
                              <span className="px-2 py-0.5 text-[10.5px] rounded-full bg-teal/10 border border-teal/30 text-teal">
                                {e.topic}
                              </span>
                              {e.tags.map((t) => (
                                <span
                                  key={t}
                                  className="px-2 py-0.5 text-[10.5px] rounded-full bg-white/5 border border-white/10 text-bone-400/80"
                                >
                                  {t}
                                </span>
                              ))}
                            </div>
                          </div>
                        </button>

                        {isOpen && (
                          <div className="border-t border-white/5 p-4 text-[13.5px] text-bone-300/90 leading-relaxed">
                            <div className="text-[10.5px] uppercase tracking-widest text-bone-500/60 mb-1.5">
                              完整内容 · {formatDateTime(e.createdAt)}
                            </div>
                            {e.body}
                          </div>
                        )}
                      </div>
                    </div>
                  );
                })}
              </div>
            </div>
          </section>
        ))}

        {filtered.length === 0 && (
          <div className="text-center text-bone-500/70 py-16">
            <p className="font-display text-xl text-bone-200">
              没有匹配的记忆条目
            </p>
            <p className="text-sm mt-1">换个关键词或切换话题再试试。</p>
          </div>
        )}
      </div>
    </div>
  );
}
