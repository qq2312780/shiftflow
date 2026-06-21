import { useEffect } from "react";
import ReactMarkdown from "react-markdown";
import remarkGfm from "remark-gfm";
import { XIcon } from "lucide-react";
import { useSkillsStore } from "../../store/skills";

export function SkillDrawer() {
  const openSkillId = useSkillsStore((s) => s.openSkillId);
  const skills = useSkillsStore((s) => s.skills);
  const close = useSkillsStore((s) => s.close);

  const skill = skills.find((s) => s.id === openSkillId) ?? null;

  useEffect(() => {
    if (!skill) return;
    const onKey = (e: KeyboardEvent) => {
      if (e.key === "Escape") close();
    };
    window.addEventListener("keydown", onKey);
    return () => window.removeEventListener("keydown", onKey);
  }, [skill, close]);

  return (
    <div
      className={`fixed inset-0 z-40 transition-all ${
        skill ? "pointer-events-auto" : "pointer-events-none"
      }`}
      aria-hidden={!skill}
    >
      <div
        className={`absolute inset-0 drawer-backdrop transition-opacity ${
          skill ? "opacity-100" : "opacity-0"
        }`}
        onClick={() => close()}
      />

      <aside
        className={`absolute right-0 top-0 h-full w-full sm:w-[520px] bg-ink-900 border-l border-white/5 shadow-2xl transition-transform ${
          skill ? "translate-x-0" : "translate-x-full"
        } animate-slide-in-right`}
      >
        {skill ? (
          <div className="flex flex-col h-full">
            <div className="flex items-start justify-between p-5 border-b border-white/5">
              <div className="flex items-start gap-3">
                <span className="text-3xl" aria-hidden>{skill.emoji}</span>
                <div>
                  <h3 className="font-display text-2xl text-bone-100">
                    {skill.name}
                  </h3>
                  <p className="text-[11px] text-bone-500/60 mt-1 uppercase tracking-widest">
                    安装于 {new Date(skill.installedAt).toLocaleDateString("zh-CN")}
                  </p>
                </div>
              </div>
              <button
                onClick={() => close()}
                className="p-1.5 rounded-full text-bone-500/70 hover:text-bone-100 hover:bg-white/5 border border-white/10"
                aria-label="关闭"
              >
                <XIcon size={16} />
              </button>
            </div>

            <div className="px-5 pt-3 pb-2 flex flex-wrap gap-1.5">
              {skill.tags.map((t) => (
                <span
                  key={t}
                  className="px-2.5 py-1 text-[11px] rounded-full bg-claw-500/10 border border-claw-500/25 text-claw-200"
                >
                  {t}
                </span>
              ))}
            </div>

            <div className="flex-1 overflow-y-auto px-6 py-4">
              <div className="markdown">
                <ReactMarkdown remarkPlugins={[remarkGfm]}>
                  {skill.body}
                </ReactMarkdown>
              </div>
            </div>

            <div className="p-4 border-t border-white/5 text-[11px] text-bone-500/70 flex justify-between">
              <span>本地安装 · 只读</span>
              <button
                onClick={() => close()}
                className="text-bone-400 hover:text-bone-200 underline underline-offset-4"
              >
                关闭
              </button>
            </div>
          </div>
        ) : null}
      </aside>
    </div>
  );
}
