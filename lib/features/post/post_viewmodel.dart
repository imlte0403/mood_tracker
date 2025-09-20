import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mood_tracker/core/models/emotion_type.dart';
import 'package:mood_tracker/core/models/timeline_entry.dart';
import 'package:mood_tracker/features/home/data/mood_repository.dart';
import 'package:mood_tracker/core/utils/firebase_error_handler.dart';
import 'package:mood_tracker/features/post/model/mood_shape.dart';

final moodSliderValueProvider = StateProvider.autoDispose<double>((ref) => 3.5);

final currentMoodDataProvider = Provider.autoDispose<MoodShapeSnapshot>((ref) {
  final value = ref.watch(moodSliderValueProvider);
  return MoodShapeEngine.resolve(value);
});

final moodEntryFormProvider =
    StateNotifierProvider.autoDispose<MoodEntryFormNotifier, MoodEntryForm>((
      ref,
    ) {
      return MoodEntryFormNotifier(ref);
    });

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

  static bool _validate(EmotionType emotion, String message) {
    return message.length <= 500;
  }
}

const Object _noValue = Object();

class MoodEntryFormNotifier extends StateNotifier<MoodEntryForm> {
  MoodEntryFormNotifier(this.ref)
    : super(
        MoodEntryForm.initial(ref.read(currentMoodDataProvider).displayEmotion),
      );

  final Ref ref;

  void startNew() {
    final currentEmotion = ref.read(currentMoodDataProvider).displayEmotion;
    state = MoodEntryForm.initial(currentEmotion);
  }

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

  void updateEmotion(EmotionType emotion) {
    state = state.copyWith(
      emotion: emotion,
      errorMessage: null,
      isSuccess: false,
    );
  }

  void updateTimestamp(DateTime timestamp) {
    if (timestamp.isAtSameMomentAs(state.timestamp)) return;
    state = state.copyWith(
      timestamp: timestamp,
      errorMessage: null,
      isSuccess: false,
    );
  }

  void updateMessage(String value) {
    final truncated = value.length > 500 ? value.substring(0, 500) : value;
    final overLimit = value.length > 500;

    state = state.copyWith(
      message: truncated,
      errorMessage: overLimit ? '500자 이내로 입력해주세요' : null,
      isSuccess: false,
    );
  }

  void resetError() {
    if (state.errorMessage != null) {
      state = state.copyWith(errorMessage: null);
    }
  }

  Future<bool> submit() async {
    if (!state.isValid) {
      state = state.copyWith(errorMessage: '감정을 선택하거나 메시지를 다시 확인해주세요.');
      return false;
    }

    final currentUser = await _ensureCurrentUser();
    if (currentUser == null) {
      state = state.copyWith(errorMessage: '로그인이 필요합니다.');
      return false;
    }

    final String resolvedUserId =
        (state.userId != null && state.userId!.isNotEmpty)
        ? state.userId!
        : currentUser.uid;

    final bool editing = state.entryId != null;
    final DateTime timestamp = editing ? state.timestamp : DateTime.now();

    state = state.copyWith(
      isSubmitting: true,
      errorMessage: null,
      timestamp: timestamp,
    );

    try {
      final repository = ref.read(moodRepositoryProvider);

      if (state.entryId != null) {
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
        await repository.createEntry(
          userId: resolvedUserId,
          timestamp: state.timestamp,
          emotion: state.emotion,
          message: state.message.isEmpty ? null : state.message,
        );

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
