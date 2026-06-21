import { BrowserRouter, Route, Routes } from "react-router-dom";
import { Header } from "./components/Shell/Header";
import { ChatPage } from "./pages/ChatPage";
import { SkillsPage } from "./pages/SkillsPage";
import { MemoryPage } from "./pages/MemoryPage";
import { LivePage } from "./pages/LivePage";

export function App() {
  return (
    <BrowserRouter>
      <div className="min-h-screen flex flex-col bg-ink-950 text-bone-200">
        <Header />
        <Routes>
          <Route path="/" element={<ChatPage />} />
          <Route path="/chat/:id" element={<ChatPage />} />
          <Route path="/skills" element={<SkillsPage />} />
          <Route path="/memory" element={<MemoryPage />} />
          <Route path="/live" element={<LivePage />} />
        </Routes>
      </div>
    </BrowserRouter>
  );
}
