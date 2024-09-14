import 'package:mysql1/mysql1.dart';

class DatabaseService {
  final String host;
  final int port;
  final String user;
  final String password;
  final String dbName;
  MySqlConnection? _connection;

  DatabaseService({
    required this.host,
    required this.port,
    required this.user,
    required this.password,
    required this.dbName,
  });

  Future<void> connect() async {
    _connection = await MySqlConnection.connect(
      ConnectionSettings(
        host: host,
        port: port,
        user: user,
        password: password,
        db: dbName,
      ),
    );
  }

  Future<void> close() async {
    await _connection?.close();
  }

  Future<void> sendMessage(String sender, String receiver, String content) async {
    if (_connection == null) {
      throw Exception('No database connection');
    }

    final query = 'INSERT INTO messages (sender, receiver, content, created_at) VALUES (?, ?, ?, ?)';
    final timestamp = DateTime.now().toIso8601String();
    await _connection!.query(query, [sender, receiver, content, timestamp]);
  }

  // Метод для отримання повідомлень
  Future<List<Map<String, dynamic>>> getMessages() async {
    if (_connection == null) {
      throw Exception('No database connection');
    }

    final results = await _connection!.query('SELECT * FROM messages ORDER BY created_at DESC');
    return results
        .map((row) => {
              'sender': row['sender'],
              'receiver': row['receiver'],
              'message': row['content'],
              'created_at': row['created_at']
            })
        .toList();
  }
}
