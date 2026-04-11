import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/firebase_auth_error_mapper.dart';
import '../data/datasources/auth_service.dart';
import '../data/firebase_auth_repository.dart';
import '../domain/auth_repository.dart';
import '../domain/auth_state.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository(ref.watch(authServiceProvider));
});

final authUserProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);

class AuthController extends Notifier<AuthState> {
  late final AuthRepository _authRepository;
  StreamSubscription<User?>? _authSubscription;

  @override
  AuthState build() {
    _authRepository = ref.watch(authRepositoryProvider);

    _authSubscription ??= _authRepository.authStateChanges().listen((user) {
      final nextState = user == null
          ? const AuthUnauthenticated()
          : const AuthAuthenticated();
      if (state != nextState) {
        state = nextState;
      }
    });
    ref.onDispose(() async {
      await _authSubscription?.cancel();
      _authSubscription = null;
    });

    return _authRepository.currentUser == null
        ? const AuthUnauthenticated()
        : const AuthAuthenticated();
  }

  Future<void> login(String email, String password) async {
    state = const AuthLoading();
    try {
      final user = await _authRepository.login(email, password);
      state = user == null
          ? const AuthError('auth_login_failed')
          : const AuthAuthenticated();
    } on FirebaseAuthException catch (error) {
      state = AuthError(FirebaseAuthErrorMapper.fromException(error));
    } catch (_) {
      state = const AuthError('auth_unknown_error');
    }
  }

  Future<void> register(
    String username,
    String email,
    String password,
  ) async {
    state = const AuthLoading();
    try {
      final user = await _authRepository.register(username, email, password);
      state = user == null
          ? const AuthError('auth_register_failed')
          : const AuthAuthenticated();
    } on FirebaseAuthException catch (error) {
      state = AuthError(FirebaseAuthErrorMapper.fromException(error));
    } catch (_) {
      state = const AuthError('auth_unknown_error');
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    state = const AuthUnauthenticated();
  }
}
