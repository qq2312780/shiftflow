import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../data/default_characters.dart';
import '../models/ai_character.dart';
import '../models/app_settings.dart';
import '../models/message.dart';
import 'ai_service.dart';
import 'storage_service.dart';

/// 群聊状态管理
class ChatState extends ChangeNotifier {
  final StorageService storage;
  AppSettings settings;
  List<AICharacter> characters;
  List<Message> messages = [];

  late AIService _aiService;
  bool _aiResponding = false;
  final _uuid = const Uuid();

  ChatState({required this.storage})
      : settings = AppSettings(),
        characters = defaultCharacters() {
    _aiService = AIService(settings);
  }

  bool get aiResponding => _aiResponding;

  Future<void> init() async {
    settings = await storage.loadSettings();
    final saved = await storage.loadCharacters();
    if (saved.isNotEmpty) {
      characters = saved;
    }
    messages = await storage.loadMessages();
    if (messages.isEmpty) {
      messages = [
        Message(
          id: _uuid.v4(),
          senderType: SenderType.system,
          senderId: '',
          senderName: '系统',
          avatarEmoji: 'ℹ️',
          avatarColor: const Color(0xFF607D8B),
          content: '欢迎来到 AI 群聊!你说话后,所有已启用的 AI 角色都会参与讨论。'
              '可在右上角"管理 AI"中调整角色与模型。',
          timestamp: DateTime.now(),
        ),
      ];
      await _persistMessages();
    }
    _aiService = AIService(settings);
    notifyListeners();
  }

  // ---------- 用户发消息 ----------
  Future<void> sendUserMessage(String text) async {
    final content = text.trim();
    if (content.isEmpty) return;

    final userMsg = Message(
      id: _uuid.v4(),
      senderType: SenderType.user,
      senderId: 'user',
      senderName: '我',
      avatarEmoji: '🙂',
      avatarColor: const Color(0xFF1976D2),
      content: content,
      timestamp: DateTime.now(),
    );
    messages.add(userMsg);
    await _persistMessages();
    notifyListeners();

    await _triggerAIReplies();
  }

  /// 让所有已启用的 AI 依次回复(串行,模拟群聊节奏)
  Future<void> _triggerAIReplies() async {
    if (_aiResponding) return;
    final enabled = characters.where((c) => c.enabled).toList();
    if (enabled.isEmpty) return;
    _aiResponding = true;
    notifyListeners();

    for (final ai in enabled) {
      // 占位"思考中"气泡
      final thinking = Message(
        id: _uuid.v4(),
        senderType: SenderType.ai,
        senderId: ai.id,
        senderName: ai.name,
        avatarEmoji: ai.emoji,
        avatarColor: ai.color,
        content: '',
        timestamp: DateTime.now(),
        isThinking: true,
      );
      messages.add(thinking);
      await _persistMessages();
      notifyListeners();

      try {
        final reply = await _aiService.generateReply(
          character: ai,
          recentMessages: _sliceContext(),
        );
        final idx = messages.indexWhere((m) => m.id == thinking.id);
        if (idx >= 0) {
          messages[idx] = thinking.copyWith(content: reply, isThinking: false);
        }
      } catch (e) {
        final idx = messages.indexWhere((m) => m.id == thinking.id);
        if (idx >= 0) {
          messages[idx] = thinking.copyWith(
            content: '[$ai.name 出错了: $e]',
            isThinking: false,
          );
        }
      }
      await _persistMessages();
      notifyListeners();
    }
    _aiResponding = false;
    notifyListeners();
  }

  List<Message> _sliceContext() {
    final n = messages.length;
    final from = (n - settings.maxContextMessages).clamp(0, n);
    return messages.sublist(from);
  }

  // ---------- 角色管理 ----------
  Future<void> toggleCharacter(String id) async {
    final idx = characters.indexWhere((c) => c.id == id);
    if (idx < 0) return;
    characters[idx] = characters[idx].copyWith(enabled: !characters[idx].enabled);
    await storage.saveCharacters(characters);
    notifyListeners();
  }

  Future<void> updateCharacter(AICharacter updated) async {
    final idx = characters.indexWhere((c) => c.id == updated.id);
    if (idx < 0) return;
    characters[idx] = updated;
    await storage.saveCharacters(characters);
    notifyListeners();
  }

  Future<AICharacter> addCharacter({
    required String name,
    required String emoji,
    required int colorValue,
    required String systemPrompt,
  }) async {
    final c = AICharacter(
      id: 'char_${_uuid.v4()}',
      name: name,
      emoji: emoji,
      color: Color(colorValue),
      systemPrompt: systemPrompt,
    );
    characters.add(c);
    await storage.saveCharacters(characters);
    notifyListeners();
    return c;
  }

  Future<void> deleteCharacter(String id) async {
    characters.removeWhere((c) => c.id == id);
    await storage.saveCharacters(characters);
    notifyListeners();
  }

  Future<void> resetCharacters() async {
    characters = defaultCharacters();
    await storage.saveCharacters(characters);
    notifyListeners();
  }

  // ---------- 设置 ----------
  Future<void> updateSettings(AppSettings newSettings) async {
    settings = newSettings;
    _aiService = AIService(settings);
    await storage.saveSettings(settings);
    notifyListeners();
  }

  // ---------- 工具 ----------
  Future<void> clearChat() async {
    messages = [];
    await _persistMessages();
    notifyListeners();
  }

  Future<void> _persistMessages() => storage.saveMessages(messages);
}
