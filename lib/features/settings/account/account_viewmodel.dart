import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'account_repository.dart';
import 'account_state.dart';

class AccountViewModel extends StateNotifier<AccountState> {
  AccountViewModel({required AccountRepository repository})
      : _repository = repository,
        super(const AccountState()) {
    _init();
  }

  final AccountRepository _repository;

  void _init() {
    Future.microtask(loadProfile);
  }

  Future<void> loadProfile() async {
    state = state.copyWith(profileStatus: const AsyncLoading());
    try {
      final profile = await _repository.loadProfile();
      state = _applyProfile(
        profile,
        profileStatus: const AsyncData(null),
        clearActionStatuses: true,
      );
    } catch (error, stackTrace) {
      state = state.copyWith(profileStatus: AsyncError(error, stackTrace));
    }
  }

  Future<void> updateDisplayName(String displayName) async {
    if (displayName.trim().isEmpty) {
      state = state.copyWith(
        renameStatus: AsyncError(
          FirebaseAuthException(
            code: 'invalid-display-name',
            message: '표시 이름을 입력해 주세요.',
          ),
          StackTrace.current,
        ),
      );
      return;
    }

    state = state.copyWith(renameStatus: const AsyncLoading());
    try {
      await _repository.updateDisplayName(displayName.trim());
      state = state.copyWith(
        displayName: displayName.trim(),
        renameStatus: const AsyncData(null),
      );
    } catch (error, stackTrace) {
      state = state.copyWith(renameStatus: AsyncError(error, stackTrace));
    }
  }

  Future<void> sendVerificationEmail() async {
    final remaining = state.verificationCooldownRemainingSeconds;
    if (remaining > 0) {
      state = state.copyWith(
        verificationStatus: AsyncError(
          Exception('$remaining초 뒤에 다시 시도해 주세요.'),
          StackTrace.current,
        ),
      );
      return;
    }

    state = state.copyWith(verificationStatus: const AsyncLoading());
    try {
      await _repository.sendEmailVerification();
      state = state.copyWith(
        verificationStatus: const AsyncData(null),
        lastVerificationEmailSentAt: DateTime.now(),
      );
      await refreshEmailVerificationStatus(silent: true);
    } catch (error, stackTrace) {
      state = state.copyWith(verificationStatus: AsyncError(error, stackTrace));
    }
  }

  Future<void> refreshEmailVerificationStatus({bool silent = false}) async {
    if (!silent) {
      state = state.copyWith(verificationStatus: const AsyncLoading());
    }
    try {
      final profile = await _repository.loadProfile();
      state = _applyProfile(
        profile,
        verificationStatus:
            silent ? state.verificationStatus : const AsyncData(null),
      );
    } catch (error, stackTrace) {
      if (!silent) {
        state = state.copyWith(verificationStatus: AsyncError(error, stackTrace));
      }
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (!state.canEditPassword) {
      state = state.copyWith(
        passwordStatus: AsyncError(
          Exception('해당 계정에서는 비밀번호를 변경할 수 없어요.'),
          StackTrace.current,
        ),
      );
      return;
    }

    if (newPassword.trim().length < 6) {
      state = state.copyWith(
        passwordStatus: AsyncError(
          FirebaseAuthException(
            code: 'weak-password',
            message: '비밀번호는 6자 이상 입력해 주세요.',
          ),
          StackTrace.current,
        ),
      );
      return;
    }

    state = state.copyWith(passwordStatus: const AsyncLoading());
    try {
      await _repository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      state = state.copyWith(passwordStatus: const AsyncData(null));
    } catch (error, stackTrace) {
      state = state.copyWith(passwordStatus: AsyncError(error, stackTrace));
    }
  }

  Future<void> deleteAccount() async {
    state = state.copyWith(deleteStatus: const AsyncLoading());
    try {
      await _repository.deleteAccount();
      state = state.copyWith(deleteStatus: const AsyncData(null));
    } catch (error, stackTrace) {
      state = state.copyWith(deleteStatus: AsyncError(error, stackTrace));
    }
  }

  AccountState _applyProfile(
    AccountProfile profile, {
    AsyncValue<void>? profileStatus,
    AsyncValue<void>? verificationStatus,
    bool clearActionStatuses = false,
  }) {
    return state.copyWith(
      profileStatus: profileStatus ?? state.profileStatus,
      displayName: profile.displayName,
      email: profile.email,
      createdAt: profile.createdAt,
      emailVerified: profile.emailVerified,
      canEditPassword: profile.usesPasswordProvider,
      verificationStatus: verificationStatus ?? state.verificationStatus,
      renameStatus: clearActionStatuses ? const AsyncData(null) : state.renameStatus,
      passwordStatus: clearActionStatuses ? const AsyncData(null) : state.passwordStatus,
      deleteStatus: clearActionStatuses ? const AsyncData(null) : state.deleteStatus,
    );
  }
}

final accountViewModelProvider =
    StateNotifierProvider<AccountViewModel, AccountState>((ref) {
  return AccountViewModel(repository: AccountRepository());
});
