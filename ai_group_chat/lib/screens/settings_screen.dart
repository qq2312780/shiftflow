import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_settings.dart';
import '../services/chat_state.dart';

/// 设置页(LLM Provider / API Key / 模型 / 上下文长度 / 模拟延迟)
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late AppSettings _draft;
  final _apiBaseCtrl = TextEditingController();
  final _apiKeyCtrl = TextEditingController();
  final _modelCtrl = TextEditingController();
  final _ctxCtrl = TextEditingController();
  late int _delayMs;

  @override
  void initState() {
    super.initState();
    final s = context.read<ChatState>().settings;
    _draft = AppSettings(
      provider: s.provider,
      apiBase: s.apiBase,
      apiKey: s.apiKey,
      model: s.model,
      maxContextMessages: s.maxContextMessages,
      aiReplyDelay: s.aiReplyDelay,
    );
    _apiBaseCtrl.text = _draft.apiBase;
    _apiKeyCtrl.text = _draft.apiKey;
    _modelCtrl.text = _draft.model;
    _ctxCtrl.text = _draft.maxContextMessages.toString();
    _delayMs = _draft.aiReplyDelay.inMilliseconds;
  }

  @override
  void dispose() {
    _apiBaseCtrl.dispose();
    _apiKeyCtrl.dispose();
    _modelCtrl.dispose();
    _ctxCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final ctx = int.tryParse(_ctxCtrl.text.trim());
    _draft = AppSettings(
      provider: _draft.provider,
      apiBase: _apiBaseCtrl.text.trim(),
      apiKey: _apiKeyCtrl.text.trim(),
      model: _modelCtrl.text.trim(),
      maxContextMessages: (ctx == null || ctx < 2) ? 20 : ctx,
      aiReplyDelay: Duration(milliseconds: _delayMs),
    );
    await context.read<ChatState>().updateSettings(_draft);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('设置已保存')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
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
          const Text('LLM 提供方'),
          const SizedBox(height: 8),
          SegmentedButton<LLMProvider>(
            segments: const [
              ButtonSegment(
                value: LLMProvider.mock,
                label: Text('Mock'),
                icon: Icon(Icons.bolt),
              ),
              ButtonSegment(
                value: LLMProvider.openaiCompatible,
                label: Text('OpenAI 兼容'),
                icon: Icon(Icons.cloud_outlined),
              ),
              ButtonSegment(
                value: LLMProvider.ollama,
                label: Text('Ollama'),
                icon: Icon(Icons.memory),
              ),
            ],
            selected: {_draft.provider},
            onSelectionChanged: (s) =>
                setState(() => _draft.provider = s.first),
          ),
          const SizedBox(height: 16),
          if (_draft.provider == LLMProvider.openaiCompatible) ...[
            TextField(
              controller: _apiBaseCtrl,
              decoration: const InputDecoration(
                labelText: 'API Base',
                helperText: '如 https://api.openai.com/v1 / 自建网关 / 青云API',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _apiKeyCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'API Key',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _modelCtrl,
              decoration: const InputDecoration(
                labelText: '模型名',
                helperText: 'gpt-4o-mini / qwen-turbo / deepseek-chat …',
                border: OutlineInputBorder(),
              ),
            ),
          ] else if (_draft.provider == LLMProvider.ollama) ...[
            TextField(
              controller: _apiBaseCtrl,
              decoration: const InputDecoration(
                labelText: 'Ollama 地址',
                helperText: '本机模拟器用 http://10.0.2.2:11434',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _modelCtrl,
              decoration: const InputDecoration(
                labelText: '模型名',
                helperText: 'llama3 / qwen2 / mistral …',
                border: OutlineInputBorder(),
              ),
            ),
          ] else ...[
            const Card(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  'Mock 模式无需联网,内置模板化回复,适合先体验 UI 与流程。',
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          TextField(
            controller: _ctxCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: '上下文消息条数',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Text('AI 模拟思考延迟: ${_delayMs}ms'),
          Slider(
            value: _delayMs.toDouble(),
            min: 0,
            max: 5000,
            divisions: 50,
            label: '$_delayMs ms',
            onChanged: (v) => setState(() => _delayMs = v.round()),
          ),
          const SizedBox(height: 24),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete_sweep),
            title: const Text('清空聊天记录'),
            onTap: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('清空聊天?'),
                  content: const Text('将删除所有本地消息,无法恢复。'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('取消'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('清空'),
                    ),
                  ],
                ),
              );
              if (ok == true && context.mounted) {
                await context.read<ChatState>().clearChat();
                if (context.mounted) Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }
}
