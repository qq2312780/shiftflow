import { LiveStream } from "../components/Live/LiveStream";

export function LivePage() {
  return (
    <div className="py-8 px-6 md:px-10 max-w-6xl mx-auto w-full">
      <div className="flex items-end justify-between mb-4">
        <div>
          <h2 className="font-display text-3xl text-bone-100">实时事件流</h2>
          <p className="text-bone-500/70 text-sm mt-1">
            实时查看 OpenClaw 正在做什么，包括思考过程与工具调用。
          </p>
        </div>
      </div>
      <div className="h-[65vh]">
        <LiveStream />
      </div>
    </div>
  );
}
