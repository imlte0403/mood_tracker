import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AccountProfile {
  const AccountProfile({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.emailVerified,
    required this.createdAt,
    required this.usesPasswordProvider,
  });

  final String uid;
  final String displayName;
  final String email;
  final bool emailVerified;
  final DateTime? createdAt;
  final bool usesPasswordProvider;
}

class AccountRepository {
  AccountRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Future<AccountProfile> loadProfile() async {
    var user = _requireUser();
    await user.reload();
    user = _requireUser();

    DateTime? createdAt;
    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (doc.exists) {
      final data = doc.data();
      final value = data?['createdAt'];
      if (value is Timestamp) {
        createdAt = value.toDate();
      } else if (value is DateTime) {
        createdAt = value;
      }
    }

    final providers = user.providerData.map((info) => info.providerId).toList();
    final usesPasswordProvider = providers.contains(EmailAuthProvider.PROVIDER_ID);

    return AccountProfile(
      uid: user.uid,
      displayName: user.displayName ?? '',
      email: user.email ?? '',
      emailVerified: user.emailVerified,
      createdAt: createdAt,
      usesPasswordProvider: usesPasswordProvider,
    );
  }

  Future<void> updateDisplayName(String displayName) async {
    final user = _requireUser();
    await user.updateDisplayName(displayName);
    await _firestore.collection('users').doc(user.uid).set(
      {
        'displayName': displayName,
      },
      SetOptions(merge: true),
    );
  }

  Future<void> sendEmailVerification() async {
    final user = _requireUser();
    await user.sendEmailVerification();
    await user.reload();
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _requireUser();
    final email = user.email;
    if (email == null) {
      throw FirebaseAuthException(
        code: 'missing-email',
        message: 'Email address is required to update password.',
      );
    }

    final credential = EmailAuthProvider.credential(
      email: email,
      password: currentPassword,
    );

    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }

  Future<void> deleteAccount() async {
    final user = _requireUser();
    await _firestore.collection('users').doc(user.uid).delete();
    // TODO: 추후 상세 개발 예정
    await user.delete();
  }

  User _requireUser() {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'No authenticated user.',
      );
    }
    return user;
  }
}
