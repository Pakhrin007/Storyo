import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:storyo/models/notification_model.dart';

class NotificationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── FCM TOKEN ──────────────────────────────────────────────────────────────

  /// Request notification permission and save the FCM token to Firestore
  /// so the backend (e.g. Cloud Functions) can send push notifications later.
  Future<void> initFCMToken() async {
    try {
      final messaging = FirebaseMessaging.instance;

      // Request permission (required on iOS / web).
      await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      final token = await messaging.getToken();
      if (token != null) {
        await _saveToken(token);
      }

      // Listen for token refresh.
      messaging.onTokenRefresh.listen(_saveToken);
    } catch (e) {
      log('NotificationService.initFCMToken error: $e');
    }
  }

  Future<void> _saveToken(String token) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      await _db.collection('users').doc(user.uid).set(
        {'fcmToken': token},
        SetOptions(merge: true),
      );
    } catch (e) {
      log('NotificationService._saveToken error: $e');
    }
  }

  // ── CREATE NOTIFICATIONS ──────────────────────────────────────────────────

  /// Create a notification document under the target user's subcollection.
  Future<void> _createNotification({
    required String targetUid,
    required NotificationType type,
    required String message,
    String? storyId,
    String? storyTitle,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Don't notify yourself.
    if (user.uid == targetUid) return;

    final fromName = user.displayName?.isNotEmpty == true
        ? user.displayName!
        : user.email ?? 'Someone';

    try {
      await _db
          .collection('users')
          .doc(targetUid)
          .collection('notifications')
          .add({
        'type': NotificationModel.typeToString(type),
        'fromUid': user.uid,
        'fromName': fromName,
        'storyId': storyId,
        'storyTitle': storyTitle,
        'message': message,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Notification failures should not break core actions.
      log('NotificationService._createNotification error: $e');
    }
  }

  /// Notify the story author that someone liked their story.
  Future<void> notifyLike({
    required String storyId,
    required String storyTitle,
    required String authorUid,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final name = user.displayName?.isNotEmpty == true
        ? user.displayName!
        : user.email ?? 'Someone';

    await _createNotification(
      targetUid: authorUid,
      type: NotificationType.like,
      message: '$name liked your story "$storyTitle"',
      storyId: storyId,
      storyTitle: storyTitle,
    );
  }

  /// Notify the story author that someone commented on their story.
  Future<void> notifyComment({
    required String storyId,
    required String storyTitle,
    required String authorUid,
    required String commentText,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final name = user.displayName?.isNotEmpty == true
        ? user.displayName!
        : user.email ?? 'Someone';

    await _createNotification(
      targetUid: authorUid,
      type: NotificationType.comment,
      message: '$name commented on "$storyTitle": $commentText',
      storyId: storyId,
      storyTitle: storyTitle,
    );
  }

  /// Notify a user that someone started following them.
  Future<void> notifyFollow({required String targetUid}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final name = user.displayName?.isNotEmpty == true
        ? user.displayName!
        : user.email ?? 'Someone';

    await _createNotification(
      targetUid: targetUid,
      type: NotificationType.follow,
      message: '$name started following you',
    );
  }

  // ── READ NOTIFICATIONS ────────────────────────────────────────────────────

  /// Real‑time stream of the current user's notifications, newest first.
  Stream<List<NotificationModel>> notificationsStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();

    return _db
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) =>
                  NotificationModel.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }

  /// Stream that emits the count of unread notifications.
  Stream<int> unreadCountStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();

    return _db
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snap) => snap.size);
  }

  /// Mark a single notification as read.
  Future<void> markAsRead(String notificationId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      await _db
          .collection('users')
          .doc(user.uid)
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      log('NotificationService.markAsRead error: $e');
    }
  }

  /// Mark all notifications as read.
  Future<void> markAllAsRead() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final snap = await _db
          .collection('users')
          .doc(user.uid)
          .collection('notifications')
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _db.batch();
      for (final doc in snap.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      log('NotificationService.markAllAsRead error: $e');
    }
  }
}
