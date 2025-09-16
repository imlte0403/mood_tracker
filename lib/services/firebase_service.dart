import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Firebase
final authProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

// Firestore
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

// Firebase Storage
final storageProvider = Provider<FirebaseStorage>((ref) {
  return FirebaseStorage.instance;
});

// FirebaseAuth 오류를 한국어 메시지로 매핑
String authErrorToKorean(Object error) {
  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'user-not-found':
        return '해당 이메일의 사용자를 찾을 수 없어요.';
      case 'wrong-password':
        return '비밀번호가 올바르지 않아요.';
      case 'invalid-email':
        return '유효하지 않은 이메일 형식이에요.';
      case 'user-disabled':
        return '해당 계정은 비활성화되었어요.';
      case 'too-many-requests':
        return '요청이 너무 많아요. 잠시 후 다시 시도해 주세요.';
      case 'network-request-failed':
        return '네트워크 오류가 발생했어요. 연결을 확인해 주세요.';
      case 'account-exists-with-different-credential':
        return '다른 인증 방식으로 가입된 계정이 있어요.';
      case 'invalid-credential':
        return '인증 정보가 올바르지 않아요.';
      case 'email-already-in-use':
        return '이미 사용 중인 이메일이에요.';
      case 'weak-password':
        return '비밀번호가 너무 약해요. 더 복잡하게 변경해 주세요.';
      default:
        return '인증 중 오류가 발생했어요. 잠시 후 다시 시도해 주세요.';
    }
  }
  return '문제가 발생했어요. 잠시 후 다시 시도해 주세요.';
}
