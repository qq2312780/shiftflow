import 'package:flutter/material.dart';

/// 消息发送者类型
enum SenderType { user, ai, system }

/// 聊天消息
class Message {
  final String id;
  final SenderType senderType;
  final String senderId; // user.id 或 ai_character.id; system 消息为空
  final String senderName;
  final String avatarEmoji; // 头像用 emoji 表示,避免引入图片资源
  final Color avatarColor;
  final String content;
  final DateTime timestamp;
  final bool isThinking; // AI 是否正在"思考中"

  const Message({
    required this.id,
    required this.senderType,
    required this.senderId,
    required this.senderName,
    required this.avatarEmoji,
    required this.avatarColor,
    required this.content,
    required this.timestamp,
    this.isThinking = false,
  });

  Message copyWith({
    String? content,
    bool? isThinking,
  }) {
    return Message(
      id: id,
      senderType: senderType,
      senderId: senderId,
      senderName: senderName,
      avatarEmoji: avatarEmoji,
      avatarColor: avatarColor,
      content: content ?? this.content,
      timestamp: timestamp,
      isThinking: isThinking ?? this.isThinking,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'senderType': senderType.name,
        'senderId': senderId,
        'senderName': senderName,
        'avatarEmoji': avatarEmoji,
        'avatarColor': avatarColor.value,
        'content': content,
        'timestamp': timestamp.toIso8601String(),
      };

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      senderType: SenderType.values.firstWhere(
        (e) => e.name == json['senderType'],
        orElse: () => SenderType.system,
      ),
      senderId: json['senderId'] as String? ?? '',
      senderName: json['senderName'] as String? ?? '',
      avatarEmoji: json['avatarEmoji'] as String? ?? '🤖',
      avatarColor: Color(json['avatarColor'] as int? ?? 0xFF9E9E9E),
      content: json['content'] as String? ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
