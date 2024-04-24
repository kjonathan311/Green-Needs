class Message {
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime sentTime;
  final MessageType messageType;
  final String transactionId;

  const Message({
    required this.senderId,
    required this.receiverId,
    required this.sentTime,
    required this.content,
    required this.messageType,
    required this.transactionId,
  });

  factory Message.fromJson(Map<String, dynamic> json) =>
      Message(
        receiverId: json['receiverId'],
        senderId: json['senderId'],
        sentTime: json['sentTime'].toDate(),
        content: json['content'],
        messageType:
        MessageType.fromJson(json['messageType']),
        transactionId:json['transactionId']
      );

  Map<String, dynamic> toJson() => {
    'receiverId': receiverId,
    'senderId': senderId,
    'sentTime': sentTime,
    'content': content,
    'messageType': messageType.toJson(),
    'transactionId':transactionId
  };
}

enum MessageType {
  text,
  image;

  String toJson() => name;

  factory MessageType.fromJson(String json) =>
      values.byName(json);
}