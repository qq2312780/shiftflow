import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ai_character.dart';
import '../models/app_settings.dart';
import '../models/message.dart';

/// 本地存储服务:使用 SharedPreferences 持久化
class StorageService {
  static const _kMessages = 'chat_messages_v1';
  static const _kCharacters = 'ai_characters_v1';
  static const _kSettings = 'app_settings_v1';

  Future<List<Message>> loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kMessages);
    if (raw == null || raw.isEmpty) return <Message>[];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .whereType<Map<String, dynamic>>()
          .map(Message.fromJson)
          .toList();
    } catch (_) {
      return <Message>[];
    }
  }

  Future<void> saveMessages(List<Message> messages) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(messages.map((m) => m.toJson()).toList());
    await prefs.setString(_kMessages, raw);
  }

  Future<List<AICharacter>> loadCharacters() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kCharacters);
    if (raw == null || raw.isEmpty) return <AICharacter>[];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .whereType<Map<String, dynamic>>()
          .map(AICharacter.fromJson)
          .toList();
    } catch (_) {
      return <AICharacter>[];
    }
  }

  Future<void> saveCharacters(List<AICharacter> chars) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(chars.map((c) => c.toJson()).toList());
    await prefs.setString(_kCharacters, raw);
  }

  Future<AppSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kSettings);
    if (raw == null || raw.isEmpty) return AppSettings();
    try {
      return AppSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return AppSettings();
    }
  }

  Future<void> saveSettings(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kSettings, jsonEncode(settings.toJson()));
  }
}
