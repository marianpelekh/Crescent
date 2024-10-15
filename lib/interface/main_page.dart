part of '../main.dart';

class MainPage extends StatefulWidget {
  final String title;
  final String username;

  const MainPage({super.key, required this.title, required this.username});

  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  final GlobalKey<CenterPanelState> centerPanelKey =
      GlobalKey<CenterPanelState>();
  bool isRightSidebarVisible = true;
  String homepage = "home";

  void closeRightSidebar() {
    setState(() {
      isRightSidebarVisible = false;
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();

    //Дописати логіку видаення токена з пристрою користувача
    // late WebSocketChannel _channel;
    // _channel = IOWebSocketChannel.connect(ipAddress);
    // final logout_mess = jsonEncode({
    //   'type': 'auth',
    //   'userId': username,
    //   'sessionId': sessionId
    // });
    await prefs.remove('loggedIn');
    await prefs.remove('username');
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const AuthPage(),
        ),
      );
    }
  }

  void _updateHomepage(String newHomepage) {
    setState(() {
      homepage = newHomepage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: backgroundColor,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: AppBar(
            elevation: 0,
            backgroundColor: secondMain,
            title: GestureDetector(
              onTap: () {
                setState(() {
                  centerPanelKey.currentState?.updateHomepageCP('home');
                });
              },
              child: SvgPicture.asset(
                'assets/CrescentLongLogo.svg',
                height: 40,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Row(
                  children: [
                    Text(
                      widget.username,
                      style: const TextStyle(
                        fontSize: 20,
                        color: textColorH,
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _logout,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor: Colors.transparent,
                        minimumSize: const Size(40, 40),
                        shape: const CircleBorder(),
                        elevation: 0, // Без тіні
                      ),
                      child: const CircleAvatar(
                        backgroundImage: AssetImage(
                          '/home/CatTheBread/Projects/Code/Crescent/crescent/assets/avatar.png',
                        ),
                        radius: 20, // Розмір аватара
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: Row(children: [
          ChatsPanel(onUpdateHomepage: (updateHomepage) {
            if (kDebugMode) {
              print("Update homepage");
            }
            setState(() {
              centerPanelKey.currentState?.updateHomepageCP('chat');
            });
          }),
          CenterPanel(
            key: centerPanelKey,
            receiverName: "Choose a chat to start",
            receiverId: 3,
            homepage: "home",
          ),
          RightSidebar(
            isRightSidebarVisible: false,
            closeSidebar: closeRightSidebar,
          )
        ]));
  }
}

class RoomTile extends StatelessWidget {
  final String name;
  final String info;
  final String imageUrl;

  const RoomTile(
      {super.key,
      required this.name,
      required this.info,
      required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: AssetImage(imageUrl),
      ),
      title: Text(name, style: const TextStyle(color: textColorH)),
      subtitle: Text(info, style: const TextStyle(color: textColorP)),
    );
  }
}
