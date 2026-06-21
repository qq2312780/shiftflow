import { create } from "zustand";
import type { GatewayEvent } from "../gateway/types";

type LiveState = {
  events: GatewayEvent[];
  push: (e: GatewayEvent) => void;
  clear: () => void;
};

export const useLiveStore = create<LiveState>((set) => ({
  events: [],
  push: (e) =>
    set((s) => ({ events: [...s.events.slice(-120), e] })),
  clear: () => set({ events: [] }),
}));
