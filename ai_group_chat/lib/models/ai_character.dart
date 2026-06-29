import 'package:flutter/material.dart';

/// AI 角色
class AICharacter {
  final String id;
  String name; // 名字,如"小智"
  String emoji; // 头像 emoji
  Color color; // 头像背景色
  String systemPrompt; // 系统提示词,定义人格/语气
  bool enabled; // 是否启用(加入当前群聊)
  double temperature; // 创造性 0~1

  AICharacter({
    required this.id,
    required this.name,
    required this.emoji,
    required this.color,
    required this.systemPrompt,
    this.enabled = true,
    this.temperature = 0.7,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'emoji': emoji,
        'color': color.value,
        'systemPrompt': systemPrompt,
        'enabled': enabled,
        'temperature': temperature,
      };

  factory AICharacter.fromJson(Map<String, dynamic> json) {
    return AICharacter(
      id: json['id'] as String,
      name: json['name'] as String,
      emoji: json['emoji'] as String? ?? '🤖',
      color: Color(json['color'] as int? ?? 0xFF9E9E9E),
      systemPrompt: json['systemPrompt'] as String? ?? '',
      enabled: json['enabled'] as bool? ?? true,
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.7,
    );
  }

  AICharacter copyWith({
    String? name,
    String? emoji,
    Color? color,
    String? systemPrompt,
    bool? enabled,
    double? temperature,
  }) {
    return AICharacter(
      id: id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      color: color ?? this.color,
      systemPrompt: systemPrompt ?? this.systemPrompt,
      enabled: enabled ?? this.enabled,
      temperature: temperature ?? this.temperature,
    );
  }
}
