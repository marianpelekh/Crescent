part of '../main.dart';

class MainPage extends StatefulWidget {
  final String title;
  final String username;

  const MainPage({super.key, required this.title, required this.username});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool isRightSidebarVisible = true;

  void CloseRightSidebar() {
    setState(() {
      isRightSidebarVisible = false;
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();

    // Очищення даних про авторизацію
    await prefs.remove('loggedIn');
    await prefs.remove('username');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const AuthPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: backgroundColor,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Container(
            child: AppBar(
              elevation: 0,
              backgroundColor: secondMain,
              title: SvgPicture.asset(
                'assets/CrescentLongLogo.svg',
                height: 40,
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
                          padding:
                              EdgeInsets.zero, backgroundColor: Colors.transparent, // Забрати внутрішні відступи
                          minimumSize:
                              Size(40, 40), // Задати мінімальні розміри кнопки
                          shape: CircleBorder(), // Зробити фон кнопки прозорим
                          elevation: 0, // Без тіні
                        ),
                        child: CircleAvatar(
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
        ),
        body: Row(children: [
          const ChatsPanel(),
          const CenterPanel(
            homepage: "chat",
          ),
          RightSidebar(
            isRightSidebarVisible: false,
            closeSidebar: CloseRightSidebar,
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
