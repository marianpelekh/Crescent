part of '../main.dart';

class CenterPanel extends StatefulWidget {
  final String homepage;
  final String receiverName;
  final int receiverId;
  final Function(String)? onUpdateHomepage;

  const CenterPanel({super.key, required this.homepage, required this.receiverName, required this.receiverId, this.onUpdateHomepage});

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

  void updateHomepageCP(String newHomepage) {
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
                    ? const HomePage()
                    : ChatPage(
                        chatName: widget.receiverName,
                        recId: widget.receiverId,
                      ),
              ));
        },
      ),
    );
  }
}
