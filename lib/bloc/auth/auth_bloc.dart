import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../services/auth_service.dart';
import '../../services/firebase_auth_error_mapper.dart';

class AuthBloc extends HydratedBloc<AuthEvent, AuthState> {
  final AuthService authService;

  AuthBloc({required this.authService}) : super(AuthInitial()) {
    on<AuthStatusChecked>((event, emit) {
      final user = authService.currentUser;
      if (user != null) {
        emit(AuthAuthenticated());
      } else {
        emit(AuthUnauthenticated());
      }
    });

    on<LoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await authService.login(event.email, event.password);
        if (user != null) {
          emit(AuthAuthenticated());
        } else {
          emit(AuthError('auth_login_failed'));
        }
      } on FirebaseAuthException catch (e) {
        emit(AuthError(FirebaseAuthErrorMapper.fromException(e)));
      } catch (_) {
        emit(AuthError('auth_unknown_error'));
      }
    });

    on<RegisterRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        final user = await authService.register(
          event.username,
          event.email,
          event.password,
        );
        if (user != null) {
          emit(AuthAuthenticated());
        } else {
          emit(AuthError('auth_register_failed'));
        }
      } on FirebaseAuthException catch (e) {
        emit(AuthError(FirebaseAuthErrorMapper.fromException(e)));
      } catch (_) {
        emit(AuthError('auth_unknown_error'));
      }
    });

    on<LogoutRequested>((event, emit) async {
      await authService.logout();
      emit(AuthUnauthenticated());
    });

    add(AuthStatusChecked());
  }

  @override
  AuthState? fromJson(Map<String, dynamic> json) {
    return authStateFromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(AuthState state) {
    return authStateToJson(state);
  }
}
