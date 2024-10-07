part of '../main.dart';

class ChatPage extends StatefulWidget {
  final String chatName;
  final int recId;

  const ChatPage({super.key, required this.chatName, required this.recId});

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
      await reloadMessages(userId, widget.recId);
    } else {
      if (kDebugMode) {
        print("User ID is null");
      }
    }
  }

  Future<void> reloadMessages(int userId, int recId) async {
    if (kDebugMode) {
      print("Trying to reload messages for Chat ID: $recId");
    }

    try {
      if (mounted) {
        if (kDebugMode) {
          print("Mounted");
        }

        String messages = await _webSocketService.getMessages(userId, recId);
        var decodedMessages = jsonDecode(messages);
        print(decodedMessages);

        if (decodedMessages['content'] is List) {
          updateMessages(decodedMessages['content']);
        } else if (decodedMessages['content'] is Map) {
          List<Map<String, dynamic>> messageList = [
            Map<String, dynamic>.from(decodedMessages['content'])
          ];
          updateMessages(messageList);
        } else {
          if (kDebugMode) {
            print("Unexpected format of decodedMessages");
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error loading messages: $e");
      }
      await Future.delayed(const Duration(seconds: 15));
      reloadMessages(userId, recId);
    }
  }

  void updateMessages(List<dynamic> messages) {
    print(messages); // Для перевірки типу
    setState(() {
      _messages.clear();
      List<Map<String, dynamic>> mappedMessages = messages
          .map((message) => Map<String, dynamic>.from(message))
          .toList();
      _messages.addAll(mappedMessages.reversed.toList());
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
            'textcontent': decodedMessage['text'] ?? '',
            'sender': decodedMessage['sender'] ?? 0,
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
        Expanded(
          child: ListView.builder(
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final messageData = _messages[index];

              bool isCurrentUser = messageData['sender'] == userId;

              return Align(
                alignment: isCurrentUser
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: 0.7,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    decoration: BoxDecoration(
                      color: isCurrentUser ? myMessages : thirdMain,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(isCurrentUser ? 12 : 0),
                        topRight: Radius.circular(isCurrentUser ? 0 : 12),
                        bottomLeft: const Radius.circular(12),
                        bottomRight: const Radius.circular(12),
                      ),
                    ),
                    child: Text(
                      messageData['text'] ?? '',
                      style: TextStyle(
                        color: isCurrentUser ? textColorH : textColorH,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
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
    if (_messageController.text.isNotEmpty && widget.recId != 0) {
      final prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('userId');

      // Виклик сервісу для надсилання повідомлення
      await _webSocketService.sendTextMessage(
          userId!, widget.recId, _messageController.text);

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
