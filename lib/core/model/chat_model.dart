class ChatModel {
  final bool success;
  final String message;
  final List<Conversation> data;

  ChatModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => Conversation.fromJson(e))
          .toList() ?? [],
    );
  }
}

class Conversation {
  final String conversationId;
  final Message lastMessage;
  final int messageCount;
  final int unreadCount;
  final ChatUser otherUser;

  Conversation({
    required this.conversationId,
    required this.lastMessage,
    required this.messageCount,
    required this.unreadCount,
    required this.otherUser,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      conversationId: json['conversationId'] ?? '',
      lastMessage: Message.fromJson(json['lastMessage'] ?? {}),
      messageCount: json['messageCount'] ?? 0,
      unreadCount: json['unreadCount'] ?? 0,
      otherUser: ChatUser.fromJson(json['otherUser'] ?? {}),
    );
  }
}

class Message {
  final String id;
  final String senderId;
  final String receiverId;
  final String message;
  final DateTime timestamp;
  final String status; // 'sent' or 'seen'
  final String conversationId;
  final String senderType;
  final String receiverType;

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.timestamp,
    required this.status,
    required this.conversationId,
    required this.senderType,
    required this.receiverType,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['_id'] ?? '',
      senderId: json['senderId'] ?? '',
      receiverId: json['receiverId'] ?? '',
      message: json['message'] ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      status: json['status'] ?? 'sent',
      conversationId: json['conversationId'] ?? '',
      senderType: json['senderType'] ?? '',
      receiverType: json['receiverType'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'status': status,
      'conversationId': conversationId,
      'senderType': senderType,
      'receiverType': receiverType,
    };
  }
}

class ChatUser {
  final String id;
  final String name;
  final String? email;
  final String? phoneNo;

  ChatUser({
    required this.id,
    required this.name,
    this.email,
    this.phoneNo,
  });

  factory ChatUser.fromJson(Map<String, dynamic> json) {
    return ChatUser(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'],
      phoneNo: json['phoneNo'],
    );
  }
}

class ConversationMessagesModel {
  final bool success;
  final ConversationMessagesData data;

  ConversationMessagesModel({
    required this.success,
    required this.data,
  });

  factory ConversationMessagesModel.fromJson(Map<String, dynamic> json) {
    return ConversationMessagesModel(
      success: json['success'] ?? false,
      data: ConversationMessagesData.fromJson(json['data'] ?? {}),
    );
  }
}

class ConversationMessagesData {
  final List<Message> messages;
  final PaginationInfo pagination;

  ConversationMessagesData({
    required this.messages,
    required this.pagination,
  });

  factory ConversationMessagesData.fromJson(Map<String, dynamic> json) {
    return ConversationMessagesData(
      messages: (json['messages'] as List<dynamic>?)
          ?.map((e) => Message.fromJson(e))
          .toList() ?? [],
      pagination: PaginationInfo.fromJson(json['pagination'] ?? {}),
    );
  }
}

class PaginationInfo {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;

  PaginationInfo({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      currentPage: json['currentPage'] ?? 1,
      totalPages: json['totalPages'] ?? 1,
      totalItems: json['totalItems'] ?? 0,
      itemsPerPage: json['itemsPerPage'] ?? 50,
    );
  }
}

class ChatUnreadCountModel {
  final bool success;
  final ChatUnreadCountData data;

  ChatUnreadCountModel({
    required this.success,
    required this.data,
  });

  factory ChatUnreadCountModel.fromJson(Map<String, dynamic> json) {
    return ChatUnreadCountModel(
      success: json['success'] ?? false,
      data: ChatUnreadCountData.fromJson(json['data'] ?? {}),
    );
  }
}

class ChatUnreadCountData {
  final int unreadCount;

  ChatUnreadCountData({
    required this.unreadCount,
  });

  factory ChatUnreadCountData.fromJson(Map<String, dynamic> json) {
    return ChatUnreadCountData(
      unreadCount: json['unreadCount'] ?? 0,
    );
  }
} 