import 'package:cloud_firestore/cloud_firestore.dart';

/// The kind of event that triggered the notification.
enum NotificationType { like, comment, follow }

class NotificationModel {
  final String id;
  final NotificationType type;
  final String fromUid;
  final String fromName;
  final String? storyId;
  final String? storyTitle;
  final String message;
  final DateTime createdAt;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.type,
    required this.fromUid,
    required this.fromName,
    this.storyId,
    this.storyTitle,
    required this.message,
    required this.createdAt,
    this.isRead = false,
  });

  factory NotificationModel.fromFirestore(
    Map<String, dynamic> data,
    String id,
  ) {
    return NotificationModel(
      id: id,
      type: _parseType(data['type'] as String?),
      fromUid: data['fromUid'] ?? '',
      fromName: data['fromName'] ?? '',
      storyId: data['storyId'],
      storyTitle: data['storyTitle'],
      message: data['message'] ?? '',
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: data['isRead'] == true,
    );
  }

  static NotificationType _parseType(String? value) {
    switch (value) {
      case 'like':
        return NotificationType.like;
      case 'comment':
        return NotificationType.comment;
      case 'follow':
        return NotificationType.follow;
      default:
        return NotificationType.like;
    }
  }

  static String typeToString(NotificationType type) {
    switch (type) {
      case NotificationType.like:
        return 'like';
      case NotificationType.comment:
        return 'comment';
      case NotificationType.follow:
        return 'follow';
    }
  }
}
