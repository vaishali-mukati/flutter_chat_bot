class Message {
  String messageId;
  String chatId;
  Role role;
  StringBuffer message;
  List<String> imageUrls;
  DateTime timeSent;

  Message(
      {required this.messageId,
      required this.chatId,
      required this.role,
      required this.message,
      required this.imageUrls,
      required this.timeSent});

  //toMap methood

  Map<String, dynamic> toMap() {
    return {
      'messageId': messageId,
      'chatId': chatId,
      'role': role,
      'message': message.toString(),
      'imageUrls': imageUrls,
      'timeSent': timeSent.toIso8601String(),
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
        messageId: map['messageId'],
        chatId: map['chatId'],
        role: Role.values[map['role']],
        message: StringBuffer(map['message']),
        imageUrls: List<String>.from(map['imageUrls']),
        timeSent: DateTime.parse(map['timeSent']));
  }

  Message copyWith({
    String? messageId,
    String? chatId,
    Role? role,
    StringBuffer? message,
    List<String>? imageUrls,
    DateTime? time,
  }) {
    return Message(
        messageId: messageId ?? this.messageId,
        chatId: chatId ?? this.chatId,
        role: role ?? this.role,
        message: message ?? this.message,
        imageUrls: imageUrls ?? this.imageUrls,
        timeSent: timeSent);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Message && other.messageId == messageId;
  }

  @override
  // TODO: implement hashCode
  int get hashCode {
    return messageId.hashCode;
  }
}

enum Role {
  user,
  assistant,
}
