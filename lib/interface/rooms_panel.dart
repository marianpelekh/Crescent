part of '../main.dart';

class RightSidebar extends StatelessWidget {
  final bool isRightSidebarVisible;
  final VoidCallback closeSidebar;

  const RightSidebar({
    super.key,
    required this.isRightSidebarVisible,
    required this.closeSidebar,
  });

  @override
  Widget build(BuildContext context) {
    return isRightSidebarVisible
        ? Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                color: firstMain,
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.only(
                  left: 15, right: 15, bottom: 20, top: 50),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                      child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 16),
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: thirdMain,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          // Обмежує ширину Text
                          child: Text(
                            'Crescent Connect',
                            style: TextStyle(
                              fontSize: 30,
                              color: textColorH,
                            ),
                            overflow: TextOverflow.ellipsis, // Додає три крапки
                          ),
                        ),
                        IconButton(
                          onPressed: closeSidebar,
                          icon: const Icon(Icons.close, color: textColorH),
                        ),
                      ],
                    ),
                  )),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: firstMain,
                              ),
                              child: const Center(
                                child: Text(
                                  'Current room',
                                  style: TextStyle(
                                    fontSize: 26,
                                    color: textColorH,
                                  ),
                                  overflow:
                                      TextOverflow.ellipsis, // Додає три крапки
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    RoomTile(
                                      name: 'Ewan',
                                      info: '(Member)',
                                      imageUrl:
                                          '/home/CatTheBread/Projects/Code/Crescent/crescent/assets/ewan_image.png',
                                    ),
                                    RoomTile(
                                      name: 'Luke',
                                      info: '(Member)',
                                      imageUrl:
                                          '/home/CatTheBread/Projects/Code/Crescent/crescent/assets/luke_image.png',
                                    ),
                                    SizedBox(height: 20),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.all(15),
                              child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 20),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Exit room',
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: textColorH,
                                    ),
                                    overflow: TextOverflow
                                        .ellipsis, // Додає три крапки
                                  ),
                                ),
                              ),
                            ),
                            const Divider(
                              color: textColorS,
                              thickness: 1,
                            ),
                            const Expanded(
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                        "Your friend's rooms",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 26,
                                          color: textColorH,
                                        ),
                                        overflow: TextOverflow
                                            .ellipsis, // Додає три крапки
                                      ),
                                    ),
                                    RoomTile(
                                      name: 'Ewan',
                                      info: 'Minecraft',
                                      imageUrl:
                                          '/home/CatTheBread/Projects/Code/Crescent/crescent/assets/ewan_image.png',
                                    ),
                                    RoomTile(
                                      name: 'Luke',
                                      info: 'Dungeons & Dragons',
                                      imageUrl:
                                          '/home/CatTheBread/Projects/Code/Crescent/crescent/assets/luke_image.png',
                                    ),
                                    RoomTile(
                                      name: 'Jace',
                                      info: 'Valorant',
                                      imageUrl:
                                          '/home/CatTheBread/Projects/Code/Crescent/crescent/assets/jace_image.png',
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                        "Add more friends or create more rooms by yourself.",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: textColorS,
                                        ),
                                        overflow: TextOverflow
                                            .ellipsis, // Додає три крапки
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        : const SizedBox.shrink();
  }
}
