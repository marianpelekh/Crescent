part of '../main.dart';

class ChatsPanel extends StatefulWidget {
  const ChatsPanel({super.key});

  @override
  _ChatsPanelState createState() => _ChatsPanelState();
}

class _ChatsPanelState extends State<ChatsPanel> {
  double _width = 300; //Початкова ширина
  double _dragStartX = 0;
  bool _isResizing = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          color: backgroundColor,
          width: _width,
          child: ListView(
            padding: const EdgeInsets.all(8.0),
            children: const [
              ChatTile(
                  name: 'Harry',
                  message: 'Hello, we haven’t talked for a bit!'),
              ChatTile(name: 'Tom', message: 'You won’t believe this...'),
              ChatTile(name: 'Elliot', message: 'Don’t you wanna turn back...'),
              ChatTile(
                  name: 'Emma',
                  message: 'Sorry, I haven’t seen your message...'),
              ChatTile(name: 'Olivia', message: 'Do you like oranges?'),
              ChatTile(name: 'Matt', message: 'I appreciate your desire...'),
              ChatTile(
                  name: 'Phia',
                  message: 'I found a new game where you play...'),
              ChatTile(
                  name: 'Harry',
                  message: 'Hello, we haven’t talked for a bit!'),
              ChatTile(name: 'Tom', message: 'You won’t believe this...'),
              ChatTile(name: 'Elliot', message: 'Don’t you wanna turn back...'),
              ChatTile(
                  name: 'Emma',
                  message: 'Sorry, I haven’t seen your message...'),
              ChatTile(name: 'Olivia', message: 'Do you like oranges?'),
              ChatTile(name: 'Matt', message: 'I appreciate your desire...'),
              ChatTile(
                  name: 'Phia',
                  message: 'I found a new game where you play...'),
              ChatTile(
                  name: 'Harry',
                  message: 'Hello, we haven’t talked for a bit!'),
              ChatTile(name: 'Tom', message: 'You won’t believe this...'),
              ChatTile(name: 'Elliot', message: 'Don’t you wanna turn back...'),
              ChatTile(
                  name: 'Emma',
                  message: 'Sorry, I haven’t seen your message...'),
              ChatTile(name: 'Olivia', message: 'Do you like oranges?'),
              ChatTile(name: 'Matt', message: 'I appreciate your desire...'),
              ChatTile(
                  name: 'Phia',
                  message: 'I found a new game where you play...'),
            ],
          ),
        ),
        MouseRegion(
          cursor: SystemMouseCursors.resizeLeftRight,
          child: GestureDetector(
            onPanStart: (details) {
              _dragStartX = details.globalPosition.dx;
              setState(() {
                _isResizing = true;
              });
            },
            onPanUpdate: (details) {
              setState(() {
                _width += details.globalPosition.dx - _dragStartX;
                _dragStartX = details.globalPosition.dx;
                _width = _width.clamp(100.0, 600.0);
              });
            },
            onPanEnd: (_) {
              setState(() {
                _isResizing = false;
              });
            },
            child: Container(
              width: 5, // область для ресайзу
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: textColorS,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ChatTile extends StatelessWidget {
  final String name;
  final String message;

  const ChatTile({super.key, required this.name, required this.message});

  @override
Widget build(BuildContext context) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final double availableWidth = constraints.maxWidth - 64; // Мінус ширину аватарки та відступи
      return ListTile(
        leading: CircleAvatar(
          backgroundColor: textColorH,
          child: Text(name[0]),
        ),
        title: availableWidth > 80
            ? Text(name, style: const TextStyle(color: textColorH))
            : null,
        subtitle: availableWidth > 80
            ? Text(
                message,
                style: const TextStyle(color: textColorP),
                overflow: TextOverflow.ellipsis,
              )
            : null,
        onTap: () {
          // Дії при натисканні
        },
      );
    },
  );
}

}
