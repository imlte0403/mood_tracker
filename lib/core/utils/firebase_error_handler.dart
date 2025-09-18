import 'package:firebase_auth/firebase_auth.dart';

class FirebaseErrorHandler {
  const FirebaseErrorHandler._();

  static String getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return '사용자를 찾을 수 없습니다.';
        case 'permission-denied':
          return '로그인이 필요합니다.';
        default:
          return '인증 오류가 발생했습니다.';
      }
    }

    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return '로그인이 필요합니다.';
        case 'unavailable':
        case 'network-error':
          return '잠시 후 다시 시도해주세요.';
        default:
          return '서버 오류가 발생했습니다.';
      }
    }

    return '잠시 후 다시 시도해주세요.';
  }
}
