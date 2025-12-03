import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mood_tracker/core/constants/gaps.dart';
import 'package:mood_tracker/core/constants/app_text_styles.dart';

import 'package:mood_tracker/features/auth/screen/log_in_screen.dart';

import 'account_state.dart';
import 'account_viewmodel.dart';

class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  static const routeName = 'account';
  static const routeURL = '/settings/account';

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  ProviderSubscription<AccountState>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = ref.listenManual<AccountState>(accountViewModelProvider, (
      previous,
      next,
    ) {
      if (!mounted) return;
      _handleStatusChange(
        context,
        previous?.renameStatus,
        next.renameStatus,
        successMessage: '이름을 새롭게 저장했어요.',
      );
      _handleStatusChange(
        context,
        previous?.verificationStatus,
        next.verificationStatus,
        successMessage: '확인 메일을 보냈어요.',
      );
      _handleStatusChange(
        context,
        previous?.passwordStatus,
        next.passwordStatus,
        successMessage: '비밀번호를 안전하게 바꿨어요.',
        onSuccess: () {
          _currentPasswordController.clear();
        },
      );
      _handleStatusChange(
        context,
        previous?.deleteStatus,
        next.deleteStatus,
        successMessage: '계정을 삭제했어요.',
        onSuccess: () => context.go(LogInScreen.routeURL),
      );
    }, fireImmediately: false);
  }

  @override
  void dispose() {
    _subscription?.close();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(accountViewModelProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          "계정 관리",
          style: AppTextStyles.authAppBar(
            Theme.of(context).textTheme,
          )?.copyWith(fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        leadingWidth: 100,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: Container(
            padding: const EdgeInsets.only(left: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.arrow_back_ios,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ],
            ),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            height: 1.0,
          ),
        ),
      ),
      body: state.profileStatus.when(
        data: (_) => _AccountContent(
          state: state,
          onDisplayNameTap: () =>
              _showEditNameDialog(context, state.displayName),
          onSendVerification: () => ref
              .read(accountViewModelProvider.notifier)
              .sendVerificationEmail(),
          onRefreshVerification: () => ref
              .read(accountViewModelProvider.notifier)
              .refreshEmailVerificationStatus(),
          onChangePassword: _handleChangePassword,
          onDeleteAccount: _confirmDeleteAccount,
          currentPasswordController: _currentPasswordController,
          newPasswordController: _newPasswordController,
          confirmPasswordController: _confirmPasswordController,
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorView(
          message: _errorMessage(error),
          onRetry: () =>
              ref.read(accountViewModelProvider.notifier).loadProfile(),
        ),
      ),
    );
  }

  Future<void> _showEditNameDialog(
    BuildContext context,
    String currentName,
  ) async {
    final controller = TextEditingController(text: currentName);
    final notifier = ref.read(accountViewModelProvider.notifier);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('이름을 수정할까요?'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(labelText: '표시 이름'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    if (result == true) {
      await notifier.updateDisplayName(controller.text);
    }
  }

  Future<void> _handleChangePassword() async {
    final notifier = ref.read(accountViewModelProvider.notifier);
    final current = _currentPasswordController.text;
    final next = _newPasswordController.text;
    final confirm = _confirmPasswordController.text;

    if (next != confirm) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('새 비밀번호가 서로 다르게 입력되었어요.')));
      return;
    }

    await notifier.changePassword(currentPassword: current, newPassword: next);
    _newPasswordController.clear();
    _confirmPasswordController.clear();
  }

  Future<void> _confirmDeleteAccount() async {
    final notifier = ref.read(accountViewModelProvider.notifier);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('계정을 삭제할까요?'),
          content: const Text('삭제하면 모든 데이터가 사라져요. 계속 진행할까요?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.onSurface,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await notifier.deleteAccount();
    }
  }

  void _handleStatusChange(
    BuildContext context,
    AsyncValue<void>? previous,
    AsyncValue<void> next, {
    String? successMessage,
    VoidCallback? onSuccess,
  }) {
    if (next == previous) {
      return;
    }

    next.whenOrNull(
      data: (_) {
        if (previous is AsyncLoading<void> && successMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(successMessage)));
        }
        if (previous is AsyncLoading<void> && onSuccess != null) {
          onSuccess();
        }
      },
      error: (error, _) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_errorMessage(error))));
      },
    );
  }

  String _errorMessage(Object error) {
    if (error is FirebaseAuthException) {
      return error.message ?? '계정 정보를 확인하는 중 문제가 발생했어요.';
    }
    return error.toString();
  }
}

class _AccountContent extends StatelessWidget {
  const _AccountContent({
    required this.state,
    required this.onDisplayNameTap,
    required this.onSendVerification,
    required this.onRefreshVerification,
    required this.onChangePassword,
    required this.onDeleteAccount,
    required this.currentPasswordController,
    required this.newPasswordController,
    required this.confirmPasswordController,
  });

  final AccountState state;
  final VoidCallback onDisplayNameTap;
  final Future<void> Function() onSendVerification;
  final Future<void> Function() onRefreshVerification;
  final Future<void> Function() onChangePassword;
  final Future<void> Function() onDeleteAccount;
  final TextEditingController currentPasswordController;
  final TextEditingController newPasswordController;
  final TextEditingController confirmPasswordController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: () => onRefreshVerification(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildProfileSection(context, theme),
          Gaps.v24,
          _buildEmailVerification(context, theme),
          Gaps.v24,
          _buildPasswordSection(context, theme),
          Gaps.v24,
          _buildDeleteSection(context, theme),
        ],
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('프로필', style: theme.textTheme.titleMedium),
                TextButton(
                  onPressed: state.renameStatus.isLoading
                      ? null
                      : onDisplayNameTap,
                  child: state.renameStatus.isLoading
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Edit'),
                ),
              ],
            ),
            Gaps.v16,
            _InfoRow(
              label: '이름',
              value: state.displayName.isEmpty ? '-' : state.displayName,
            ),
            Gaps.v8,
            _InfoRow(
              label: '이메일',
              value: state.email.isEmpty ? '-' : state.email,
            ),
            Gaps.v8,
            _InfoRow(label: '가입일', value: _formatDate(state.createdAt)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailVerification(BuildContext context, ThemeData theme) {
    final isCoolingDown = state.verificationCooldownRemainingSeconds > 0;
    final cooldownSeconds = state.verificationCooldownRemainingSeconds;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('이메일 인증', style: theme.textTheme.titleMedium),
            Gaps.v12,
            Row(
              children: [
                Icon(
                  state.emailVerified ? Icons.verified : Icons.error_outline,
                  color: state.emailVerified
                      ? theme.colorScheme.primary
                      : theme.colorScheme.error,
                ),
                Gaps.h8,
                Text(state.emailVerified ? '인증 완료' : '인증 필요'),
              ],
            ),
            Gaps.v12,
            Row(
              children: [
                FilledButton.tonal(
                  onPressed:
                      state.emailVerified || state.verificationStatus.isLoading
                      ? null
                      : () async {
                          await onRefreshVerification();
                        },
                  child: state.verificationStatus.isLoading
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Check status'),
                ),
                Gaps.h12,
                FilledButton(
                  onPressed:
                      state.emailVerified ||
                          state.verificationStatus.isLoading ||
                          isCoolingDown
                      ? null
                      : () async {
                          await onSendVerification();
                        },
                  child: state.verificationStatus.isLoading
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          isCoolingDown
                              ? 'Wait $cooldownSeconds s'
                              : 'Resend email',
                        ),
                ),
              ],
            ),
            if (isCoolingDown)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '$cooldownSeconds초 뒤에 다시 보낼 수 있어요.',
                  style: theme.textTheme.bodySmall,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordSection(BuildContext context, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('비밀번호 변경', style: theme.textTheme.titleMedium),
            Gaps.v12,
            if (!state.canEditPassword)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('소셜 로그인 계정은 비밀번호를 변경할 수 없어요.'),
              )
            else ...[
              TextField(
                controller: currentPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: '현재 비밀번호'),
              ),
              Gaps.v12,
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: '새 비밀번호'),
              ),
              Gaps.v12,
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: '새 비밀번호 확인'),
              ),
              Gaps.v16,
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: state.passwordStatus.isLoading
                      ? null
                      : () async {
                          await onChangePassword();
                        },
                  child: state.passwordStatus.isLoading
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Update password'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDeleteSection(BuildContext context, ThemeData theme) {
    return Card(
      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('계정 삭제', style: theme.textTheme.titleMedium),
            Gaps.v12,
            const Text('계정과 모든 데이터가 완전히 삭제돼요.'),
            Gaps.v16,
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
              ),
              onPressed: state.deleteStatus.isLoading
                  ? null
                  : () async {
                      await onDeleteAccount();
                    },
              child: state.deleteStatus.isLoading
                  ? SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: theme.colorScheme.onPrimary,
                      ),
                    )
                  : const Text('Delete account'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) {
      return '-';
    }
    return '${dateTime.year}-${_twoDigits(dateTime.month)}-${_twoDigits(dateTime.day)}';
  }

  String _twoDigits(int value) => value.toString().padLeft(2, '0');
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Gaps.h8,
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            Gaps.v16,
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
