# AI 群聊 (AI Group Chat)

> 一个 Flutter 移动端 App：在一个聊天室里和**多个 AI 角色**一起讨论。
> 支持自定义 AI 人设、切换本地 Mock / 真实大模型 API (OpenAI 兼容 / Ollama)，
> 全部数据本地存储,无后端依赖。

## 核心功能

- 🧑‍🤝‍🧑 **多角色混合群聊**：你发一句,所有"在线"的 AI 角色依次回复
- 🎭 **AI 角色管理**：内置 4 个角色 (小智/小媛/老哥/小白),可增删改、人设/语气/温度独立配置
- 🔌 **三种 LLM 模式**
  - **Mock**：纯本地模板化回复,无需联网,开箱即玩
  - **OpenAI 兼容**：填入 `api_base` + `api_key` + `model`,即可对接任何兼容服务
    (OpenAI、DeepSeek、Qwen、Moonshot、自建网关等)
  - **Ollama**：本地/局域网 Ollama 服务
- 💾 **本地持久化**：消息、角色、设置都存 `SharedPreferences`
- 🌓 **明暗主题**：跟随系统
- 🚫 **零后端**：单机 APK,可离线使用 (Mock 模式)

## 工程结构

```
ai_group_chat/
├── pubspec.yaml
├── analysis_options.yaml
└── lib/
    ├── main.dart                    # 入口
    ├── models/
    │   ├── message.dart             # 消息模型
    │   ├── ai_character.dart        # AI 角色模型
    │   └── app_settings.dart        # 设置模型
    ├── services/
    │   ├── storage_service.dart     # 本地持久化
    │   ├── ai_service.dart          # LLM 调用 (Mock/OpenAI/Ollama)
    │   └── chat_state.dart          # ChangeNotifier 状态
    ├── data/
    │   └── default_characters.dart  # 预置角色
    ├── widgets/
    │   ├── message_bubble.dart      # 消息气泡 + 思考动画
    │   └── ai_avatar.dart           # 头像
    └── screens/
        ├── chat_room_screen.dart    # 群聊主屏
        ├── ai_manage_screen.dart    # AI 角色管理 + 编辑
        └── settings_screen.dart      # LLM / API / 上下文配置
```

## 准备构建环境(本机一次性)

> ⚠️ 当前沙箱无 Android SDK / Flutter,需在**你自己电脑**上完成 APK 构建。

### 1. 安装 Flutter
参考官方文档:https://docs.flutter.dev/get-started/install

要求 Flutter 3.16+、Dart 3+。

验证:
```bash
flutter doctor
```

### 2. 安装 Android 工具链
- 安装 **Android Studio**(自带 Android SDK / Platform Tools / Emulator)
- 或仅安装 **Android command-line tools** + 配置 `ANDROID_HOME` 环境变量
- `flutter doctor` 全部打勾后即可。

### 3. 同意 Android License
```bash
flutter doctor --android-licenses
```

## 生成 Android 工程 + 构建 APK

进入工程目录:
```bash
cd ai_group_chat
```

### 一次性:补全 android/ 平台目录
`lib/` 代码已就绪,但 `android/` 等平台目录需让 Flutter 生成:
```bash
flutter create --org com.example --project-name ai_group_chat --platforms=android .
```

> 这条命令不会覆盖 `lib/` 和 `pubspec.yaml`,只会补全 `android/`、`ios/` 等。

### 安装依赖
```bash
flutter pub get
```

### 调试运行(连接手机或模拟器)
```bash
flutter run
```

### 构建 Release APK
```bash
flutter build apk --release
# 产物:build/app/outputs/flutter-apk/app-release.apk
```

### 构建分架构 APK(体积更小)
```bash
flutter build apk --split-per-abi
# 产物:build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
#      build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk
#      build/app/outputs/flutter-apk/app-x86_64-release.apk
```

### 构建 App Bundle(上架 Google Play)
```bash
flutter build appbundle --release
# 产物:build/app/outputs/bundle/release/app-release.aab
```

### 给 APK 签名(可选)
默认 debug 签名已能直接安装到手机做内测。
要打正式 release 签名,见 Flutter 官方文档:
[Android 部署 - 应用签名](https://docs.flutter.dev/deployment/android#signing-the-app)

## 使用指南

1. 启动后默认进入 **Mock 模式**,直接发消息即可看到 4 个 AI 角色轮流回复。
2. 右上角 ⚙️ **设置** → 选择 "OpenAI 兼容" 或 "Ollama",填入对应信息,点保存。
3. 右上角 👥 **管理 AI** → 编辑人设、启用/停用、增删角色。
4. 每条用户消息会触发**所有已启用**的 AI 依次回答,模拟群聊节奏。

## 切换到真实大模型示例

### OpenAI
```
Provider: OpenAI 兼容
API Base: https://api.openai.com/v1
API Key : sk-...
Model   : gpt-4o-mini
```

### 任意 OpenAI 兼容网关
例如青云 API、One API、自建网关:
```
API Base: https://your-gateway.example.com/v1
API Key : your-key
Model   : qwen-turbo   # 或服务商支持的模型
```

### Ollama (本地)
```
Provider: Ollama
Ollama 地址: http://10.0.2.2:11434   # 模拟器;真机用电脑局域网 IP
Model      : llama3
```
先在本机跑 `ollama pull llama3 && ollama serve`。

## 路线图(可在此基础上扩展)

- [ ] 多人群组(每个群独立 AI 阵容)
- [ ] 流式回复(打字机效果)
- [ ] 消息撤回 / @某位 AI
- [ ] 图片消息(多模态)
- [ ] 历史消息搜索
- [ ] 导出聊天记录
- [ ] 主题自定义 / 自定义头像图片

## 许可
MIT
