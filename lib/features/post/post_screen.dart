import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mood_tracker/core/constants/app_color.dart';
import 'package:mood_tracker/core/constants/gaps.dart';
import 'package:mood_tracker/core/constants/sizes.dart';
import 'package:mood_tracker/features/post/post_viewmodel.dart';
import 'package:mood_tracker/features/post/widget/mood_shape_display.dart';
import 'package:mood_tracker/features/post/widget/mood_slider.dart';
import 'package:mood_tracker/features/post/widget/mood_textfield.dart';
import 'package:mood_tracker/features/home/home_screen.dart';


class PostScreen extends ConsumerWidget {
  static const String routeName = 'post';
  static const String routeURL = '/post';

  const PostScreen({super.key});

  static const double _initialSliderValue = 3.5;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(moodEntryFormProvider);

    Future<void> handleSubmit() async {
      if (form.isSubmitting) return;

      final success = await ref.read(moodEntryFormProvider.notifier).submit();
      if (!context.mounted) return;

      if (success) {
        ref.read(moodSliderValueProvider.notifier).state = _initialSliderValue;
        context.go(HomeScreen.routeURL);
        return;
      }

      final error =
          ref.read(moodEntryFormProvider).errorMessage ?? '잠시 후 다시 시도해주세요.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    }

    return Scaffold(
      backgroundColor: AppColors.bgBeige,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.text),
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
            ? const SizedBox(
                width: Sizes.size20,
                height: Sizes.size20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.bgWhite),
                ),
              )
            : const Text(
                'Post',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.bgWhite,
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
              const Text(
                'How do you feel Right Now?',
                style: TextStyle(
                  fontFamily: 'PlayfairDisplay',
                  fontSize: Sizes.size24,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
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
