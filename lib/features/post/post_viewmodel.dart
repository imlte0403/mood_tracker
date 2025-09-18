import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mood_tracker/constants/app_color.dart';
import 'package:mood_tracker/core/models/emotion_type.dart';
import 'package:mood_tracker/features/home/data/mood_repository.dart';
import 'package:mood_tracker/services/firebase_service.dart';

const double _maxSliderValue = 8.0;
const int _segmentCount = 60;

final moodSliderValueProvider =
    StateProvider.autoDispose<double>((ref) => 3.5);

final currentMoodDataProvider =
    Provider.autoDispose<MoodSliderData>((ref) {
  final value = ref.watch(moodSliderValueProvider);
  return MoodSliderData.fromSliderValue(value);
});

final moodEntryFormProvider =
    StateNotifierProvider.autoDispose<MoodEntryFormNotifier, MoodEntryForm>(
  (ref) {
    return MoodEntryFormNotifier(ref);
  },
);

class MoodSliderData {
  const MoodSliderData({
    required this.value,
    required this.emotion,
    required this.currentColor,
    required this.radii,
  });

  final double value;
  final EmotionType emotion;
  final Color currentColor;
  final List<double> radii;

  static MoodSliderData fromSliderValue(double rawValue) {
    final clamped = rawValue.clamp(0.0, _maxSliderValue);
    final int lowerIndex = math.min(
      _morphStages.length - 1,
      clamped.floor(),
    );

    final _MorphStage lowerStage = _morphStages[lowerIndex];
    final bool isLastStage = lowerIndex == _morphStages.length - 1;
    final _MorphStage upperStage = isLastStage
        ? lowerStage
        : _morphStages[lowerIndex + 1];

    final double span = isLastStage
        ? 1
        : (upperStage.start - lowerStage.start).clamp(0.001, 1.0);
    final double t = isLastStage
        ? 0
        : ((clamped - lowerStage.start) / span).clamp(0.0, 1.0);

    final Color blendedColor = Color.lerp(
          lowerStage.color,
          upperStage.color,
          t,
        ) ??
        lowerStage.color;

    final List<double> interpolatedRadii = List<double>.generate(
      _segmentCount,
      (index) {
        final double a = lowerStage.radii[index];
        final double b = upperStage.radii[index];
        return lerpDouble(a, b, t)!;
      },
      growable: false,
    );

    final EmotionType displayEmotion =
        (isLastStage || t <= 0.5) ? lowerStage.emotion : upperStage.emotion;

    return MoodSliderData(
      value: clamped,
      emotion: displayEmotion,
      currentColor: blendedColor,
      radii: interpolatedRadii,
    );
  }

  static Color colorForEmotion(EmotionType emotion) {
    final stage = _stageByEmotion[emotion];
    return stage?.color ?? AppColors.moodHappy;
  }
}

class MoodEntryForm {
  const MoodEntryForm({
    required this.timestamp,
    required this.emotion,
    required this.message,
    required this.isSubmitting,
    required this.isSuccess,
    required this.isValid,
    this.errorMessage,
  });

  final DateTime timestamp;
  final EmotionType emotion;
  final String message;
  final bool isSubmitting;
  final bool isSuccess;
  final bool isValid;
  final String? errorMessage;

  factory MoodEntryForm.initial(EmotionType emotion) {
    return MoodEntryForm(
      timestamp: DateTime.now(),
      emotion: emotion,
      message: '',
      isSubmitting: false,
      isSuccess: false,
      isValid: true,
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
          MoodEntryForm.initial(
            ref.read(currentMoodDataProvider).emotion,
          ),
        );

  final Ref ref;

  void updateEmotion(EmotionType emotion) {
    state = state.copyWith(
      emotion: emotion,
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
      state = state.copyWith(
        errorMessage: '감정을 선택하거나 메시지를 다시 확인해주세요.',
      );
      return false;
    }

    final user = ref.read(authProvider).currentUser;
    if (user == null) {
      state = state.copyWith(errorMessage: '로그인이 필요합니다.');
      return false;
    }

    state = state.copyWith(
      isSubmitting: true,
      errorMessage: null,
      timestamp: DateTime.now(),
    );

    try {
      await ref.read(moodRepositoryProvider).createEntry(
            userId: user.uid,
            timestamp: state.timestamp,
            emotion: state.emotion,
            message: state.message.isEmpty ? null : state.message,
          );

      state = MoodEntryForm.initial(state.emotion).copyWith(isSuccess: true);
      return true;
    } on FirebaseAuthException {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: '로그인이 필요합니다.',
      );
      return false;
    } on FirebaseException catch (error) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: _firebaseErrorToMessage(error),
      );
      return false;
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: '잠시 후 다시 시도해주세요.',
      );
      return false;
    }
  }
}

class _MorphStage {
  _MorphStage({
    required this.start,
    required this.emotion,
    required this.color,
    required this.radii,
  });

  final double start;
  final EmotionType emotion;
  final Color color;
  final List<double> radii;
}

final List<double> _spikyStarRadii = _generateStarRadii(
  spikes: 12,
  outer: 1.08,
  inner: 0.28,
  sharpness: 3.2,
);

final List<double> _ninePointStarRadii = _generateStarRadii(
  spikes: 9,
  outer: 1.02,
  inner: 0.54,
  sharpness: 1.6,
);

final List<double> _sevenPointStarRadii = _generateStarRadii(
  spikes: 7,
  outer: 1.0,
  inner: 0.6,
  sharpness: 1.4,
);

final List<double> _classicStarRadii = _generateStarRadii(
  spikes: 5,
  outer: 0.98,
  inner: 0.74,
  sharpness: 1.2,
);

final List<double> _triangleRadii = _generateStarRadii(
  spikes: 3,
  outer: 1.05,
  inner: 0.46,
  sharpness: 3.5,
);

final List<double> _blobThreeRadii = _generateBlobRadii(
  lobes: 3,
  base: 0.94,
  amplitude: 0.08,
  secondary: 0.035,
);

final List<double> _blobFiveRadii = _generateBlobRadii(
  lobes: 5,
  base: 0.96,
  amplitude: 0.06,
  secondary: 0.028,
);

final List<double> _circleRadii = List<double>.filled(
  _segmentCount,
  0.95,
  growable: false,
);

final List<_MorphStage> _morphStages = <_MorphStage>[
  _MorphStage(
    start: 0.0,
    emotion: EmotionType.angry,
    color: AppColors.moodAngry,
    radii: _spikyStarRadii,
  ),
  _MorphStage(
    start: 1.0,
    emotion: EmotionType.sad,
    color: AppColors.moodSad,
    radii: _ninePointStarRadii,
  ),
  _MorphStage(
    start: 2.0,
    emotion: EmotionType.anxious,
    color: AppColors.moodAnxious,
    radii: _sevenPointStarRadii,
  ),
  _MorphStage(
    start: 3.0,
    emotion: EmotionType.normal,
    color: AppColors.moodNormal,
    radii: _classicStarRadii,
  ),
  _MorphStage(
    start: 4.0,
    emotion: EmotionType.depressed,
    color: AppColors.moodDepressed,
    radii: _triangleRadii,
  ),
  _MorphStage(
    start: 5.0,
    emotion: EmotionType.lucky,
    color: AppColors.moodLucky,
    radii: _blobThreeRadii,
  ),
  _MorphStage(
    start: 6.0,
    emotion: EmotionType.excited,
    color: AppColors.moodExcited,
    radii: _blobFiveRadii,
  ),
  _MorphStage(
    start: 7.0,
    emotion: EmotionType.happy,
    color: AppColors.moodHappy,
    radii: _circleRadii,
  ),
];

final Map<EmotionType, _MorphStage> _stageByEmotion = <EmotionType, _MorphStage>{
  for (final stage in _morphStages) stage.emotion: stage,
};

List<double> _generateStarRadii({
  required int spikes,
  required double outer,
  required double inner,
  double sharpness = 1.0,
}) {
  final double amplitude = outer - inner;
  return List<double>.generate(
    _segmentCount,
    (int index) {
      final double angle = (2 * math.pi * index) / _segmentCount;
      final double cosValue = (math.cos(spikes * angle) + 1) / 2;
      final double shaped = math.pow(cosValue, sharpness).toDouble();
      final double radius = inner + amplitude * shaped;
      return radius.clamp(0.3, 1.15);
    },
    growable: false,
  );
}

List<double> _generateBlobRadii({
  required int lobes,
  required double base,
  required double amplitude,
  required double secondary,
}) {
  return List<double>.generate(
    _segmentCount,
    (int index) {
      final double angle = (2 * math.pi * index) / _segmentCount;
      final double primary = math.sin(lobes * angle);
      final double secondaryWave = math.sin((lobes * 2) * angle + math.pi / lobes);
      final double radius = base + amplitude * primary + secondary * secondaryWave;
      return radius.clamp(0.65, 1.08);
    },
    growable: false,
  );
}

String _firebaseErrorToMessage(FirebaseException error) {
  if (error.code == 'permission-denied') {
    return '로그인이 필요합니다.';
  }
  if (error.code == 'unavailable' || error.code == 'network-error') {
    return '잠시 후 다시 시도해주세요.';
  }
  return '잠시 후 다시 시도해주세요.';
}
