import { create } from "zustand";
import type { SkillCard } from "../gateway/types";
import { seedSkills } from "../gateway/fixtures";

type SkillsState = {
  skills: SkillCard[];
  openSkillId: string | null;
  query: string;
  setSkills: (skills: SkillCard[]) => void;
  setQuery: (q: string) => void;
  open: (id: string) => void;
  close: () => void;
};

export const useSkillsStore = create<SkillsState>((set) => ({
  skills: seedSkills.slice(),
  openSkillId: null,
  query: "",
  setSkills: (skills) => set({ skills }),
  setQuery: (q) => set({ query: q }),
  open: (id) => set({ openSkillId: id }),
  close: () => set({ openSkillId: null }),
}));
