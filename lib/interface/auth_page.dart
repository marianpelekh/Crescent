// ignore_for_file: prefer_interpolation_to_compose_strings

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../main.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  AuthPageState createState() => AuthPageState();
}

class AuthPageState extends State<AuthPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  late WebSocketChannel _channel;

  @override
  void initState() {
    super.initState();
    _channel = IOWebSocketChannel.connect(ipAddress);
  }

  Future<void> authorize() async {
    final username = _usernameController.text;
    final password = _passwordController.text;

    final message = jsonEncode({
      'type': 'auth',
      'username': username,
      'password': password,
    });
    _channel.sink.add(message);
    _channel.stream.listen((response) async {
      final data = jsonDecode(response);
      if (kDebugMode) {
        print(data);
      }

      if (data['type'] != null && data['type'] == 'auth') {
        if (data['status'] == 'success') {
          if (kDebugMode) {
            print("succesful login");
          }
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('loggedIn', true);
          await prefs.setString('username', username);
          await prefs.setInt('userId', data['userid']);

          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    MainPage(title: 'Crescent', username: username),
              ),
            );
          }
        } else {
          if (kDebugMode) {
            print("login failed");
          }
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Invalid username or password')),
            );
          }
        }
      } else if (data['type'] != null &&
          data['type'] == 'auth' &&
          data['status'] == 'failed') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid login or password'),
              backgroundColor: errorColor,
            ),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Container(
          width: screenWidth * 0.75,
          height: screenHeight * 0.5,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: secondMain,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Authorization",
                  style: TextStyle(
                      color: textColorH,
                      fontSize: 32,
                      fontFamily: "JosefinSans")),
              const SizedBox(height: 50),
              TextField(
                style: const TextStyle(
                  color: textColorH,
                ),
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (String value) {
                  authorize();
                },
              ),
              const SizedBox(height: 20),
              TextField(
                style: const TextStyle(
                  color: textColorH,
                ),
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (String value) {
                  authorize();
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 150,
                height: 50,
                child: ElevatedButton(
                  onPressed: authorize,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: thirdMain,
                    foregroundColor: textColorH,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Login', style: TextStyle(fontSize: 20)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
