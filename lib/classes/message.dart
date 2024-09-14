class Message {
  final int sender;
  final int receiver;
  final String content;
  final String timestamp;

  Message({
    required this.sender,
    required this.receiver,
    required this.content,
    required this.timestamp,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      sender: json['sender'],
      receiver: json['receiver'],
      content: json['content'],
      timestamp: json['timestamp'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sender': sender,
      'receiver': receiver,
      'message': content,
      'timestamp': timestamp,
    };
  }
}
