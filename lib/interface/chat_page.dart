part of '../main.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _channel = WebSocketChannel.connect(Uri.parse(ipAddress));
  final _messageController = TextEditingController();
  final List<String> _messages = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: thirdMain, borderRadius: BorderRadius.circular(5)),
                  child: Text(  
                    _messages[index],
                    style: const TextStyle(color: textColorH), // Колір тексту
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          height: 50,
          decoration: const BoxDecoration(
            color: secondMain,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: secondMain,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                        borderSide: BorderSide.none,
                      ),
                      hintText: 'Write a message...',
                    ),
                    style: const TextStyle(
                      color: textColorH, // Колір тексту
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: _sendMessage,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _sendMessage() async {
    final content = _messageController.text;
    if (content.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('userId');
      if (kDebugMode) {
        print(userId);
      }
      final message = jsonEncode({
        'type': 'message',
        'sender': userId,
        'receiver': 'server',
        'content': content
      });
      _channel.sink.add(message);
      _messageController.clear();
    }
  }

  @override
  void initState() {
    super.initState();
    _channel.stream.listen((message) {
      setState(() {
        _messages.add(message);
      });
    });
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }
}
