import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReadingProgressService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> saveContinueReading({
    required String storyId,
    required String title,
    required String authorName,
    required String coverUrl,
    required String pdfUrl,
    required String genre,
    int currentPage = 1,
    int totalPages = 0,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('continueReading')
        .doc(storyId)
        .set({
          'id': storyId,
          'storyId': storyId,
          'title': title,
          'authorName': authorName,
          'coverUrl': coverUrl,
          'pdfUrl': pdfUrl,
          'genre': genre,
          'currentPage': currentPage,
          'totalPages': totalPages,
          'lastReadAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }

  Future<void> updateReadingProgress({
    required String storyId,
    required int currentPage,
    required int totalPages,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('continueReading')
        .doc(storyId)
        .set({
          'currentPage': currentPage,
          'totalPages': totalPages,
          'lastReadAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>?> getReadingProgress(String storyId) async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('continueReading')
        .doc(storyId)
        .get();

    return doc.data();
  }

  Future<void> removeContinueReading(String storyId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('continueReading')
        .doc(storyId)
        .delete();
  }
}
