import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  User? get currentUser;

  Stream<User?> authStateChanges();

  Future<User?> login(String email, String password);

  Future<User?> register(String username, String email, String password);

  Future<void> logout();
}
