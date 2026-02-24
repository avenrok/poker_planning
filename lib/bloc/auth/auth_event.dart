part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AuthLoginRequested extends AuthEvent {
  final String userName;
  final String? password;

  const AuthLoginRequested({
    required this.userName,
    this.password,
  });

  @override
  List<Object> get props => [userName];
}

class AuthRegisterRequested extends AuthEvent {
  final String userName;
  final String email;
  final String? password;

  const AuthRegisterRequested({
    required this.userName,
    required this.email,
    this.password,
  });

  @override
  List<Object> get props => [userName, email];
}

class AuthCheckStatus extends AuthEvent {}

class AuthLogoutRequested extends AuthEvent {}

class AuthUpdateProfile extends AuthEvent {
  final String userName;
  final String? email;
  final String? avatarUrl;

  const AuthUpdateProfile({
    required this.userName,
    this.email,
    this.avatarUrl,
  });

  @override
  List<Object> get props => [userName];
}