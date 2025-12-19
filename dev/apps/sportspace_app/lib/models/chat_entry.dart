class ChatMessageItem {
  final String sender;
  final String message;
  final String timestamp;

  ChatMessageItem({
    required this.sender,
    required this.message,
    required this.timestamp,
  });

  factory ChatMessageItem.fromJson(Map<String, dynamic> json) {
    return ChatMessageItem(
      sender: json['sender'],
      message: json['message'],
      timestamp: json['timestamp'],
    );
  }
}