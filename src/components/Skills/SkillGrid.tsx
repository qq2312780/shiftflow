import { useEffect } from "react";
import { SearchIcon, ExternalLinkIcon } from "lucide-react";
import { useSkillsStore } from "../../store/skills";
import { gateway } from "../../gateway/client";
import { SkillDrawer } from "./SkillDrawer";
import type { SkillCard as SkillCardType } from "../../gateway/types";

function SkillCard({ skill }: { skill: SkillCardType }) {
  const open = useSkillsStore((s) => s.open);

  return (
    <button
      onClick={() => open(skill.id)}
      className="panel panel-hover text-left flex flex-col h-full p-4 group"
    >
      <div className="flex items-start justify-between gap-2">
        <div className="flex items-center gap-3">
          <span className="text-2xl" aria-hidden>
            {skill.emoji}
          </span>
          <div>
            <h3 className="font-display text-lg text-bone-100 leading-tight">
              {skill.name}
            </h3>
            <p className="text-[11px] text-bone-500/70 mt-0.5">
              installed · {new Date(skill.installedAt).toLocaleDateString()}
            </p>
          </div>
        </div>
        <ExternalLinkIcon
          size={14}
          className="text-bone-500/50 group-hover:text-claw-300 transition-colors mt-1"
        />
      </div>

      <p className="mt-3 text-[13px] text-bone-300/90 leading-relaxed line-clamp-3">
        {skill.description}
      </p>

      <div className="mt-4 flex flex-wrap gap-1.5">
        {skill.tags.map((t) => (
          <span
            key={t}
            className="px-2 py-0.5 text-[10.5px] rounded-full bg-white/5 border border-white/10 text-bone-400"
          >
            {t}
          </span>
        ))}
      </div>
    </button>
  );
}

export function SkillsGrid() {
  const skills = useSkillsStore((s) => s.skills);
  const query = useSkillsStore((s) => s.query);
  const setQuery = useSkillsStore((s) => s.setQuery);
  const setSkills = useSkillsStore((s) => s.setSkills);

  useEffect(() => {
    gateway.listSkills().then((list) => setSkills(list));
  }, [setSkills]);

  const filtered = query.trim()
    ? skills.filter(
        (s) =>
          s.name.toLowerCase().includes(query.toLowerCase()) ||
          s.description.toLowerCase().includes(query.toLowerCase()) ||
          s.tags.some((t) => t.toLowerCase().includes(query.toLowerCase()))
      )
    : skills;

  return (
    <div className="max-w-6xl mx-auto">
      <div className="flex items-end justify-between mb-6">
        <div>
          <h2 className="font-display text-3xl text-bone-100">
            Skills
          </h2>
          <p className="text-bone-500/70 text-sm mt-1">
            procedural extensions that teach OpenClaw how to act. {skills.length} installed.
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
            placeholder="search skills, tags…"
            className="bg-ink-800 border border-white/5 rounded-full pl-9 pr-4 py-2 text-sm focus-ring w-56"
          />
        </div>
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
        {filtered.map((s) => (
          <SkillCard key={s.id} skill={s} />
        ))}
      </div>

      {filtered.length === 0 && (
        <div className="text-center text-bone-500/70 mt-16">
          <p className="font-display text-xl text-bone-200">
            No skills match "{query}".
          </p>
          <p className="text-sm mt-1">Try a different tag or name.</p>
        </div>
      )}

      <SkillDrawer />
    </div>
  );
}
