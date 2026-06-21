import { Navigate, useParams } from "react-router-dom";
import { SidebarHistory } from "../components/Chat/SidebarHistory";
import { ConversationPane } from "../components/Chat/ConversationPane";
import { Composer } from "../components/Chat/Composer";
import { LiveStream } from "../components/Live/LiveStream";
import { useChatStore } from "../store/chat";

export function ChatPage() {
  const { id } = useParams<{ id?: string }>();
  const conversations = useChatStore((s) => s.conversations);
  const activeId = useChatStore((s) => s.activeId);
  const setActive = useChatStore((s) => s.setActive);

  const resolvedId = id ?? activeId;

  // If id is provided but doesn't match any conversation, create it.
  if (id && !conversations.find((c) => c.id === id)) {
    useChatStore.setState({
      activeId: id,
      conversations: [
        { id, title: "New conversation", updatedAt: Date.now() },
        ...conversations,
      ],
    });
  }

  if (resolvedId !== activeId) {
    setActive(resolvedId);
  }

  if (!id && conversations.length > 0) {
    return <Navigate to={`/chat/${conversations[0].id}`} replace />;
  }

  const finalId = id ?? conversations[0]?.id ?? "welcome";

  return (
    <div className="flex min-h-[calc(100vh-57px)]">
      <SidebarHistory />

      <main className="flex-1 flex flex-col min-w-0">
        <ConversationPane conversationId={finalId} />
        <Composer conversationId={finalId} />
      </main>

      <aside className="hidden xl:block w-[380px] shrink-0 border-l border-white/5 p-4">
        <LiveStream />
      </aside>
    </div>
  );
}
