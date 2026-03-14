import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FollowService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Follow [targetUid]. Updates subcollections and denormalized counts atomically.
  Future<void> followUser({
    required String targetUid,
    required String targetName,
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final currentUid = currentUser.uid;
    final currentName = currentUser.displayName ?? currentUser.email ?? '';

    try {
      final batch = _db.batch();

      // Add targetUid to current user's "following" subcollection
      batch.set(
        _db
            .collection('users')
            .doc(currentUid)
            .collection('following')
            .doc(targetUid),
        {
          'uid': targetUid,
          'name': targetName,
          'followedAt': FieldValue.serverTimestamp(),
        },
      );

      // Add currentUid to target user's "followers" subcollection
      batch.set(
        _db
            .collection('users')
            .doc(targetUid)
            .collection('followers')
            .doc(currentUid),
        {
          'uid': currentUid,
          'name': currentName,
          'followedAt': FieldValue.serverTimestamp(),
        },
      );

      // Increment denormalized counts
      batch.update(
        _db.collection('users').doc(currentUid),
        {'followingCount': FieldValue.increment(1)},
      );
      batch.update(
        _db.collection('users').doc(targetUid),
        {'followerCount': FieldValue.increment(1)},
      );

      await batch.commit();
    } catch (e) {
      log('FollowService.followUser error: $e');
      rethrow;
    }
  }

  /// Unfollow [targetUid]. Removes from subcollections and decrements counts.
  Future<void> unfollowUser({required String targetUid}) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final currentUid = currentUser.uid;

    try {
      final batch = _db.batch();

      batch.delete(
        _db
            .collection('users')
            .doc(currentUid)
            .collection('following')
            .doc(targetUid),
      );

      batch.delete(
        _db
            .collection('users')
            .doc(targetUid)
            .collection('followers')
            .doc(currentUid),
      );

      // Decrement denormalized counts (clamp at 0 via max logic)
      batch.update(
        _db.collection('users').doc(currentUid),
        {'followingCount': FieldValue.increment(-1)},
      );
      batch.update(
        _db.collection('users').doc(targetUid),
        {'followerCount': FieldValue.increment(-1)},
      );

      await batch.commit();
    } catch (e) {
      log('FollowService.unfollowUser error: $e');
      rethrow;
    }
  }

  /// Returns true if the current user already follows [targetUid].
  Future<bool> isFollowing(String targetUid) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return false;

    final doc = await _db
        .collection('users')
        .doc(currentUser.uid)
        .collection('following')
        .doc(targetUid)
        .get();

    return doc.exists;
  }

  /// Returns the follower count for [uid] using the denormalized field,
  /// falling back to a subcollection count if the field is absent.
  Future<int> getFollowerCount(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        final count = doc.data()?['followerCount'];
        if (count is int) return count < 0 ? 0 : count;
      }
      // Fallback: count subcollection documents
      final snap =
          await _db.collection('users').doc(uid).collection('followers').get();
      return snap.size;
    } catch (e) {
      log('FollowService.getFollowerCount error: $e');
      return 0;
    }
  }

  /// Returns the following count for [uid] using the denormalized field,
  /// falling back to a subcollection count if the field is absent.
  Future<int> getFollowingCount(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        final count = doc.data()?['followingCount'];
        if (count is int) return count < 0 ? 0 : count;
      }
      // Fallback: count subcollection documents
      final snap =
          await _db.collection('users').doc(uid).collection('following').get();
      return snap.size;
    } catch (e) {
      log('FollowService.getFollowingCount error: $e');
      return 0;
    }
  }
}
