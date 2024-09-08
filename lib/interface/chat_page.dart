part of '../main.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(8.0),
            child: ListView.builder(
              // Розміщення повідомлень тут
              itemCount: 10, // Змініть на вашу кількість повідомлень
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Message $index'), // Змініть на текст повідомлення
                );
              },
            ),
          ),
        ),
        Container(
          height: 50,
          decoration: const BoxDecoration(
            color: secondMain,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
          ),
          child: const Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: TextField(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: secondMain,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                        borderSide: BorderSide.none,
                      ),
                      hintText: 'Write a message...',
                      hintStyle: TextStyle(
                        fontSize: 18,
                        color: textColorS,
                      ),
                    ),
                    style: TextStyle(
                      fontSize: 20,
                      color: textColorH,
                    ),
                  ),
                ),
              ),
              IconButton(
                onPressed: runShelfServer,
                icon: Icon(Icons.send),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
