import 'package:firebase_auth/firebase_auth.dart';

import 'datasources/auth_service.dart';
import '../domain/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._authService, {FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final AuthService _authService;
  final FirebaseAuth _firebaseAuth;

  @override
  User? get currentUser => _authService.currentUser;

  @override
  Stream<User?> authStateChanges() => _firebaseAuth.userChanges();

  @override
  Future<User?> login(String email, String password) {
    return _authService.login(email, password);
  }

  @override
  Future<User?> register(String username, String email, String password) {
    return _authService.register(username, email, password);
  }

  @override
  Future<void> logout() => _authService.logout();
}
