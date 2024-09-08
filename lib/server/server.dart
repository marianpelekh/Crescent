import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_plus/shelf_plus.dart';

void runShelfServer() async {
  final app = Router().plus;

  // HTML-based web client
  app.get('/', () => File('public/html_client.html'));

  // Track connected clients
  final users = <WebSocketSession>[];

  // Web socket route
  app.get(
    '/ws',
    () => WebSocketSession(
      onOpen: (ws) {
        // Join chat
        users.add(ws);
        users
            .where((user) => user != ws)
            .forEach((user) => user.send('A new user joined the chat.'));
      },
      onClose: (ws) {
        // Leave chat
        users.remove(ws);
        for (var user in users) {
          user.send('A user has left.');
        }
      },
      onMessage: (ws, dynamic data) {
        // Deliver messages to all users
        for (var user in users) {
          user.send(data);
        }
      },
    ),
  );

  // Start server
  final handler = const Pipeline().addHandler(app);
  final server = await io.serve(handler, 'localhost', 8080);
  print('Server listening on http://localhost:8080');
}
