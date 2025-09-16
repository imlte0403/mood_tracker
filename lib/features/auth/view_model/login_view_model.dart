import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mood_tracker/services/firebase_service.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

final loginProvider = StateNotifierProvider<LoginViewModel, AsyncValue<void>>((ref) {
  final auth = ref.watch(authProvider);
  return LoginViewModel(auth);
});

class LoginViewModel extends StateNotifier<AsyncValue<void>> {
  LoginViewModel(this._auth) : super(const AsyncData(null));

  final FirebaseAuth _auth;

  Future<void> login({required String email, required String password}) async {
    await _withLoading(() async {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    });
  }

  // 구글 로그인
  Future<void> loginWithGoogle() async {
    await _withLoading(() async {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        throw Exception('Sign-in canceled');
      }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );
      await _auth.signInWithCredential(credential);
    });
  }

  // 애플 로그인
  Future<void> loginWithApple() async {
    await _withLoading(() async {
      final rawNonce = _generateNonce();
      final nonce = _sha256(rawNonce);

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      final oauthProvider = OAuthProvider('apple.com');
      final credential = oauthProvider.credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );
      await _auth.signInWithCredential(credential);
    });
  }

  // 애플 로그인용 nonce 생성
  String _generateNonce({int length = 32}) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  String _sha256(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
  
  // 에러 핸들링 및 로딩 상태 관리
  Future<void> _withLoading(Future<void> Function() run) async {
    state = const AsyncLoading();
    try {
      await run();
      state = const AsyncData(null);
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        state = AsyncError(Exception('Sign-in canceled'), StackTrace.current);
      } else {
        state = AsyncError(e, StackTrace.current);
      }
    } on FirebaseAuthException catch (e) {
      state = AsyncError(e, StackTrace.current);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
