import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mood_tracker/services/firebase_service.dart';

final signUpProvider = StateNotifierProvider<SignUpViewModel, AsyncValue<void>>((ref) {
  final auth = ref.watch(authProvider);
  final db = ref.watch(firestoreProvider);
  return SignUpViewModel(auth: auth, db: db);
});

class SignUpViewModel extends StateNotifier<AsyncValue<void>> {
  SignUpViewModel({required FirebaseAuth auth, required FirebaseFirestore db})
      : _auth = auth,
        _db = db,
        super(const AsyncData(null));

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  Future<void> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    state = const AsyncLoading();
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = cred.user;
      if (user != null) {
        await user.updateDisplayName(displayName);
        await _db.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': user.email,
          'displayName': displayName,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      state = const AsyncData(null);
    } on FirebaseAuthException catch (e) {
      state = AsyncError(e, StackTrace.current);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
