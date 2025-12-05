import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mood_tracker/core/models/timeline_entry.dart';

final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  return SearchRepository(FirebaseFirestore.instance);
});

class SearchRepository {
  SearchRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _entriesRef(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('timelineEntries');
  }

  Future<List<TimelineEntry>> fetchEntries({required String userId}) async {
    final snapshot = await _entriesRef(userId)
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => TimelineEntry.fromMap(doc.id, doc.data()))
        .toList();
  }
}
