import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poker_planning/bloc/auth/auth_bloc.dart';
// import 'package:poker_planning/bloc/auth/auth_state.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  String? _avatarUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final authState = context.read<AuthBloc>().state;
    // Используем status вместо проверки типа
    if (authState.status == AuthStatus.authenticated) {
      _nameController.text = authState.user?.userName ?? '';
      _emailController.text = authState.user?.email ?? '';
      _avatarUrl = authState.user?.avatarUrl;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.loading) {
          setState(() => _isLoading = true);
        } else {
          setState(() => _isLoading = false);
        }

        if (state.status == AuthStatus.authenticated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Профиль успешно обновлен'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        }

        if (state.status == AuthStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Ошибка при обновлении профиля'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Редактирование профиля'),
          actions: [
            TextButton(
              onPressed: _isLoading ? null : _saveProfile,
              child: const Text('Сохранить'),
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Аватар
                      Stack(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.grey[300]!,
                                width: 2,
                              ),
                              image: _avatarUrl != null
                                  ? DecorationImage(
                                      image: NetworkImage(_avatarUrl!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: _avatarUrl == null
                                ? const Center(
                                    child: Icon(
                                      Icons.person,
                                      size: 60,
                                      color: Colors.grey,
                                    ),
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                onPressed: _changeAvatar,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Форма
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Имя пользователя',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Введите имя пользователя';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.email),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            if (!value.contains('@')) {
                              return 'Введите корректный email';
                            }
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Дополнительные настройки
                      Card(
                        child: Column(
                          children: [
                            SwitchListTile(
                              title: const Text('Получать уведомления'),
                              subtitle: const Text('О новых голосованиях в комнатах'),
                              value: true,
                              onChanged: (value) {
                                // Сохранить настройку
                              },
                              secondary: const Icon(Icons.notifications),
                            ),
                            const Divider(height: 0),
                            SwitchListTile(
                              title: const Text('Темная тема'),
                              subtitle: const Text('Использовать темную тему приложения'),
                              value: false,
                              onChanged: (value) {
                                // Сохранить настройку
                              },
                              secondary: const Icon(Icons.dark_mode),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Кнопка смены пароля
                      OutlinedButton.icon(
                        onPressed: _changePassword,
                        icon: const Icon(Icons.lock),
                        label: const Text('Изменить пароль'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Кнопка удаления аккаунта
                      TextButton.icon(
                        onPressed: _deleteAccount,
                        icon: const Icon(Icons.delete_forever, color: Colors.red),
                        label: const Text(
                          'Удалить аккаунт',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        AuthUpdateProfile(
          userName: _nameController.text,
          email: _emailController.text.isNotEmpty ? _emailController.text : null,
          avatarUrl: _avatarUrl,
        ),
      );
    }
  }

  void _changeAvatar() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Выберите источник',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.blue),
                title: const Text('Выбрать из галереи'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Выбрать из галереи
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera, color: Colors.blue),
                title: const Text('Сделать фото'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Сделать фото
                },
              ),
              ListTile(
                leading: const Icon(Icons.link, color: Colors.blue),
                title: const Text('Вставить URL'),
                onTap: () {
                  Navigator.pop(context);
                  _showUrlDialog();
                },
              ),
              if (_avatarUrl != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text(
                    'Удалить аватар',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    setState(() {
                      _avatarUrl = null;
                    });
                    Navigator.pop(context);
                  },
                ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showUrlDialog() {
    final urlController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('URL изображения'),
          content: TextField(
            controller: urlController,
            decoration: const InputDecoration(
              hintText: 'https://example.com/avatar.jpg',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () {
                if (urlController.text.isNotEmpty) {
                  setState(() {
                    _avatarUrl = urlController.text;
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('Применить'),
            ),
          ],
        );
      },
    );
  }

  void _changePassword() {
    // TODO: Реализовать смену пароля
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Функция смены пароля будет доступна позже'),
      ),
    );
  }

  void _deleteAccount() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Удаление аккаунта'),
          content: const Text(
            'Вы уверены, что хотите удалить свой аккаунт? '
            'Это действие нельзя отменить. Все ваши данные будут потеряны.'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // TODO: Реализовать удаление аккаунта
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Функция удаления аккаунта будет доступна позже'),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Удалить'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}