import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poker_planning/bloc/auth/auth_bloc.dart';
import 'package:poker_planning/env/env_config.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Пользователь',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Версия: ${EnvConfig.appVersion}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                _buildDrawerItem(
                  icon: Icons.home,
                  title: 'Главная',
                  onTap: () {
                    // Перейти на главную
                    Navigator.pop(context);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.person,
                  title: 'Профиль',
                  onTap: () {
                    // Перейти в профиль
                    Navigator.pop(context);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.settings,
                  title: 'Настройки',
                  onTap: () {
                    // Перейти в настройки
                    Navigator.pop(context);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.help,
                  title: 'Помощь',
                  onTap: () {
                    // Перейти в помощь
                    Navigator.pop(context);
                  },
                ),
                const Divider(),
                _buildDrawerItem(
                  icon: Icons.logout,
                  title: 'Выйти',
                  color: Colors.red,
                  onTap: () {
                    _showLogoutDialog(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(color: color),
      ),
      onTap: onTap,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Выход'),
          content: const Text('Вы действительно хотите выйти?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                context.read<AuthBloc>().add(AuthLogoutRequested());
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Выйти'),
            ),
          ],
        );
      },
    );
  }
}