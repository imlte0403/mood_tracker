import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mood_tracker/services/firebase_service.dart';

final loginViewModelProvider =
    StateNotifierProvider<LoginViewModel, AsyncValue<void>>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return LoginViewModel(auth);
});

class LoginViewModel extends StateNotifier<AsyncValue<void>> {
  LoginViewModel(this._auth) : super(const AsyncData(null));

  final FirebaseAuth _auth;

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncLoading();
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      state = const AsyncData(null);
    } on FirebaseAuthException catch (e) {
      state = AsyncError(e, StackTrace.current);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
