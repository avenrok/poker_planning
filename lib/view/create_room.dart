import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poker_planning/bloc/auth/auth_bloc.dart';
import 'package:poker_planning/bloc/rooms/rooms_bloc.dart';
import 'package:poker_planning/env/env_config.dart';
import 'package:poker_planning/data/utils/network_helper.dart';

class CreateRoomView extends StatefulWidget {
  const CreateRoomView({super.key});

  @override
  State<CreateRoomView> createState() => _CreateRoomViewState();
}

class _CreateRoomViewState extends State<CreateRoomView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String? _localIpUrl;
  bool _isGeneratingUrl = false;

  @override
  void initState() {
    super.initState();
    _generateRoomUrl();
  }

  Future<void> _generateRoomUrl() async {
    setState(() {
      _isGeneratingUrl = true;
    });

    // Получаем локальный IP адрес
    final localIp = await NetworkHelper.getLocalIpAddress();
    final roomId = DateTime.now().millisecondsSinceEpoch.toString();
    
    setState(() {
      _localIpUrl = 'http://$localIp:${EnvConfig.localNetworkPort}/room/$roomId';
      _isGeneratingUrl = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Создание комнаты'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Название комнаты
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Название комнаты *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.meeting_room),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите название комнаты';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Описание
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Описание (необязательно)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              
              const SizedBox(height: 24),
              
              // URL для подключения
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'URL для подключения:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_isGeneratingUrl)
                        const Center(child: CircularProgressIndicator())
                      else if (_localIpUrl != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _localIpUrl!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.copy),
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: _localIpUrl!));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('URL скопирован'),
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'По этому URL пользователи смогут подключиться к комнате\n'
                          '(доступно только в локальной сети)',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Кнопка создания
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _createRoom();
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Создать комнату',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _createRoom() {
  if (_formKey.currentState!.validate()) {
    final authState = context.read<AuthBloc>().state;
    final userId = authState.user?.id ?? 'guest';
    final userName = authState.user?.userName ?? 'Guest';
    
    context.read<RoomsBloc>().add(
      CreateRoomEvent(
        name: _nameController.text,
        description: _descriptionController.text,
        localUrl: _localIpUrl,
        userId: userId,       
        userName: userName,    
      ),
    );
    
    Navigator.of(context).pop();
  }
}

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}