import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthErrorMapper {
  static String fromException(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'auth_invalid_email';
      case 'user-disabled':
        return 'auth_user_disabled';
      case 'user-not-found':
        return 'auth_user_not_found';
      case 'wrong-password':
      case 'invalid-credential':
        return 'auth_wrong_password';
      case 'email-already-in-use':
        return 'auth_email_already_in_use';
      case 'weak-password':
        return 'auth_weak_password';
      case 'operation-not-allowed':
        return 'auth_operation_not_allowed';
      case 'too-many-requests':
        return 'auth_too_many_requests';
      case 'network-request-failed':
        return 'auth_network_error';
      default:
        return 'auth_unknown_error';
    }
  }
}
