import 'package:flutter/material.dart';

/// 紧凑的头像(用于角色列表)
class AIAvatar extends StatelessWidget {
  final String emoji;
  final Color color;
  final double radius;
  const AIAvatar({
    super.key,
    required this.emoji,
    required this.color,
    this.radius = 20,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: color,
      child: Text(emoji, style: TextStyle(fontSize: radius)),
    );
  }
}
