class NotificationListModel {
  final bool success;
  final String message;
  final NotificationData? data;

  NotificationListModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory NotificationListModel.fromJson(Map<String, dynamic> json) {
    return NotificationListModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? NotificationData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class NotificationData {
  final List<NotificationItem> notifications;
  final PaginationInfo pagination;

  NotificationData({
    required this.notifications,
    required this.pagination,
  });

  factory NotificationData.fromJson(Map<String, dynamic> json) {
    return NotificationData(
      notifications: (json['notifications'] as List<dynamic>?)
          ?.map((e) => NotificationItem.fromJson(e))
          .toList() ?? [],
      pagination: PaginationInfo.fromJson(json['pagination'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notifications': notifications.map((e) => e.toJson()).toList(),
      'pagination': pagination.toJson(),
    };
  }
}

class NotificationItem {
  final String id;
  final String notificationId;
  final String title;
  final String message;
  final String recipientType;
  final bool isRead;
  final String? readAt;
  final String receivedAt;
  final String createdAt;
  final String? createdBy;

  NotificationItem({
    required this.id,
    required this.notificationId,
    required this.title,
    required this.message,
    required this.recipientType,
    required this.isRead,
    this.readAt,
    required this.receivedAt,
    required this.createdAt,
    this.createdBy,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] ?? '',
      notificationId: json['notificationId'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      recipientType: json['recipientType'] ?? '',
      isRead: json['isRead'] ?? false,
      readAt: json['readAt'],
      receivedAt: json['receivedAt'] ?? '',
      createdAt: json['createdAt'] ?? '',
      createdBy: json['createdBy'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'notificationId': notificationId,
      'title': title,
      'message': message,
      'recipientType': recipientType,
      'isRead': isRead,
      'readAt': readAt,
      'receivedAt': receivedAt,
      'createdAt': createdAt,
      'createdBy': createdBy,
    };
  }

  // Helper method to get truncated message
  String getTruncatedMessage({int maxLength = 100}) {
    if (message.length <= maxLength) return message;
    return '${message.substring(0, maxLength)}...';
  }

  // Helper method to format received time
  String getFormattedTime() {
    try {
      final dateTime = DateTime.parse(receivedAt);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return receivedAt;
    }
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
      itemsPerPage: json['itemsPerPage'] ?? 20,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentPage': currentPage,
      'totalPages': totalPages,
      'totalItems': totalItems,
      'itemsPerPage': itemsPerPage,
    };
  }
}

class UnreadCountModel {
  final bool success;
  final String message;
  final UnreadCountData? data;

  UnreadCountModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory UnreadCountModel.fromJson(Map<String, dynamic> json) {
    return UnreadCountModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? UnreadCountData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class UnreadCountData {
  final int unreadCount;

  UnreadCountData({
    required this.unreadCount,
  });

  factory UnreadCountData.fromJson(Map<String, dynamic> json) {
    return UnreadCountData(
      unreadCount: json['unreadCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'unreadCount': unreadCount,
    };
  }
}

class SingleNotificationModel {
  final bool success;
  final String message;
  final NotificationItem? data;

  SingleNotificationModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory SingleNotificationModel.fromJson(Map<String, dynamic> json) {
    return SingleNotificationModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? NotificationItem.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.toJson(),
    };
  }
} 