import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_plus/shelf_plus.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import '../database/connect_db.dart';

class MessageServer {
  final DatabaseService databaseService;

  MessageServer(this.databaseService);

  Handler get handler {
    final router = Router();

    // Маршрут для WebSocket з'єднання
    router.get('/ws', (Request request) {
      return shelfWebSocketHandler((webSocket) async {
        webSocket.listen((message) async {
          try {
            final data = jsonDecode(message) as Map<String, dynamic>;
            final sender = data['sender'] as String?;
            final receiver = data['receiver'] as String?;
            final text = data['message'] as String?;

            if (sender != null && receiver != null && text != null) {
              await databaseService.sendMessage(sender, receiver, text);
              // Відправляємо повідомлення назад всім підключеним клієнтам
              webSocket.add(jsonEncode({
                'sender': sender,
                'receiver': receiver,
                'message': text,
                'timestamp': DateTime.now().toIso8601String()
              }));
            } else {
              webSocket.add(jsonEncode({'error': 'Invalid input'}));
            }
          } catch (e) {
            webSocket.add(jsonEncode({'error': 'Error processing message'}));
          }
        });
      })(request);
    });

    return router.call;
  }
  
  shelfWebSocketHandler(Future<Null> Function(dynamic webSocket) param0) {}
}
