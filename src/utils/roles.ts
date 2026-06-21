import {
  MessageCircleIcon,
  BrainCircuitIcon,
  WrenchIcon,
  BotIcon,
} from "lucide-react";
import type { Role } from "../gateway/types";

export function roleIcon(role: Role) {
  switch (role) {
    case "agent":
      return BotIcon;
    case "tool":
      return WrenchIcon;
    case "system":
      return BrainCircuitIcon;
    case "user":
    default:
      return MessageCircleIcon;
  }
}

export function roleLabel(role: Role): string {
  switch (role) {
    case "agent":
      return "claw";
    case "tool":
      return "tool";
    case "system":
      return "system";
    case "user":
    default:
      return "you";
  }
}

export function roleAccent(role: Role): string {
  switch (role) {
    case "agent":
      return "text-claw-300 border-claw-500/30 bg-claw-500/10";
    case "tool":
      return "text-teal border-teal/30 bg-teal/10";
    case "system":
      return "text-bone-500 border-white/10 bg-white/5";
    case "user":
    default:
      return "text-bone-300 border-white/10 bg-white/5";
  }
}
