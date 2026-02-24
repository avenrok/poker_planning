import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poker_planning/bloc/auth/auth_bloc.dart';
import 'package:poker_planning/bloc/rooms/rooms_bloc.dart';
import 'package:poker_planning/bloc/voting/voting_bloc.dart';
import 'package:poker_planning/env/env_config.dart';
import 'package:poker_planning/data/repositories/auth_repository.dart';
import 'package:poker_planning/data/repositories/room_repository.dart';
import 'package:poker_planning/data/repositories/voting_repository.dart';
import 'package:poker_planning/data/services/api_service.dart';
import 'package:poker_planning/view/login.dart';
import 'package:poker_planning/view/menu.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EnvConfig.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Инициализация сервисов
    final apiService = ApiService();
    
    // Инициализация репозиториев
    final authRepository = AuthRepository(apiService);
    final roomRepository = RoomRepository(apiService);
    final votingRepository = VotingRepository(apiService);

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(authRepository: authRepository),
        ),
        BlocProvider<RoomsBloc>(
          create: (context) => RoomsBloc(roomRepository: roomRepository),
        ),
        BlocProvider<VotingBloc>(
          create: (context) => VotingBloc(votingRepository: votingRepository),
        ),
      ],
      child: MaterialApp(
        title: EnvConfig.appName,
        debugShowCheckedModeBanner: false,
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginView(),
          '/menu': (context) => const MainView(),
        },
      ),
    );
  }
}