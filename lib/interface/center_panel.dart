part of '../main.dart';
class CenterPanel extends StatefulWidget {
  final String homepage;
  final Function(String)? onUpdateHomepage;

  const CenterPanel({super.key, required this.homepage, this.onUpdateHomepage});

  @override
  CenterPanelState createState() => CenterPanelState();
}

class CenterPanelState extends State<CenterPanel> {
  late String homepage;

  @override
  void initState() {
    super.initState();
    homepage = widget.homepage;
  }

  void updateHomepage(String newHomepage) {
    setState(() {
      homepage = newHomepage;
    });
  }

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
                  ? HomePage(adjustedFontSize: adjustedFontSize)
                  : const ChatPage(
                      chatName: 'Choose chat to start...', recId: 2),
            ),
          );
        },
      ),
    );
  }
}
