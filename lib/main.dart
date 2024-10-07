import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './interface/auth_page.dart';
part './interface/main_page.dart';
part './interface/chats_panel.dart';
part './interface/rooms_panel.dart';
part './interface/center_panel.dart';
part './interface/home_page.dart';
part './interface/chat_page.dart';
part 'constants.dart';

void main() {
  runApp(const CrescentApp());
}

class CrescentApp extends StatelessWidget {
  const CrescentApp({super.key});

  Future<bool> _isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('loggedIn') ?? false;
  }

  Future<String?> _getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crescent',
      theme: ThemeData(
        fontFamily: 'JosefinSans',
        textTheme: TextTheme(
          bodyLarge: TextStyle(
            fontSize: _getFontSize(context, 75, 16.0, 26.0),
          ),
          bodyMedium: TextStyle(
            fontSize: _getFontSize(context, 75, 16.0, 26.0) * 0.7,
          ),
          bodySmall: TextStyle(
            fontSize: _getFontSize(context, 75, 16.0, 26.0) * 0.5,
          ),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: firstMain,
          primary: textColorH,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: secondMain,
          foregroundColor: textColorH,
        ),
      ),
      home: FutureBuilder<bool>(
        future: _isLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData && snapshot.data == true) {
            return FutureBuilder<String?>(
              future: _getUsername(),
              builder: (context, usernameSnapshot) {
                if (usernameSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (usernameSnapshot.hasData &&
                    usernameSnapshot.data != null) {
                  return MainPage(
                      title: 'Crescent', username: usernameSnapshot.data!);
                } else {
                  return const AuthPage();
                }
              },
            );
          } else {
            return const AuthPage();
          }
        },
      ),
      routes: {
        '/main': (context) =>
            const MainPage(title: 'Crescent', username: "Unauthorized"),
      },
    );
  }

  double _getFontSize(BuildContext context, double multiplier,
      double minFontSize, double maxFontSize) {
    final constraints = MediaQuery.of(context).size;
    double fontSize = sqrt(constraints.height * constraints.width) / multiplier;
    return fontSize.clamp(minFontSize, maxFontSize);
  }
}

class WebSocketService {
  late WebSocketChannel channel;
  late final Stream<dynamic> broadcastStream;

  WebSocketService(String url) {
    channel = WebSocketChannel.connect(Uri.parse(url));
    broadcastStream = channel.stream.asBroadcastStream();
    listenToMessages();
  }

  Stream<dynamic> listenToMessages() {
    return broadcastStream;
  }

  Future<String> getMessages(int user1Id, int user2id) async {
    String message = jsonEncode(
        {"type": "getmessages", 'sender': user1Id, 'receiver': user2id});
    if (kDebugMode) {
      print(message);
    }
    channel.sink.add(message);

    String data = await broadcastStream.firstWhere((event) {
      final decoded = jsonDecode(event);
      return decoded['type'] == 'getmessages';
    });
    print(data);

return data;
    // final response = jsonEncode(data);
    // return response;
  }

  Future<List<ChatTile>> getChats() async {
    final prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt("userId");

    if (userId != null) {
      channel.sink.add(jsonEncode({'type': 'getChats', 'userId': userId}));
      if (kDebugMode) {
        print("Chats fetcher added to sink.");
      }

      try {
        final message = await broadcastStream.firstWhere((message) {
          final data = jsonDecode(message);
          return data['type'] == 'chatList';
        });

        final data = jsonDecode(message);
        final List<dynamic> decodedContent = data['content'];

        // Генерація списку ChatTile
        List<ChatTile> chats = decodedContent.map((chat) {
          final chatData = jsonDecode(chat['content']);
          return ChatTile(
            imageName: '../assets/avatar.png',
            name: chatData['username'],
            message: 'Text chat',
            chatId: chatData['id'],
            usId: chatData['usId'],
          );
        }).toList();

        return chats;
      } catch (e) {
        if (kDebugMode) {
          print('Error fetching chats: $e');
        }
        return [];
      }
    } else {
      return [];
    }
  }

  Future<String?> getImage(String imageName) async {
    // Відправляємо запит на отримання зображення
    channel.sink.add(jsonEncode({'type': 'getImage', 'imageName': imageName}));

    try {
      // Очікуємо на відповідь від сервера, де буде URL зображення
      final response = await broadcastStream.firstWhere((message) {
        final data = jsonDecode(message);
        return data['type'] == 'getImage' && data['imageName'] == imageName;
      });

      // Розбираємо відповідь
      final decodedData = jsonDecode(response);
      return decodedData['imageUrl'];
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching image: $e");
      }
      return null;
    }
  }

  Future<void> sendTextMessage(int userId, int chatId, String text) async {
    String mediacontent = jsonEncode({
      'photo': null,
      'video': null,
      'sound': null,
    });

    final message = {
      'type': 'sendtextmessage',
      'sender': userId,
      'receiver': chatId,
      'text': text,
      'media': mediacontent,
    };

    sendMessage(jsonEncode(message));
  }

  void sendMessage(String message) {
    channel.sink.add(message);
  }

  void closeConnection() {
    channel.sink.close();
  }
}
