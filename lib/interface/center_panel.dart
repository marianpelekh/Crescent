part of '../main.dart';

class CenterPanel extends StatelessWidget {
  final String homepage;

  const CenterPanel({super.key, required this.homepage});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 5,
      child: LayoutBuilder(
        builder: (context, constraints) {
          double fontSize = constraints.maxWidth / 30;
          double minFontSize = 14.0;
          double maxFontSize = 30.0;
          double adjustedFontSize = fontSize.clamp(minFontSize, maxFontSize);

          return Container(
            margin: const EdgeInsets.only(
              bottom: 20,
              right: 10,
              left: 10,
            ),
            decoration: const BoxDecoration(
              color: firstMain,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
              child: homepage == "home"
                  ? HomePage(
                      adjustedFontSize: adjustedFontSize) // Викликає компонент для home
                  : const ChatPage(chatName: 'Choose chat to start...', chatId: 1,), // Викликає компонент для чату
            ),
          );
        },
      ),
    );
  }
}
