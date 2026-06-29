import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/ai_character.dart';
import '../services/chat_state.dart';
import '../widgets/ai_avatar.dart';

/// AI 角色管理页
class AIManageScreen extends StatelessWidget {
  const AIManageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('管理 AI 角色'),
        actions: [
          IconButton(
            tooltip: '重置为默认',
            icon: const Icon(Icons.restart_alt),
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('重置角色?'),
                  content: const Text('将清空自定义角色,恢复为内置预设。'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('取消'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('重置'),
                    ),
                  ],
                ),
              );
              if (ok == true && context.mounted) {
                await context.read<ChatState>().resetCharacters();
              }
            },
          ),
        ],
      ),
      body: Consumer<ChatState>(
        builder: (_, state, __) {
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: state.characters.length,
            separatorBuilder: (_, __) =>
                const Divider(height: 1, indent: 72),
            itemBuilder: (_, i) {
              final c = state.characters[i];
              return ListTile(
                leading: AIAvatar(emoji: c.emoji, color: c.color, radius: 22),
                title: Text(c.name),
                subtitle: Text(
                  c.systemPrompt,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Switch(
                      value: c.enabled,
                      onChanged: (_) =>
                          context.read<ChatState>().toggleCharacter(c.id),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => _openEditor(context, c),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () async {
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('删除角色?'),
                            content: Text('将删除"${c.name}",不可恢复。'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('取消'),
                              ),
                              FilledButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('删除'),
                              ),
                            ],
                          ),
                        );
                        if (ok == true && context.mounted) {
                          await context.read<ChatState>().deleteCharacter(c.id);
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openEditor(context, null),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _openEditor(BuildContext context, AICharacter? original) async {
    final result = await Navigator.of(context).push<AICharacter>(
      MaterialPageRoute(
        builder: (_) => CharacterEditorScreen(original: original),
      ),
    );
    if (result == null || !context.mounted) return;
    final state = context.read<ChatState>();
    if (original == null) {
      await state.addCharacter(
        name: result.name,
        emoji: result.emoji,
        colorValue: result.color.value,
        systemPrompt: result.systemPrompt,
      );
    } else {
      await state.updateCharacter(result);
    }
  }
}

/// 角色编辑器
class CharacterEditorScreen extends StatefulWidget {
  final AICharacter? original;
  const CharacterEditorScreen({super.key, this.original});

  @override
  State<CharacterEditorScreen> createState() => _CharacterEditorScreenState();
}

class _CharacterEditorScreenState extends State<CharacterEditorScreen> {
  late final TextEditingController _name;
  late final TextEditingController _emoji;
  late final TextEditingController _prompt;
  late int _color;
  late double _temperature;

  static const _palette = <int>[
    0xFF4CAF50,
    0xFFE91E63,
    0xFFFF9800,
    0xFF03A9F4,
    0xFF9C27B0,
    0xFF607D8B,
    0xFF795548,
    0xFF009688,
  ];

  @override
  void initState() {
    super.initState();
    final o = widget.original;
    _name = TextEditingController(text: o?.name ?? '');
    _emoji = TextEditingController(text: o?.emoji ?? '🤖');
    _prompt = TextEditingController(text: o?.systemPrompt ?? '');
    _color = o?.color.value ?? _palette.first;
    _temperature = o?.temperature ?? 0.7;
  }

  @override
  void dispose() {
    _name.dispose();
    _emoji.dispose();
    _prompt.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.original == null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isNew ? '新增 AI 角色' : '编辑 AI 角色'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('保存'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Color(_color),
                child: Text(_emoji.text, style: const TextStyle(fontSize: 28)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _emoji,
                  maxLength: 2,
                  decoration: const InputDecoration(
                    labelText: '头像 Emoji',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _name,
            decoration: const InputDecoration(
              labelText: '名称',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          const Text('头像颜色'),
          const SizedBox(height: 6),
          Wrap(
            spacing: 10,
            children: _palette.map((c) {
              final selected = c == _color;
              return GestureDetector(
                onTap: () => setState(() => _color = c),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Color(c),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? Colors.black : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _prompt,
            minLines: 4,
            maxLines: 10,
            decoration: const InputDecoration(
              labelText: '系统提示词 (人设/语气/规则)',
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Text('创造性 (temperature): ${_temperature.toStringAsFixed(2)}'),
          Slider(
            value: _temperature,
            min: 0,
            max: 1.5,
            divisions: 15,
            label: _temperature.toStringAsFixed(2),
            onChanged: (v) => setState(() => _temperature = v),
          ),
        ],
      ),
    );
  }

  void _save() {
    final name = _name.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('名称不能为空')),
      );
      return;
    }
    final emoji = _emoji.text.trim().isEmpty ? '🤖' : _emoji.text.trim();
    final prompt = _prompt.text.trim();
    final updated = (widget.original ??
            AICharacter(
              id: 'tmp',
              name: name,
              emoji: emoji,
              color: Color(_color),
              systemPrompt: prompt,
            ))
        .copyWith(
      name: name,
      emoji: emoji,
      color: Color(_color),
      systemPrompt: prompt,
      temperature: _temperature,
    );
    Navigator.of(context).pop(updated);
  }
}
