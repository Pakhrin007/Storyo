import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:storyo/models/comment_model.dart';
import 'package:storyo/models/story_model.dart';
import 'package:storyo/services/notification_service.dart';

class InteractionService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();

  // ── Likes ──────────────────────────────────────────────────────────────────

  /// Returns whether the current user has liked [storyId].
  Future<bool> isLiked(String storyId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    final doc = await _db
        .collection('stories')
        .doc(storyId)
        .collection('likes')
        .doc(user.uid)
        .get();
    return doc.exists;
  }

  /// Like [storyId]. Updates the story's likeCount and the user's likedStories.
  Future<void> likeStory({
    required String storyId,
    required String storyTitle,
    required String storyCoverUrl,
    required String storyAuthor,
    required String storyGenre,
    required String storyPdfUrl,
    String? authorUid,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final batch = _db.batch();

      batch.set(
        _db
            .collection('stories')
            .doc(storyId)
            .collection('likes')
            .doc(user.uid),
        {
          'userId': user.uid,
          'likedAt': FieldValue.serverTimestamp(),
        },
      );

      batch.update(
        _db.collection('stories').doc(storyId),
        {'likeCount': FieldValue.increment(1)},
      );

      batch.set(
        _db
            .collection('users')
            .doc(user.uid)
            .collection('likedStories')
            .doc(storyId),
        {
          'storyId': storyId,
          'title': storyTitle,
          'coverUrl': storyCoverUrl,
          'author': storyAuthor,
          'genre': storyGenre,
          'pdfUrl': storyPdfUrl,
          'likedAt': FieldValue.serverTimestamp(),
        },
      );

      await batch.commit();

      // Notify the story author about the like.
      if (authorUid != null) {
        _notificationService.notifyLike(
          storyId: storyId,
          storyTitle: storyTitle,
          authorUid: authorUid,
        );
      }
    } catch (e) {
      log('InteractionService.likeStory error: $e');
      rethrow;
    }
  }

  /// Unlike [storyId]. Reverses likeStory.
  Future<void> unlikeStory(String storyId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final batch = _db.batch();

      batch.delete(
        _db
            .collection('stories')
            .doc(storyId)
            .collection('likes')
            .doc(user.uid),
      );

      batch.update(
        _db.collection('stories').doc(storyId),
        {'likeCount': FieldValue.increment(-1)},
      );

      batch.delete(
        _db
            .collection('users')
            .doc(user.uid)
            .collection('likedStories')
            .doc(storyId),
      );

      await batch.commit();
    } catch (e) {
      log('InteractionService.unlikeStory error: $e');
      rethrow;
    }
  }

  /// Returns the current like count for [storyId] from the denormalized field,
  /// falling back to counting the subcollection.
  Future<int> getLikeCount(String storyId) async {
    try {
      final doc = await _db.collection('stories').doc(storyId).get();
      if (doc.exists) {
        final count = doc.data()?['likeCount'];
        if (count is int) return count < 0 ? 0 : count;
      }
      final snap = await _db
          .collection('stories')
          .doc(storyId)
          .collection('likes')
          .get();
      return snap.size;
    } catch (e) {
      log('InteractionService.getLikeCount error: $e');
      return 0;
    }
  }

  /// Returns the current comment count for [storyId] from the denormalized field,
  /// falling back to counting the subcollection.
  Future<int> getCommentCount(String storyId) async {
    try {
      final doc = await _db.collection('stories').doc(storyId).get();
      if (doc.exists) {
        final count = doc.data()?['commentCount'];
        if (count is int) return count < 0 ? 0 : count;
      }
      final snap = await _db
          .collection('stories')
          .doc(storyId)
          .collection('comments')
          .get();
      return snap.size;
    } catch (e) {
      log('InteractionService.getCommentCount error: $e');
      return 0;
    }
  }

  // ── Comments ───────────────────────────────────────────────────────────────

  /// Add a comment to [storyId]. Also mirrors the comment under the user's
  /// `myComments` subcollection for activity display.
  Future<void> addComment({
    required String storyId,
    required String storyTitle,
    required String text,
    String? authorUid,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userName =
        user.displayName?.isNotEmpty == true ? user.displayName! : user.email ?? 'Anonymous';

    try {
      final batch = _db.batch();

      final commentRef = _db
          .collection('stories')
          .doc(storyId)
          .collection('comments')
          .doc();

      batch.set(commentRef, {
        'userId': user.uid,
        'userName': userName,
        'text': text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      batch.update(
        _db.collection('stories').doc(storyId),
        {'commentCount': FieldValue.increment(1)},
      );

      // Mirror in user's activity feed
      batch.set(
        _db
            .collection('users')
            .doc(user.uid)
            .collection('myComments')
            .doc(commentRef.id),
        {
          'commentId': commentRef.id,
          'storyId': storyId,
          'storyTitle': storyTitle,
          'text': text.trim(),
          'createdAt': FieldValue.serverTimestamp(),
        },
      );

      await batch.commit();

      // Notify the story author about the comment.
      if (authorUid != null) {
        _notificationService.notifyComment(
          storyId: storyId,
          storyTitle: storyTitle,
          authorUid: authorUid,
          commentText: text.trim(),
        );
      }
    } catch (e) {
      log('InteractionService.addComment error: $e');
      rethrow;
    }
  }

  /// Delete a comment owned by the current user.
  Future<void> deleteComment({
    required String storyId,
    required String commentId,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final commentDoc = await _db
          .collection('stories')
          .doc(storyId)
          .collection('comments')
          .doc(commentId)
          .get();

      if (!commentDoc.exists) return;
      // Only allow deleting own comments
      if (commentDoc.data()?['userId'] != user.uid) return;

      final batch = _db.batch();

      batch.delete(commentDoc.reference);

      batch.update(
        _db.collection('stories').doc(storyId),
        {'commentCount': FieldValue.increment(-1)},
      );

      batch.delete(
        _db
            .collection('users')
            .doc(user.uid)
            .collection('myComments')
            .doc(commentId),
      );

      await batch.commit();
    } catch (e) {
      log('InteractionService.deleteComment error: $e');
      rethrow;
    }
  }

  /// Real-time stream of comments for [storyId], oldest first.
  Stream<List<CommentModel>> commentsStream(String storyId) {
    return _db
        .collection('stories')
        .doc(storyId)
        .collection('comments')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => CommentModel.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }

  // ── User Activity ──────────────────────────────────────────────────────────

  /// Returns the stories liked by [userId], newest first.
  Future<List<StoryModel>> getLikedStories(String userId) async {
    try {
      final snap = await _db
          .collection('users')
          .doc(userId)
          .collection('likedStories')
          .orderBy('likedAt', descending: true)
          .get();

      return snap.docs.map((doc) {
        final data = doc.data();
        return StoryModel(
          id: doc.id,
          title: data['title'] ?? '',
          genre: data['genre'] ?? '',
          coverUrl: data['coverUrl'] ?? '',
          pdfUrl: data['pdfUrl'] ?? '',
          author: data['author'] ?? '',
        );
      }).toList();
    } catch (e) {
      log('InteractionService.getLikedStories error: $e');
      return [];
    }
  }

  /// Returns the comment activity records for [userId], newest first.
  /// Each map contains: commentId, storyId, storyTitle, text, createdAt.
  Future<List<Map<String, dynamic>>> getUserComments(String userId) async {
    try {
      final snap = await _db
          .collection('users')
          .doc(userId)
          .collection('myComments')
          .orderBy('createdAt', descending: true)
          .get();

      return snap.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    } catch (e) {
      log('InteractionService.getUserComments error: $e');
      return [];
    }
  }
}
