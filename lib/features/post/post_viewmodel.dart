import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mood_tracker/core/models/emotion_type.dart';
import 'package:mood_tracker/core/models/timeline_entry.dart';
import 'package:mood_tracker/core/utils/firebase_error_handler.dart';

import 'package:mood_tracker/features/home/data/mood_repository.dart';
import 'package:mood_tracker/features/post/model/mood_shape.dart';

// 슬라이더 값을 관리하는 Provider (초기 값: 3.5)
final moodSliderValueProvider = StateProvider.autoDispose<double>((ref) => 3.5);

// 현재 감정 데이터를 제공하는 Provider
// 슬라이더 값을 기반으로 MoodShapeEngine에서 감정 정보를 가져옴
final currentMoodDataProvider = Provider.autoDispose<MoodShapeSnapshot>((ref) {
  final value = ref.watch(moodSliderValueProvider);
  return MoodShapeEngine.resolve(value);
});

// 감정 엔트리 폼 상태를 관리하는 Provider
final moodEntryFormProvider =
    StateNotifierProvider.autoDispose<MoodEntryFormNotifier, MoodEntryForm>((
      ref,
    ) {
      return MoodEntryFormNotifier(ref);
    });

// 감정 기록 모델 클래스
class MoodEntryForm {
  const MoodEntryForm({
    required this.timestamp,
    required this.emotion,
    required this.message,
    required this.isSubmitting,
    required this.isSuccess,
    required this.isValid,
    this.entryId,
    this.userId,
    this.errorMessage,
  });

  final DateTime timestamp;
  final EmotionType emotion;
  final String message;
  final bool isSubmitting;
  final bool isSuccess;
  final bool isValid;
  final String? entryId;
  final String? userId;
  final String? errorMessage;

  bool get isEditing => entryId != null;

  // 생성자
  factory MoodEntryForm.initial(EmotionType emotion) {
    return MoodEntryForm(
      timestamp: DateTime.now(),
      emotion: emotion,
      message: '',
      isSubmitting: false,
      isSuccess: false,
      isValid: true,
      entryId: null,
      userId: null,
      errorMessage: null,
    );
  }

  // 메서드
  MoodEntryForm copyWith({
    DateTime? timestamp,
    EmotionType? emotion,
    String? message,
    bool? isSubmitting,
    bool? isSuccess,
    bool? isValid,
    String? entryId,
    String? userId,
    Object? errorMessage = _noValue,
  }) {
    final nextEmotion = emotion ?? this.emotion;
    final nextMessage = message ?? this.message;
    final computedIsValid = isValid ?? _validate(nextEmotion, nextMessage);
    return MoodEntryForm(
      timestamp: timestamp ?? this.timestamp,
      emotion: nextEmotion,
      message: nextMessage,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      isValid: computedIsValid,
      entryId: entryId ?? this.entryId,
      userId: userId ?? this.userId,
      errorMessage: errorMessage == _noValue
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  // 메시지 길이 제한
  static bool _validate(EmotionType emotion, String message) {
    return message.length <= 500;
  }
}

// null 구별
const Object _noValue = Object();

class MoodEntryFormNotifier extends StateNotifier<MoodEntryForm> {
  MoodEntryFormNotifier(this.ref)
    : super(
        MoodEntryForm.initial(ref.read(currentMoodDataProvider).displayEmotion),
      );

  final Ref ref;

  // 초기 기록용 초기화
  void startNew() {
    final currentEmotion = ref.read(currentMoodDataProvider).displayEmotion;
    state = MoodEntryForm.initial(currentEmotion);
  }

  // 기록 편집용 초기화
  void startEditing(TimelineEntry entry) {
    state = MoodEntryForm(
      timestamp: entry.timestamp,
      emotion: entry.emotion,
      message: entry.message ?? '',
      isSubmitting: false,
      isSuccess: false,
      isValid: true,
      entryId: entry.id,
      userId: entry.userId,
      errorMessage: null,
    );
  }

  // 감정 타입
  void updateEmotion(EmotionType emotion) {
    state = state.copyWith(
      emotion: emotion,
      errorMessage: null,
      isSuccess: false,
    );
  }

  // 타임스탬프
  void updateTimestamp(DateTime timestamp) {
    if (timestamp.isAtSameMomentAs(state.timestamp)) return;
    state = state.copyWith(
      timestamp: timestamp,
      errorMessage: null,
      isSuccess: false,
    );
  }

  // 메시지 업데이트
  void updateMessage(String value) {
    final truncated = value.length > 500 ? value.substring(0, 500) : value;
    final overLimit = value.length > 500;

    state = state.copyWith(
      message: truncated,
      errorMessage: overLimit ? '500자 이내로 입력해주세요' : null,
      isSuccess: false,
    );
  }

  // 에러 메시지 초기화
  void resetError() {
    if (state.errorMessage != null) {
      state = state.copyWith(errorMessage: null);
    }
  }

  // 폼 제출 처리 (새 기록 생성 또는 기존 기록 수정)
  Future<bool> submit() async {
    // 유효성 검사
    if (!state.isValid) {
      state = state.copyWith(errorMessage: '감정을 선택하거나 메시지를 다시 확인해주세요.');
      return false;
    }

    // 사용자 인증 확인
    final currentUser = await _ensureCurrentUser();
    if (currentUser == null) {
      state = state.copyWith(errorMessage: '로그인이 필요합니다.');
      return false;
    }

    // 사용자 ID 결정
    final String resolvedUserId =
        (state.userId != null && state.userId!.isNotEmpty)
        ? state.userId!
        : currentUser.uid;

    final bool editing = state.entryId != null;
    final DateTime timestamp = editing ? state.timestamp : DateTime.now();

    // 제출 상태로 변경
    state = state.copyWith(
      isSubmitting: true,
      errorMessage: null,
      timestamp: timestamp,
    );

    try {
      final repository = ref.read(moodRepositoryProvider);

      if (state.entryId != null) {
        // 수정
        final updatedEntry = TimelineEntry(
          id: state.entryId!,
          timestamp: state.timestamp,
          emotion: state.emotion,
          message: state.message.isEmpty ? null : state.message,
          userId: resolvedUserId,
        );
        await repository.updateEntry(updatedEntry);
        state = state.copyWith(
          isSubmitting: false,
          isSuccess: true,
          userId: resolvedUserId,
        );
      } else {
        // 새 기록 생성
        await repository.createEntry(
          userId: resolvedUserId,
          timestamp: state.timestamp,
          emotion: state.emotion,
          message: state.message.isEmpty ? null : state.message,
        );

        // 성공 후 폼 초기화
        state = MoodEntryForm.initial(
          state.emotion,
        ).copyWith(isSuccess: true, userId: resolvedUserId);
      }

      return true;
    } on FirebaseException catch (error) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: FirebaseErrorHandler.getErrorMessage(error),
      );
      return false;
    } catch (error) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: FirebaseErrorHandler.getErrorMessage(error),
      );
      return false;
    }
  }

  // 현재 로그인된 사용자 확인
  Future<User?> _ensureCurrentUser() async {
    final cachedUser = FirebaseAuth.instance.currentUser;
    if (cachedUser != null) {
      return cachedUser;
    }

    try {
      return await FirebaseAuth.instance
          .authStateChanges()
          .where((user) => user != null)
          .map((user) => user!)
          .first
          .timeout(const Duration(seconds: 3));
    } on TimeoutException {
      return null;
    } catch (_) {
      return null;
    }
  }
}
