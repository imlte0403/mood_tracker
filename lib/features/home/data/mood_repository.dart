import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mood_tracker/core/models/emotion_type.dart';
import 'package:mood_tracker/core/models/timeline_entry.dart';
final moodRepositoryProvider = Provider<MoodRepository>((ref) {
  return MoodRepository(FirebaseFirestore.instance);
});

class MoodRepository {
  MoodRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _entriesRef(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('timelineEntries');
  }

  Stream<List<TimelineEntry>> watchEntries({
    required String userId,
    required DateTime date,
  }) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return watchEntriesInRange(userId: userId, start: start, end: end);
  }

  Stream<List<TimelineEntry>> watchEntriesInRange({
    required String userId,
    required DateTime start,
    required DateTime end,
  }) {
    final normalizedStart = DateTime(start.year, start.month, start.day);
    final normalizedEnd = DateTime(end.year, end.month, end.day);

    final startTimestamp = Timestamp.fromDate(normalizedStart.toUtc());
    final endTimestamp = Timestamp.fromDate(normalizedEnd.toUtc());

    return _entriesRef(userId)
        .where('timestamp', isGreaterThanOrEqualTo: startTimestamp)
        .where('timestamp', isLessThan: endTimestamp)
        .orderBy('timestamp')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => TimelineEntry.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<TimelineEntry> createEntry({
    required String userId,
    required DateTime timestamp,
    required EmotionType emotion,
    String? message,
  }) async {
    final doc = _entriesRef(userId).doc();
    final entry = TimelineEntry(
      id: doc.id,
      timestamp: timestamp,
      emotion: emotion,
      message: message,
      userId: userId,
    );
    await doc.set(entry.toMap());
    return entry;
  }

  Future<void> updateEntry(TimelineEntry entry) {
    return _entriesRef(entry.userId).doc(entry.id).update(entry.toMap());
  }

  Future<void> deleteEntry({required String userId, required String entryId}) {
    return _entriesRef(userId).doc(entryId).delete();
  }
}
