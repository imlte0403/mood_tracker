import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

final loginProvider = StateNotifierProvider<LoginViewModel, LoginState>((ref) {
  return LoginViewModel(FirebaseAuth.instance);
});

class LoginViewModel extends StateNotifier<LoginState> {
  LoginViewModel(this._auth) : super(const LoginState());

  final FirebaseAuth _auth;

  Future<void> login({required String email, required String password}) async {
    await _withLoading(_LoginAction.email, () async {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    });
  }

  // 구글 로그인
  Future<void> loginWithGoogle() async {
    await _withLoading(_LoginAction.google, () async {
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
    await _withLoading(_LoginAction.apple, () async {
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
  Future<void> _withLoading(
    _LoginAction action,
    Future<void> Function() run,
  ) async {
    state = LoginState.loading(
      email: action == _LoginAction.email,
      google: action == _LoginAction.google,
      apple: action == _LoginAction.apple,
    );
    try {
      await run();
      state = const LoginState();
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        state = LoginState.error(
          Exception('Sign-in canceled'),
          StackTrace.current,
        );
      } else {
        state = LoginState.error(e, StackTrace.current);
      }
    } on FirebaseAuthException catch (e) {
      state = LoginState.error(e, StackTrace.current);
    } catch (e, st) {
      state = LoginState.error(e, st);
    }
  }
}

enum _LoginAction { email, google, apple }

class LoginState {
  const LoginState({
    this.status = const AsyncData(null),
    this.emailLoading = false,
    this.googleLoading = false,
    this.appleLoading = false,
  });

  factory LoginState.loading({
    bool email = false,
    bool google = false,
    bool apple = false,
  }) {
    return LoginState(
      status: const AsyncLoading(),
      emailLoading: email,
      googleLoading: google,
      appleLoading: apple,
    );
  }

  factory LoginState.error(Object error, StackTrace stackTrace) {
    return LoginState(status: AsyncError(error, stackTrace));
  }

  final AsyncValue<void> status;
  final bool emailLoading;
  final bool googleLoading;
  final bool appleLoading;

  bool get isLoading => status.isLoading;
}
