import 'package:flutter_riverpod/flutter_riverpod.dart';

class AccountState {
  const AccountState({
    this.displayName = '',
    this.email = '',
    this.createdAt,
    this.emailVerified = false,
    this.canEditPassword = false,
    this.profileStatus = const AsyncLoading(),
    this.renameStatus = const AsyncData(null),
    this.verificationStatus = const AsyncData(null),
    this.passwordStatus = const AsyncData(null),
    this.deleteStatus = const AsyncData(null),
    this.lastVerificationEmailSentAt,
  });

  final String displayName;
  final String email;
  final DateTime? createdAt;
  final bool emailVerified;
  final bool canEditPassword;

  final AsyncValue<void> profileStatus;
  final AsyncValue<void> renameStatus;
  final AsyncValue<void> verificationStatus;
  final AsyncValue<void> passwordStatus;
  final AsyncValue<void> deleteStatus;

  final DateTime? lastVerificationEmailSentAt;

  AccountState copyWith({
    String? displayName,
    String? email,
    DateTime? createdAt,
    bool? emailVerified,
    bool? canEditPassword,
    AsyncValue<void>? profileStatus,
    AsyncValue<void>? renameStatus,
    AsyncValue<void>? verificationStatus,
    AsyncValue<void>? passwordStatus,
    AsyncValue<void>? deleteStatus,
    DateTime? lastVerificationEmailSentAt,
    bool resetLastVerificationTimestamp = false,
  }) {
    return AccountState(
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      emailVerified: emailVerified ?? this.emailVerified,
      canEditPassword: canEditPassword ?? this.canEditPassword,
      profileStatus: profileStatus ?? this.profileStatus,
      renameStatus: renameStatus ?? this.renameStatus,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      passwordStatus: passwordStatus ?? this.passwordStatus,
      deleteStatus: deleteStatus ?? this.deleteStatus,
      lastVerificationEmailSentAt: resetLastVerificationTimestamp
          ? null
          : (lastVerificationEmailSentAt ?? this.lastVerificationEmailSentAt),
    );
  }

  bool get isProfileLoaded => profileStatus is AsyncData<void>;

  int get verificationCooldownRemainingSeconds {
    if (lastVerificationEmailSentAt == null) {
      return 0;
    }
    final elapsed = DateTime.now().difference(lastVerificationEmailSentAt!);
    final remaining = const Duration(seconds: 60) - elapsed;
    if (remaining.isNegative) {
      return 0;
    }
    return remaining.inSeconds;
  }
}
