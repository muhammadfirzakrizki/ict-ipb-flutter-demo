import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  LoginRequested(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}

class RegisterRequested extends AuthEvent {
  final String username;
  final String email;
  final String password;

  RegisterRequested(this.username, this.email, this.password);

  @override
  List<Object?> get props => [username, email, password];
}

class AuthStatusChecked extends AuthEvent {}

class LogoutRequested extends AuthEvent {}
