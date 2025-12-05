import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mood_tracker/core/constants/app_text_styles.dart';
import 'package:mood_tracker/core/constants/gaps.dart';
import 'package:mood_tracker/core/models/timeline_entry.dart';
import 'package:mood_tracker/features/home/mood_post.dart';
import 'package:mood_tracker/features/post/post_edit.dart';
import 'package:mood_tracker/features/search/viewmodel/search_viewmodel.dart';
import 'package:mood_tracker/features/search/widget/search_bar.dart';
import 'package:mood_tracker/features/search/widget/search_result_tile.dart';

class SearchScreen extends ConsumerWidget {
  static const String routeName = 'search';
  static const String routeURL = '/search';

  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final state = ref.watch(searchViewModelProvider);
    final notifier = ref.read(searchViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          '기록 검색',
          style: AppTextStyles.settings(context),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            SearchInputBar(
              value: state.query,
              onChanged: notifier.updateQuery,
              onSubmitted: (_) => notifier.search(),
              onClear: () => notifier.updateQuery(''),
              onSearchPressed: notifier.search,
            ),
            Gaps.v24,
            Expanded(
              child: _SearchResultSection(
                state: state,
                onEdit: (entry) => context.push(
                  PostEditScreen.routeURL,
                  extra: entry,
                ),
                onDelete: (entry) => confirmDelete(context, ref, entry),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchResultSection extends StatelessWidget {
  const _SearchResultSection({
    required this.state,
    required this.onEdit,
    required this.onDelete,
  });

  final SearchState state;
  final void Function(TimelineEntry entry) onEdit;
  final void Function(TimelineEntry entry) onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (!state.hasSearched && state.query.isEmpty) {
      return _SearchGuide(colorScheme: colorScheme);
    }

    return state.results.when(
      data: (entries) {
        if (entries.isEmpty) {
          return _EmptyResultView(colorScheme: colorScheme);
        }
        return ListView.separated(
          padding: EdgeInsets.zero,
          itemCount: entries.length,
          separatorBuilder: (_, __) => Gaps.v12,
          itemBuilder: (context, index) {
            final entry = entries[index];
            return SearchResultTile(
              entry: entry,
              onEdit: () => onEdit(entry),
              onDelete: () => onDelete(entry),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text(
          error.toString(),
            style: AppTextStyles.settings(context).copyWith(
              color: colorScheme.error,
            ),
        ),
      ),
    );
  }
}

class _SearchGuide extends StatelessWidget {
  const _SearchGuide({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 48,
            color: colorScheme.onSurfaceVariant,
          ),
          Gaps.v12,
          Text(
            '검색어를 입력해 기록을 찾아보세요.',
            style: AppTextStyles.settings(context).copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _EmptyResultView extends StatelessWidget {
  const _EmptyResultView({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 48,
            color: colorScheme.onSurfaceVariant,
          ),
          Gaps.v12,
          Text(
            '해당 검색어를 포함한 기록이 없어요.',
            style: AppTextStyles.settings(context).copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
