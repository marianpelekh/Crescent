import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'dart:math';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './interface/auth_page.dart';

part './interface/main_page.dart';
part 'interface/chats_panel.dart';
part 'interface/rooms_panel.dart';
part 'interface/center_panel.dart';
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
          seedColor: const Color.fromARGB(255, 0, 0, 0),
          primary: const Color.fromARGB(255, 255, 255, 255),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 32, 32, 32),
          foregroundColor: Color.fromARGB(255, 232, 232, 232),
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
              if (usernameSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (usernameSnapshot.hasData && usernameSnapshot.data != null) {
                return MainPage(title: 'Crescent', username: usernameSnapshot.data!);
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
        '/main': (context) => const MainPage(title: 'Crescent', username: "Unauthorized"),
      },
    );
  }

  double _getFontSize(BuildContext context, double multiplier, double minFontSize, double maxFontSize) {
    final constraints = MediaQuery.of(context).size;
    double fontSize = sqrt(constraints.height * constraints.width) / multiplier;
    return fontSize.clamp(minFontSize, maxFontSize);
  }
}

class WebSocketService {
  late WebSocketChannel channel;

  WebSocketService(String url) {
    channel = WebSocketChannel.connect(Uri.parse(url));
    channel.stream.listen((message) {
      // Логіка обробки отриманих повідомлень
      print("Отримане повідомлення: $message");
    }, onError: (error) {
      // Логіка обробки помилок
      print("Помилка: $error");
    }, onDone: () {
      // Логіка після завершення з'єднання
      print("З'єднання закрите.");
    });
  }

  void sendMessage(String message) {
    channel.sink.add(message);
  }

  void closeConnection() {
    channel.sink.close();
  }
}

