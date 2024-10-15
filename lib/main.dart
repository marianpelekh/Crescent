import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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

  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }

  Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crescent',
      theme: ThemeData(
        fontFamily: 'JosefinSans',
        textTheme: const TextTheme(
          bodyLarge: TextStyle(
            fontSize: textLarge,
          ),
          bodyMedium: TextStyle(
            fontSize: textMedium,
          ),
          bodySmall: TextStyle(
            fontSize: textSmall,
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
              future: getUsername(),
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
}
class WebSocketService {
  late WebSocketChannel channel;
  late final Stream<dynamic> broadcastStream;

  WebSocketService(String url) {
    try {
      channel = WebSocketChannel.connect(Uri.parse(url));
      broadcastStream = channel.stream.asBroadcastStream();
      listenToMessages();
      if (kDebugMode) {
        print("WebSocketService initialized with URL: $url");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error initializing WebSocket: $e");
      }
    }
  }

  Stream<dynamic> listenToMessages() {
    return broadcastStream;
  }

  Future<String> getMessages(int user1Id, int user2Id) async {
    String message = jsonEncode(
        {"type": "getmessages", 'sender': user1Id, 'receiver': user2Id});
    if (kDebugMode) {
      print("Sending message to WebSocket: $message");
    }
    try {
      channel.sink.add(message);

      String data = await broadcastStream.firstWhere((event) {
        final decoded = jsonDecode(event);
        return decoded['type'] == 'getmessages';
      });

      if (kDebugMode) {
        print("Received messages data: $data");
      }
      return data;
    } catch (e) {
      if (kDebugMode) {
        print("Error getting messages: $e");
      }
      return '';
    }
  }

  Future<List<ChatTile>> getChats() async {
    final prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt("userId");

    if (userId == null) {
      if (kDebugMode) {
        print("UserId not found in SharedPreferences");
      }
      return [];
    }

    try {
      channel.sink.add(jsonEncode({'type': 'getChats', 'userId': userId}));
      if (kDebugMode) {
        print("Requesting chats for userId: $userId");
      }

      final message = await broadcastStream.firstWhere((message) {
        final data = jsonDecode(message);
        return data['type'] == 'chatList';
      });

      final data = jsonDecode(message);
      final List<dynamic> decodedContent = data['content'];

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
  }

  Future<String?> getImage(String imageName) async {
    try {
      channel.sink.add(jsonEncode({'type': 'getImage', 'imageName': imageName}));

      final response = await broadcastStream.firstWhere((message) {
        final data = jsonDecode(message);
        return data['type'] == 'getImage' && data['imageName'] == imageName;
      });

      final decodedData = jsonDecode(response);
      return decodedData['imageUrl'];
    } catch (e) {
      if (kDebugMode) {
        print("Error fetching image: $e");
      }
      return null;
    }
  }

  Future<void> sendTextMessage(int userId, int recId, String text) async {
    String mediacontent = jsonEncode({
      'photo': null,
      'video': null,
      'sound': null,
    });

    final message = {
      'type': 'sendtextmessage',
      'sender': userId,
      'receiver': recId,
      'text': text,
      'media': mediacontent,
    };

    sendMessage(jsonEncode(message));
  }

  void sendMessage(String message) {
    try {
      channel.sink.add(message);
      if (kDebugMode) {
        print("Message sent: $message");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error sending message: $e");
      }
    }
  }

  void closeConnection() {
    try {
      channel.sink.close();
      if (kDebugMode) {
        print("WebSocket connection closed.");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error closing WebSocket connection: $e");
      }
    }
  }

  bool isConnected() {
    return channel.closeCode == null; // WebSocket не закритий
  }
}
