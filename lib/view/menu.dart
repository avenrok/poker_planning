import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:poker_planning/widgets/bottom_nav_bar.dart';
import 'package:poker_planning/widgets/drawer_menu.dart';
import 'package:poker_planning/tabs/my_rooms_tabs.dart';
import 'package:poker_planning/tabs/joined_rooms_tab.dart';
import 'package:poker_planning/tabs/profile_tab.dart';
import 'package:poker_planning/bloc/auth/auth_bloc.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  int _currentIndex = 0;
  
  final List<Widget> _tabs = [
    const MyRoomsTab(),
    const JoinedRoomsTab(),
    const ProfileTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.unauthenticated) {
          print('User logged out, navigating to login');
          Navigator.of(context).pushReplacementNamed('/login');
        }
      },
      child: ResponsiveBuilder(
        builder: (context, sizingInformation) {
          // Для веба показываем Drawer, для мобилок - BottomNavigationBar
          final isMobile = sizingInformation.deviceScreenType == DeviceScreenType.mobile;
          
          return Scaffold(
            appBar: AppBar(
              title: Text(_getAppBarTitle()),
              actions: [
                if (!isMobile)
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      // Обновить данные
                    },
                  ),
                IconButton(
                  icon: const Icon(Icons.notifications),
                  onPressed: () {
                    // Показать уведомления
                  },
                ),
              ],
            ),
            drawer: !isMobile ? const DrawerMenu() : null,
            body: _tabs[_currentIndex],
            bottomNavigationBar: isMobile 
                ? BottomNavBar(
                    currentIndex: _currentIndex,
                    onTap: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                  )
                : null,
          );
        },
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Мои комнаты';
      case 1:
        return 'Посещаемые комнаты';
      case 2:
        return 'Профиль';
      default:
        return 'Главная';
    }
  }
}