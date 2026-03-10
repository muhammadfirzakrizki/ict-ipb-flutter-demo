import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthAuthenticated extends AuthState {}
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
  @override
  List<Object?> get props => [message];
}
class AuthUnauthenticated extends AuthState {}

AuthState authStateFromJson(Map<String, dynamic> json) {
  switch (json['type']) {
    case 'loading':
      return AuthLoading();
    case 'authenticated':
      return AuthAuthenticated();
    case 'error':
      return AuthError((json['message'] as String?) ?? 'auth_unknown_error');
    case 'unauthenticated':
      return AuthUnauthenticated();
    case 'initial':
    default:
      return AuthInitial();
  }
}

Map<String, dynamic> authStateToJson(AuthState state) {
  if (state is AuthLoading) {
    return {'type': 'loading'};
  }
  if (state is AuthAuthenticated) {
    return {'type': 'authenticated'};
  }
  if (state is AuthError) {
    return {'type': 'error', 'message': state.message};
  }
  if (state is AuthUnauthenticated) {
    return {'type': 'unauthenticated'};
  }
  return {'type': 'initial'};
}
