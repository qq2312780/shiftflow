/// LLM 提供方
enum LLMProvider { mock, openaiCompatible, ollama }

/// 应用设置
class AppSettings {
  LLMProvider provider;
  String apiBase; // 例如 https://api.openai.com/v1
  String apiKey;
  String model; // 例如 gpt-4o-mini, qwen-turbo, llama3
  int maxContextMessages; // 注入给 LLM 的最近消息条数
  Duration aiReplyDelay; // 模拟思考延迟

  AppSettings({
    this.provider = LLMProvider.mock,
    this.apiBase = 'https://api.openai.com/v1',
    this.apiKey = '',
    this.model = 'gpt-4o-mini',
    this.maxContextMessages = 20,
    this.aiReplyDelay = const Duration(milliseconds: 800),
  });

  Map<String, dynamic> toJson() => {
        'provider': provider.name,
        'apiBase': apiBase,
        'apiKey': apiKey,
        'model': model,
        'maxContextMessages': maxContextMessages,
        'aiReplyDelayMs': aiReplyDelay.inMilliseconds,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      provider: LLMProvider.values.firstWhere(
        (e) => e.name == json['provider'],
        orElse: () => LLMProvider.mock,
      ),
      apiBase: json['apiBase'] as String? ?? 'https://api.openai.com/v1',
      apiKey: json['apiKey'] as String? ?? '',
      model: json['model'] as String? ?? 'gpt-4o-mini',
      maxContextMessages: json['maxContextMessages'] as int? ?? 20,
      aiReplyDelay: Duration(
        milliseconds: json['aiReplyDelayMs'] as int? ?? 800,
      ),
    );
  }
}
