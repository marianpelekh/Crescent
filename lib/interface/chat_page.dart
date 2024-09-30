part of '../main.dart';

class ChatPage extends StatefulWidget {
  final String chatName;
  final int chatId;

  const ChatPage({super.key, required this.chatName, required this.chatId});

  @override
  ChatPageState createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> {
  final _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  late final WebSocketService _webSocketService;
  int? userId;

  @override
  void initState() {
    super.initState();
    _webSocketService = WebSocketService(ipAddress);
    if (kDebugMode) {
      print("WebSocket in init state ChatPageState has been initialized.");
    }

    _loadCurrentUserId();

    _webSocketService.listenToMessages().listen((message) {
      _handleIncomingMessage(message);
    }, onError: (error) {
      if (kDebugMode) {
        print("Error (ChatPageState, WebSocket connect): $error");
      }
    }, onDone: () {
      if (kDebugMode) {
        print("Connection closed.");
      }
    });

    _loadInitialMessages();
  }

  Future<void> _loadCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getInt('userId');
    });
  }

  void _loadInitialMessages() async {
    final prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('userId');
    if (userId != null) {
      await reloadMessages(userId, widget.chatId);
    } else {
      if (kDebugMode) {
        print("User ID is null");
      }
    }
  }

  Future<void> reloadMessages(int userId, int chatId) async {
    if (kDebugMode) {
      print("ReloadMessages");
      print(chatId);
    }

    Future<void> reloadMessages(int userId, int chatId) async {
      if (kDebugMode) {
        print("Trying to reload messages for Chat ID: $chatId");
      }

      try {
        if (mounted) {
          if (kDebugMode) {
            print("Mounted");
          }
          String messages = await _webSocketService.getMessages(userId, chatId);
          List<Map<String, dynamic>> decodedMessages =
              List<Map<String, dynamic>>.from(jsonDecode(messages));

          updateMessages(decodedMessages);
        } else {
          if (kDebugMode) {
            print("Not mounted, restart in 5s");
          }
          await Future.delayed(const Duration(seconds: 5));
          reloadMessages(userId, chatId);
        }
      } catch (e) {
        if (kDebugMode) {
          print("Error loading messages: $e");
        }
      }
    }
  }

  void updateMessages(List<Map<String, dynamic>> messages) {
    setState(() {
      _messages.clear();
      _messages.addAll(messages);
    });
  }

  void _handleIncomingMessage(String message) {
    try {
      final decodedMessage = jsonDecode(message);
      if (decodedMessage['type'] == 'getmessages') {
        final List<dynamic> messagesContent =
            jsonDecode(decodedMessage['content']);
        List<Map<String, dynamic>> messages =
            List<Map<String, dynamic>>.from(messagesContent);
        updateMessages(messages);
      } else {
        setState(() {
          _messages.add({
            'textcontent': decodedMessage['text'],
            'sender': decodedMessage['sender'],
          });
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error handling incoming message: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Заголовок з назвою чату
        Container(
          padding: const EdgeInsets.all(8.0),
          color: secondMain,
          child: Text(
            widget.chatName,
            style: const TextStyle(
              color: textColorH,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // Список повідомлень
        Expanded(
          child: ListView.builder(
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final messageData = _messages[index];
              return Align(
                alignment: messageData['sender'] == userId
                    ? Alignment.bottomRight
                    : Alignment.bottomLeft,
                child: FractionallySizedBox(
                  widthFactor: 0.7,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: thirdMain,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      messageData['textcontent'] ?? '',
                      style: const TextStyle(color: textColorH),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        // Поле вводу повідомлень
        Material(
          color: secondMain,
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
                      border: InputBorder.none,
                      hintText: 'Write a message...',
                      hintStyle: TextStyle(color: thirdMain),
                    ),
                    style: const TextStyle(color: textColorH),
                  ),
                ),
              ),
              IconButton(
                color: thirdMain,
                icon: const Icon(Icons.send),
                onPressed: _sendMessage,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _sendMessage() async {
    if (_messageController.text.isNotEmpty && widget.chatId != 0) {
      final prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('userId');

      // Виклик сервісу для надсилання повідомлення
      await _webSocketService.sendTextMessage(
          userId!, widget.chatId, _messageController.text);

      setState(() {
        _messages.add({
          'textcontent': _messageController.text,
          'sender': userId,
        });
      });

      _messageController.clear();
    } else {
      if (kDebugMode) {
        print("Message is empty or receiver id is 0.");
        _messageController.clear();
      }
    }
  }

  @override
  void dispose() {
    _webSocketService.closeConnection();
    super.dispose();
  }
}
