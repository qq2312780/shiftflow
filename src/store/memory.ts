import { create } from "zustand";
import type { MemoryEntry } from "../gateway/types";
import { seedMemory } from "../gateway/fixtures";

type MemoryState = {
  entries: MemoryEntry[];
  query: string;
  topicFilter: string | null;
  setEntries: (entries: MemoryEntry[]) => void;
  setQuery: (q: string) => void;
  setTopic: (t: string | null) => void;
};

export const useMemoryStore = create<MemoryState>((set) => ({
  entries: [...seedMemory].sort((a, b) => b.createdAt - a.createdAt),
  query: "",
  topicFilter: null,
  setEntries: (entries) => set({ entries }),
  setQuery: (q) => set({ query: q }),
  setTopic: (t) => set({ topicFilter: t }),
}));
