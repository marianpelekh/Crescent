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
  final ScrollController _scrollController = ScrollController(); // Додаємо ScrollController
  late final WebSocketService _webSocketService;
  int? userId;

  @override
  void initState() {
    super.initState();
    _webSocketService = WebSocketService(ipAddress);
    if (kDebugMode) {
      print(ipAddress);
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialMessages();
    });
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
    if (kDebugMode) {
      print("Load initial messages " + widget.chatId.toString());
    }
    await reloadMessages(userId!, widget.chatId);
    _scrollToBottom(); // Прокручуємо вниз після завантаження повідомлень
  }

  Future<void> reloadMessages(int userId, int recId) async {
    try {
      if (kDebugMode) {
        print("Trying to reload messages for user $userId to Chat ID: $recId");
      }
      _messages.clear();
      if (mounted) {
        String messages = await _webSocketService.getMessages(userId, recId);
        var decodedMessages = jsonDecode(messages);

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
            print(decodedMessages);
          }
        }
        _scrollToBottom(); // Прокручуємо вниз після оновлення повідомлень
      } else {
        if (kDebugMode) {
          print("Not mounted");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error loading messages: $e");
      }
      await Future.delayed(const Duration(seconds: 15));
      if (mounted) {
        await reloadMessages(userId, recId);
      }
    }
  }

  void updateMessages(List<dynamic> messages) {
    if (mounted) {
      setState(() {
        _messages.clear();
        List<Map<String, dynamic>> mappedMessages = messages
            .map((message) => Map<String, dynamic>.from(message))
            .toList();
        _messages.addAll(mappedMessages.reversed.toList());
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
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
      } else if (decodedMessage['type'] == 'sendtextmessage') {
        setState(() {
          _messages.add({
            'textcontent': decodedMessage['text'] ?? '',
            'sender': decodedMessage['sender'] ?? 0,
          });
          _scrollToBottom(); // Прокручуємо вниз після отримання нового повідомлення
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
          color: fourthMain,
          width: double.infinity,
          child: Row(
            children: [
              if (widget.chatId != 0)
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                    color: textColorH,
                  ),
                ),
              Expanded(
                child: Text(
                  widget.chatName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: textColorH,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            controller: _scrollController, // Використовуємо ScrollController
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final messageData = _messages[index];

              bool isCurrentUser = messageData['sender'] == userId;

              return Align(
                alignment: isCurrentUser
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: 0.45,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    decoration: BoxDecoration(
                      color: isCurrentUser ? myMessages : thirdMain,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(isCurrentUser ? 10 : 0),
                        bottomRight: Radius.circular(isCurrentUser ? 0 : 10),
                        topLeft: const Radius.circular(10),
                        topRight: const Radius.circular(10),
                      ),
                    ),
                    child: Text(
                      messageData['text'] ?? '',
                      style: TextStyle(
                        color: isCurrentUser ? textColorH : textColorH,
                        fontSize: textSmall
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
                    onSubmitted: (value) {
                      _sendMessage();
                    },
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
        )
      ],
    );
  }

  void _sendMessage() async {
    if (_messageController.text.isNotEmpty && widget.chatId != 0) {
      final prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('userId');
      await _webSocketService.sendTextMessage(
          userId!, widget.chatId, _messageController.text);

      setState(() {
        _messages.add({
          'text': _messageController.text,
          'sender': userId,
        });
        _messageController.clear();
        _scrollToBottom();
      });
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
    _scrollController.dispose();
    super.dispose();
  }
}
