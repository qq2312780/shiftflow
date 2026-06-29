import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/chat_room_screen.dart';
import 'services/chat_state.dart';
import 'services/storage_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AIGroupChatApp());
}

class AIGroupChatApp extends StatelessWidget {
  const AIGroupChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChatState(storage: StorageService())..init(),
      child: MaterialApp(
        title: 'AI 群聊',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6750A4)),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF6750A4),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        home: const ChatRoomScreen(),
      ),
    );
  }
}
