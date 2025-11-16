import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mood_tracker/core/models/emotion_type.dart';
import 'package:mood_tracker/core/models/timeline_entry.dart';
import 'package:mood_tracker/features/analytics/models/mood_statistics.dart';
import 'package:mood_tracker/features/analytics/models/daily_mood_distribution.dart';

final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  return AnalyticsRepository(FirebaseFirestore.instance);
});

class AnalyticsRepository {
  AnalyticsRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _entriesRef(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('timelineEntries');
  }

  /// 특정 기간의 감정 통계 가져오기
  Future<MoodStatistics> getStatistics({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // 날짜 정규화 (시작일 00:00 ~ 종료일 다음날 00:00)
    final normalizedStart = DateTime(startDate.year, startDate.month, startDate.day);
    final normalizedEnd = DateTime(endDate.year, endDate.month, endDate.day)
        .add(const Duration(days: 1));

    final startTimestamp = Timestamp.fromDate(normalizedStart.toUtc());
    final endTimestamp = Timestamp.fromDate(normalizedEnd.toUtc());

    // Firestore에서 데이터 가져오기
    final snapshot = await _entriesRef(userId)
        .where('timestamp', isGreaterThanOrEqualTo: startTimestamp)
        .where('timestamp', isLessThan: endTimestamp)
        .get();

    if (snapshot.docs.isEmpty) {
      return MoodStatistics.empty(
        startDate: normalizedStart,
        endDate: endDate,
      );
    }

    // 감정별 횟수 계산
    final Map<EmotionType, int> emotionCounts = {};
    for (final doc in snapshot.docs) {
      final entry = TimelineEntry.fromMap(doc.id, doc.data());
      emotionCounts[entry.emotion] = (emotionCounts[entry.emotion] ?? 0) + 1;
    }

    final totalEntries = snapshot.docs.length;

    // 감정별 비율 계산 (0-100)
    final Map<EmotionType, double> emotionPercentages = {};
    for (final entry in emotionCounts.entries) {
      emotionPercentages[entry.key] = (entry.value / totalEntries) * 100;
    }

    // 가장 많은 감정 찾기
    EmotionType? mostFrequent;
    int maxCount = 0;
    for (final entry in emotionCounts.entries) {
      if (entry.value > maxCount) {
        maxCount = entry.value;
        mostFrequent = entry.key;
      }
    }

    return MoodStatistics(
      emotionCounts: emotionCounts,
      emotionPercentages: emotionPercentages,
      mostFrequent: mostFrequent,
      startDate: normalizedStart,
      endDate: endDate,
      totalEntries: totalEntries,
    );
  }

  /// 일별 감정 분포 가져오기
  Future<List<DailyMoodDistribution>> getDailyDistribution({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final normalizedStart = DateTime(startDate.year, startDate.month, startDate.day);
    final normalizedEnd = DateTime(endDate.year, endDate.month, endDate.day)
        .add(const Duration(days: 1));

    final startTimestamp = Timestamp.fromDate(normalizedStart.toUtc());
    final endTimestamp = Timestamp.fromDate(normalizedEnd.toUtc());

    final snapshot = await _entriesRef(userId)
        .where('timestamp', isGreaterThanOrEqualTo: startTimestamp)
        .where('timestamp', isLessThan: endTimestamp)
        .get();

    // 날짜별로 그룹화
    final Map<String, Map<EmotionType, int>> dailyData = {};

    for (final doc in snapshot.docs) {
      final entry = TimelineEntry.fromMap(doc.id, doc.data());
      final dateKey =
          '${entry.timestamp.year}-${entry.timestamp.month.toString().padLeft(2, '0')}-${entry.timestamp.day.toString().padLeft(2, '0')}';

      if (!dailyData.containsKey(dateKey)) {
        dailyData[dateKey] = {};
      }

      final emotionCounts = dailyData[dateKey]!;
      emotionCounts[entry.emotion] = (emotionCounts[entry.emotion] ?? 0) + 1;
    }

    // DailyMoodDistribution 리스트 생성
    final List<DailyMoodDistribution> distributions = [];

    // 시작일부터 종료일까지 모든 날짜 포함 (빈 날짜도)
    DateTime currentDate = normalizedStart;
    while (currentDate.isBefore(normalizedEnd)) {
      final dateKey =
          '${currentDate.year}-${currentDate.month.toString().padLeft(2, '0')}-${currentDate.day.toString().padLeft(2, '0')}';

      final emotionCounts = dailyData[dateKey] ?? {};

      // 가장 많은 감정 찾기
      EmotionType? dominantEmotion;
      int maxCount = 0;
      for (final entry in emotionCounts.entries) {
        if (entry.value > maxCount) {
          maxCount = entry.value;
          dominantEmotion = entry.key;
        }
      }

      distributions.add(DailyMoodDistribution(
        date: currentDate,
        emotionCounts: emotionCounts,
        dominantEmotion: dominantEmotion,
      ));

      currentDate = currentDate.add(const Duration(days: 1));
    }

    return distributions;
  }
}
