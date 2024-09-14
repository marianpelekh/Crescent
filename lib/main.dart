import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_inner_shadow/flutter_inner_shadow.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'classes/message.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http; // Для роботи з HTTP-запитами

import 'server/server.dart';

part 'interface/chats_panel.dart';
part 'interface/rooms_panel.dart';
part 'interface/center_panel.dart';

part './interface/home_page.dart';
part './interface/chat_page.dart';

part 'constants.dart';

void main() {
  runApp(const CrescentApp());
}

class CrescentApp extends StatelessWidget {
  const CrescentApp({super.key});

  @override
  Widget build(BuildContext context) {
    // double unitHeightValue = MediaQuery.of(context).size.height * 0.01;
    // double unitWidthValue = MediaQuery.of(context).size.width * 0.01;
        double multiplier = 75;
        // double multiplier = 50;

        return LayoutBuilder(
          builder: (context, constraints) {
            double fontSize = sqrt(constraints.maxHeight * constraints.maxWidth) / multiplier;
            double minFontSize = 14.0;
            double maxFontSize = 26.0;
        return MaterialApp(
          title: 'Crescent',
          theme: ThemeData(
            fontFamily: 'JosefinSans',
            textTheme: TextTheme(
              bodyLarge: TextStyle(
                fontSize: fontSize.clamp(minFontSize, maxFontSize),
              ),
              bodyMedium: TextStyle(
                fontSize: fontSize.clamp(minFontSize * 0.7, maxFontSize * 0.7),
              ),
              bodySmall: TextStyle(
                fontSize: fontSize.clamp(minFontSize * 0.5, maxFontSize * 0.5),
              ),
            ),
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 0, 0, 0),
              primary: const Color.fromARGB(255, 255, 255, 255),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color.fromARGB(255, 32, 32, 32),
              foregroundColor: Color.fromARGB(255, 232, 232, 232),
            ),
          ),
          home: const MainPage(title: 'Crescent'),
        );
      },
    );
  }
}

class MainPage extends StatefulWidget {
  final String title;

  const MainPage({super.key, required this.title});

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
              actions: const [
                Padding(
                  padding: EdgeInsets.only(right: 16.0),
                  child: Row(
                    children: [
                      Text(
                        '[Username]',
                        style: TextStyle(
                          fontSize: 20,
                          color: textColorH,
                        ),
                      ),
                      SizedBox(width: 10),
                      CircleAvatar(
                        backgroundImage: AssetImage(
                            '/home/CatTheBread/Projects/Code/Crescent/crescent/assets/avatar.png'),
                        radius: 20,
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
            isRightSidebarVisible: true,
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
