import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mood_tracker/core/constants/app_color.dart';
import 'package:mood_tracker/core/constants/gaps.dart';
import 'package:mood_tracker/core/constants/sizes.dart';
import 'package:mood_tracker/core/models/timeline_entry.dart';

import 'package:mood_tracker/features/post/model/mood_shape.dart';
import 'package:mood_tracker/features/post/post_viewmodel.dart';
import 'package:mood_tracker/features/post/widget/mood_shape_display.dart';
import 'package:mood_tracker/features/post/widget/mood_slider.dart';
import 'package:mood_tracker/features/post/widget/mood_textfield.dart';

class PostScreen extends ConsumerStatefulWidget {
  static const String routeName = 'post';
  static const String routeURL = '/post';

  const PostScreen({super.key, this.entry});

  final TimelineEntry? entry;

  static const double _initialSliderValue = 3.5;

  @override
  ConsumerState<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends ConsumerState<PostScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final sliderNotifier = ref.read(moodSliderValueProvider.notifier);
      final formNotifier = ref.read(moodEntryFormProvider.notifier);

      if (widget.entry != null) {
        final entry = widget.entry!;
        sliderNotifier.state = MoodShapeEngine.sliderAnchorForEmotion(
          entry.emotion,
        );
        formNotifier.startEditing(entry);
      } else {
        sliderNotifier.state = PostScreen._initialSliderValue;
        formNotifier.startNew();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(moodEntryFormProvider);

    Future<void> handleSubmit() async {
      if (form.isSubmitting) return;

      final success = await ref.read(moodEntryFormProvider.notifier).submit();
      if (!context.mounted) return;

      if (success) {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/');
        }
        return;
      }

      final error =
          ref.read(moodEntryFormProvider).errorMessage ?? '잠시 후 다시 시도해주세요.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    }

    final isEditing = form.isEditing;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            }
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.point,
        onPressed: handleSubmit,
        child: form.isSubmitting
            ? SizedBox(
                width: Sizes.size20,
                height: Sizes.size20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.surface,
                  ),
                ),
              )
            : Text(
                isEditing ? 'Update' : 'Post',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.surface,
                ),
              ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: Sizes.size24,
            vertical: Sizes.size16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isEditing ? '생각을 같이 정리해볼까요?' : '지금 어떤 기분인가요?',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: Sizes.size24,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              Gaps.v32,
              Align(
                alignment: Alignment.center,
                child: MoodShapeDisplay(size: Sizes.size200),
              ),
              Gaps.v32,
              const MoodSlider(),
              Gaps.v24,
              const MoodTextField(),
              Gaps.v96,
            ],
          ),
        ),
      ),
    );
  }
}
