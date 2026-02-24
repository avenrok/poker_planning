import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poker_planning/data/models/user.dart';
import 'package:poker_planning/data/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthState()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthCheckStatus>(_onCheckStatus);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthUpdateProfile>(_onUpdateProfile);
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    
    try {
      print('AuthBloc: Login requested for ${event.userName}');
      final user = await _authRepository.login(
        userName: event.userName,
        password: event.password,
      );
      print('AuthBloc: Login successful, user id: ${user.id}');
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      ));
    } catch (e) {
      print('AuthBloc: Login error: $e');
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    
    try {
      print('AuthBloc: Register requested for ${event.userName}');
      final user = await _authRepository.register(
        userName: event.userName,
        email: event.email,
        password: event.password,
      );
      print('AuthBloc: Register successful, user id: ${user.id}');
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      ));
    } catch (e) {
      print('AuthBloc: Register error: $e');
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onCheckStatus(
    AuthCheckStatus event,
    Emitter<AuthState> emit,
  ) async {
    print('AuthBloc: Checking auth status');
    final isAuthenticated = await _authRepository.isAuthenticated();
    print('AuthBloc: Is authenticated: $isAuthenticated');
    
    if (isAuthenticated) {
      try {
        final user = await _authRepository.getCurrentUser();
        if (user != null) {
          print('AuthBloc: User found: ${user.userName}');
          emit(state.copyWith(
            status: AuthStatus.authenticated,
            user: user,
          ));
        } else {
          print('AuthBloc: User not found');
          emit(state.copyWith(
            status: AuthStatus.unauthenticated,
          ));
        }
      } catch (e) {
        print('AuthBloc: CheckStatus error: $e');
        emit(state.copyWith(
          status: AuthStatus.unauthenticated,
        ));
      }
    } else {
      print('AuthBloc: Not authenticated');
      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
      ));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    print('AuthBloc: Logout requested');
    await _authRepository.logout();
    emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  Future<void> _onUpdateProfile(
    AuthUpdateProfile event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    
    try {
      print('AuthBloc: Update profile for ${event.userName}');
      final updatedUser = await _authRepository.updateProfile(
        userName: event.userName,
        email: event.email,
        avatarUrl: event.avatarUrl,
      );
      
      print('AuthBloc: Profile updated');
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: updatedUser,
      ));
    } catch (e) {
      print('AuthBloc: Update profile error: $e');
      emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}