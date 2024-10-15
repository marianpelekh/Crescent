part of '../main.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.only(left: 10, right: 10, bottom: 20),
          decoration: const BoxDecoration(
            color: firstMain,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      flex: 3,
                      child: Text(
                        "Welcome to Crescent!\nThis is your new secured communication app. We’re pleased that you chose us! Hope, you’ll get the best experience using our app.\nGood luck!",
                        style: TextStyle(
                          fontFamily: 'Jomolhari',
                          height: 1.5,
                          fontSize: textLarge,
                          color: textColorH,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final buttonWidth = (constraints.maxWidth * 0.5)
                                  .clamp(100.0, 250.0);
                              final buttonHeight = (constraints.maxWidth * 0.5)
                                  .clamp(70.0, 100.0);
                              return Container(
                                width: buttonWidth,
                                height: buttonHeight,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Colors.purple, Colors.pink],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: textColorH,
                                    backgroundColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    shadowColor: Colors.transparent,
                                    padding: EdgeInsets.zero,
                                  ),
                                  child: const Center(
                                    child: Text(
                                      "GET STARTED",
                                      style: TextStyle(
                                        color: textColorH,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                const Divider(
                  color: textColorP,
                  thickness: 2,
                ),
                const SizedBox(height: 30),
                const Center(
                    child: Text(
                  "News",
                  style: TextStyle(
                    fontSize: textLarge,
                    color: textColorH,
                  ),
                )),
                const Text(
                  "This is first title\n\n\n\n\n\n\n",
                  style: TextStyle(
                    fontFamily: 'Jomolhari',
                    height: 1.5,
                    fontSize: textLarge,
                    color: textColorH,
                  ),
                  textAlign: TextAlign.left,
                ),
                const Text(
                  "This is second title\n\n\n\n\n\n\n",
                  style: TextStyle(
                    fontFamily: 'Jomolhari',
                    height: 1.5,
                    fontSize: textLarge,
                    color: textColorH,
                  ),
                  textAlign: TextAlign.left,
                ),
                const Text(
                  "This is third title\n\n\n\n\n\n\n",
                  style: TextStyle(
                    fontFamily: 'Jomolhari',
                    height: 1.5,
                    fontSize: textLarge,
                    color: textColorH,
                  ),
                  textAlign: TextAlign.left,
                ),
                const Text(
                  "This is fourth title\n\n\n\n\n\n\n",
                  style: TextStyle(
                    fontFamily: 'Jomolhari',
                    height: 1.5,
                    fontSize: textLarge,
                    color: textColorH,
                  ),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            width: double.infinity,
            height: 50,
            decoration: const BoxDecoration(
              color: secondMain,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
