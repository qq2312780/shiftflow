import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/ai_character.dart';
import '../services/chat_state.dart';
import '../widgets/message_bubble.dart';
import 'ai_manage_screen.dart';
import 'settings_screen.dart';

/// 群聊主屏
class ChatRoomScreen extends StatefulWidget {
  const ChatRoomScreen({super.key});

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final _controller = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _focus = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _scrollCtrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollCtrl.hasClients) return;
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _send() async {
    final text = _controller.text;
    if (text.trim().isEmpty) return;
    _controller.clear();
    await context.read<ChatState>().sendUserMessage(text);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 群聊'),
        actions: [
          IconButton(
            tooltip: '管理 AI',
            icon: const Icon(Icons.group),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const AIManageScreen(),
                ),
              );
            },
          ),
          IconButton(
            tooltip: '设置',
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _ActiveBar(),
          const Divider(height: 1),
          Expanded(
            child: Consumer<ChatState>(
              builder: (_, state, __) {
                _scrollToBottom();
                if (state.messages.isEmpty) {
                  return const Center(child: Text('还没有消息,开个头吧 👇'));
                }
                return ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: state.messages.length,
                  itemBuilder: (_, i) =>
                      MessageBubble(message: state.messages[i]),
                );
              },
            ),
          ),
          const Divider(height: 1),
          SafeArea(
            top: false,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focus,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: '说点什么…所有启用的 AI 都会回复',
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Consumer<ChatState>(
                    builder: (_, state, __) => IconButton.filled(
                      onPressed: state.aiResponding ? null : _send,
                      icon: state.aiResponding
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.send),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 顶部"在线 AI"指示条
class _ActiveBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<ChatState>();
    final enabled = state.characters.where((c) => c.enabled).toList();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Row(
        children: [
          const Icon(Icons.circle, color: Colors.green, size: 10),
          const SizedBox(width: 6),
          Text(
            '在线 ${enabled.length} 位 AI',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: enabled
                    .map<Widget>(
                      (c) => Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: _Chip(c: c),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final AICharacter c;
  const _Chip({required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: c.color.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(c.emoji),
          const SizedBox(width: 4),
          Text(
            c.name,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}
