import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

import '../models/ai_character.dart';
import '../models/app_settings.dart';
import '../models/message.dart';

/// AI 服务:根据当前 provider 分发到 Mock / OpenAI 兼容 / Ollama
class AIService {
  final AppSettings settings;
  final Random _random = Random();

  AIService(this.settings);

  /// 产生单个 AI 角色的回复
  Future<String> generateReply({
    required AICharacter character,
    required List<Message> recentMessages,
  }) async {
    // 模拟思考延迟
    await Future.delayed(settings.aiReplyDelay);

    switch (settings.provider) {
      case LLMProvider.mock:
        return _mockReply(character, recentMessages);
      case LLMProvider.openaiCompatible:
        return _openAiCompatibleReply(character, recentMessages);
      case LLMProvider.ollama:
        return _ollamaReply(character, recentMessages);
    }
  }

  // ---------- Mock ----------
  String _mockReply(AICharacter character, List<Message> recent) {
    final lastUser = recent.lastWhere(
      (m) => m.senderType == SenderType.user,
      orElse: () => Message(
        id: 'sys',
        senderType: SenderType.system,
        senderId: '',
        senderName: '',
        avatarEmoji: '',
        avatarColor: const Color(0),
        content: '',
        timestamp: DateTime.now(),
      ),
    );

    final lastContent = lastUser.content;

    // 根据人设 + 关键词做模板化回复
    final keywordsGreet = ['你好', 'hi', 'hello', '在吗', '嗨'];
    final keywordsQuestion = ['吗', '?', '？', 'why', '怎么', '如何'];
    final keywordsThanks = ['谢谢', 'thanks', 'thx'];

    final lowers = lastContent.toLowerCase();

    String pick(List<String> pool) => pool[_random.nextInt(pool.length)];

    if (keywordsGreet.any(lowers.contains)) {
      switch (character.id) {
        case 'char_xiaozhi':
          return pick(['你好!我是 ${character.name} 📊 有什么可以帮你分析的?',
              'hi~ 已上线,准备就绪。', '👋 你好,请问今天想聊什么?']);
        case 'char_xiaoyuan':
          return pick(['🌸 你好呀~ 见到你真开心!',
              'hi hi~ 今天心情怎么样呀?', '来啦来啦~ 🌸']);
        case 'char_laoge':
          return pick(['哟,来了 🤨 今天想搞点啥?',
              '在呢。说吧。', '👋 别寒暄,直接说正事。']);
        case 'char_xiaobai':
          return pick(['你好你好!✨', 'hi~ 我是小白!❓', '见到你啦!']);
      }
    }
    if (keywordsThanks.any(lowers.contains)) {
      return pick([
        '不客气~',
        '应该的!',
        '有需要再叫我。',
        '🌸 能帮到你就好~',
      ]);
    }
    if (keywordsQuestion.any(lowers.contains)) {
      return pick([
        '关于"${lastContent.length > 12 ? lastContent.substring(0, 12) + '…' : lastContent}",我先说个思路:从目标、约束、可行方案三步拆解。',
        '这个问题我会这样想…先确认关键假设,再列选项。',
        '嗯嗯,让我想想~ 可以补充一下背景吗?',
        '🤨 你这问题有坑,我反问一下:目的是什么?',
        '❓ 为什么你会这么问呀?',
      ]);
    }
    return pick([
      '收到。',
      '我在听~',
      '嗯嗯,继续说。',
      '有意思的想法。',
      '🌸 这样啊~',
      '🤨 然后呢?',
      '✨ 哇哦!',
    ]);
  }

  // ---------- OpenAI 兼容 ----------
  Future<String> _openAiCompatibleReply(
    AICharacter character,
    List<Message> recent,
  ) async {
    if (settings.apiKey.isEmpty) {
      throw const AIServiceException('未设置 API Key,请在设置中填写。');
    }
    final uri = Uri.parse('${_trimSlash(settings.apiBase)}/chat/completions');

    final messages = <Map<String, String>>[
      {'role': 'system', 'content': character.systemPrompt},
      ..._toOpenAiMessages(recent),
    ];

    final body = jsonEncode({
      'model': settings.model,
      'messages': messages,
      'temperature': character.temperature,
      'max_tokens': 512,
    });

    final resp = await http
        .post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${settings.apiKey}',
          },
          body: body,
        )
        .timeout(const Duration(seconds: 30));

    if (resp.statusCode >= 400) {
      throw AIServiceException(
          'LLM 返回错误 ${resp.statusCode}: ${_safeBody(resp.body)}');
    }

    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    final choices = data['choices'] as List<dynamic>?;
    if (choices == null || choices.isEmpty) {
      throw const AIServiceException('LLM 响应无 choices。');
    }
    final msg = choices.first['message'] as Map<String, dynamic>?;
    final content = msg?['content'] as String? ?? '';
    return content.trim();
  }

  // ---------- Ollama ----------
  Future<String> _ollamaReply(
    AICharacter character,
    List<Message> recent,
  ) async {
    final base = _trimSlash(settings.apiBase.isEmpty
        ? 'http://10.0.2.2:11434'
        : settings.apiBase);
    final uri = Uri.parse('$base/api/chat');

    final messages = <Map<String, String>>[
      {'role': 'system', 'content': character.systemPrompt},
      ..._toOpenAiMessages(recent),
    ];

    final body = jsonEncode({
      'model': settings.model.isEmpty ? 'llama3' : settings.model,
      'messages': messages,
      'stream': false,
      'options': {'temperature': character.temperature},
    });

    final resp = await http
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: body,
        )
        .timeout(const Duration(seconds: 60));

    if (resp.statusCode >= 400) {
      throw AIServiceException(
          'Ollama 返回错误 ${resp.statusCode}: ${_safeBody(resp.body)}');
    }
    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    final msg = data['message'] as Map<String, dynamic>?;
    return (msg?['content'] as String? ?? '').trim();
  }

  // ---------- helpers ----------
  List<Map<String, String>> _toOpenAiMessages(List<Message> recent) {
    final n = recent.length;
    final from = (n - settings.maxContextMessages).clamp(0, n);
    final slice = recent.sublist(from);
    return slice.where((m) => m.senderType != SenderType.system).map((m) {
      final role = m.senderType == SenderType.user ? 'user' : 'assistant';
      return {
        'role': role,
        // 标注发言人,让 LLM 知道谁在说话
        'content': '[${m.senderName}]: ${m.content}',
      };
    }).toList();
  }

  String _trimSlash(String s) =>
      s.endsWith('/') ? s.substring(0, s.length - 1) : s;

  String _safeBody(String s) => s.length > 200 ? '${s.substring(0, 200)}…' : s;
}

class AIServiceException implements Exception {
  final String message;
  const AIServiceException(this.message);
  @override
  String toString() => message;
}
