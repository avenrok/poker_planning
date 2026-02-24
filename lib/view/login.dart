import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poker_planning/bloc/auth/auth_bloc.dart';
// import 'package:poker_planning/bloc/auth/auth_state.dart';
// import 'package:poker_planning/view/main_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        print('Auth state changed: ${state.status}');
        
        if (state.status == AuthStatus.authenticated) {
          print('User authenticated, navigating to main');
          Navigator.of(context).pushReplacementNamed('/menu');
        }
        
        if (state.status == AuthStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Ошибка входа'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.person, size: 100, color: Colors.blue),
                const SizedBox(height: 20),
                const Text(
                  'Вход в приложение',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Имя пользователя',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 20),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    return Column(
                      children: [
                        ElevatedButton(
                          onPressed: state.status == AuthStatus.loading
                              ? null
                              : () => _login(),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: state.status == AuthStatus.loading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text('Войти'),
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton(
                          onPressed: state.status == AuthStatus.loading
                              ? null
                              : () => _loginAsGuest(),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Продолжить как гость'),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _login() {
    if (_nameController.text.isNotEmpty) {
      context.read<AuthBloc>().add(
        AuthLoginRequested(userName: _nameController.text),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Введите имя пользователя'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _loginAsGuest() {
    final guestName = 'Гость${DateTime.now().second}';
    context.read<AuthBloc>().add(
      AuthLoginRequested(userName: guestName),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}