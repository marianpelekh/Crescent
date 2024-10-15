part of '../main.dart';

late WebSocketService _webSocketService;

class ChatsPanel extends StatefulWidget {
  final Function(String) onUpdateHomepage;

  const ChatsPanel({super.key, required this.onUpdateHomepage});
  @override
  ChatsPanelState createState() => ChatsPanelState();
}

class ChatsPanelState extends State<ChatsPanel> {
  double _width = 300;
  double _dragStartX = 0;

  @override
  void initState() {
    super.initState();
    _webSocketService = WebSocketService(ipAddress);

    _webSocketService.broadcastStream.listen((message) {
      if (kDebugMode) {
        print("Recieved message in ChatsPanel: $message");
      }
    }, onError: (error) {
      if (kDebugMode) {
        print("Error: $error");
      }
    });
  }

  @override
  void dispose() {
    _webSocketService.closeConnection();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          color: backgroundColor,
          width: _width,
          child: FutureBuilder<List<ChatTile>>(
            future: _webSocketService.getChats(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                if (kDebugMode) {
                  print("Loading chats...");
                }
                return const Center(child: Text("Loading chats..."));
              } else if (snapshot.hasError) {
                if (kDebugMode) {
                  print("Error loading chats...");
                }
                return const Center(child: Text('Error loading chats'));
              } else if (snapshot.hasData) {
                if (kDebugMode) {
                  print("Chats have been loaded...");
                  print(snapshot.data!);
                }
                return ListView(
                    children: snapshot.data!.map((chatTile) {
                  return GestureDetector(
                    onTap: () {
                      if (kDebugMode) {
                        print('Tapped chat tile');
                      }
                      widget.onUpdateHomepage('chat');
                    },
                    child: chatTile,
                  );
                }).toList());
              } else {
                return const Center(child: Text('No chats available'));
              }
            },
          ),
        ),
        MouseRegion(
          cursor: SystemMouseCursors.resizeLeftRight,
          child: GestureDetector(
            onPanStart: (details) {
              _dragStartX = details.globalPosition.dx;
              setState(() {});
            },
            onPanUpdate: (details) {
              setState(() {
                _width += details.globalPosition.dx - _dragStartX;
                _dragStartX = details.globalPosition.dx;
                _width = _width.clamp(100.0, 600.0);
              });
            },
            onPanEnd: (_) {
              setState(() {});
            },
            child: Container(
              width: 20,
              height: 50,
              decoration: const BoxDecoration(
                color: Colors.transparent,
              ),
              alignment: Alignment.center,
              child: Container(
                width: 5,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: textColorS,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> buildChatTiles(List<ChatTile> chats) {
    return chats.map((chat) {
      return ChatTile(
        key: ValueKey(chat.chatId),
        imageName: chat.imageName,
        name: chat.name,
        message: chat.message,
        chatId: chat.chatId,
        usId: chat.usId,
        onTap: () {
          if (kDebugMode) {
            print("ChatsPanelState updateHomepage call");
          }
          widget.onUpdateHomepage('chat');
          CrescentApp c = const CrescentApp();
          Future<int?> userId = c.getUserId();
          ChatPageState chatState = ChatPageState();
          chatState.reloadMessages(userId as int, chat.usId);
        },
      );
    }).toList();
  }
}

class ChatTile extends StatefulWidget {
  final String imageName;
  final String name;
  final String message;
  final int chatId;
  final int usId;
  final VoidCallback? onTap;

  const ChatTile(
      {super.key,
      required this.imageName,
      required this.name,
      required this.message,
      required this.chatId,
      required this.usId,
      this.onTap});

  @override
  ChatTileState createState() => ChatTileState();
}

class ChatTileState extends State<ChatTile> {
  // late Future<String?> _imageUrl;

  @override
  void initState() {
    super.initState();
    // _loadImage();
  }

  void _loadImage() {
    setState(() {
      // _imageUrl = _webSocketService.getImage(widget.imageName);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      // future: _imageUrl,
      future: null,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return const Icon(Icons.error);
        } else if (snapshot.hasData && snapshot.data != null) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: textColorH,
              child: ClipOval(
                child: snapshot.data!.startsWith('http')
                    ? Image.network(
                        snapshot.data!,
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Text(widget.name[0]);
                        },
                      )
                    : Image.memory(
                        base64Decode(snapshot.data!),
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            title: Text(widget.name, style: const TextStyle(color: textColorH)),
            subtitle: Text(
              widget.message,
              style: const TextStyle(color: textColorP),
              overflow: TextOverflow.ellipsis,
            ),
            onTap: widget.onTap,
          );
        } else {
          return ListTile(
              leading: CircleAvatar(
                child: Text(widget.name[0]),
              ),
              title: Text(widget.name,
                  style:
                      const TextStyle(color: textColorH, fontSize: textMedium)),
              subtitle: Text(
                widget.message,
                style: const TextStyle(color: textColorP, fontSize: textSmall),
                overflow: TextOverflow.ellipsis,
              ),
              onTap: widget.onTap);
        }
      },
    );
  }
}
