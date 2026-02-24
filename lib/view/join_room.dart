import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poker_planning/bloc/rooms/rooms_bloc.dart';

class JoinRoomView extends StatefulWidget {
  const JoinRoomView({super.key});

  @override
  State<JoinRoomView> createState() => _JoinRoomViewState();
}

class _JoinRoomViewState extends State<JoinRoomView> {
  final _roomIdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Присоединиться к комнате'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.meeting_room,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 20),
            const Text(
              'Введите ID комнаты',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _roomIdController,
              decoration: InputDecoration(
                labelText: 'ID комнаты',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.vpn_key),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _joinRoom,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Присоединиться',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _joinRoom() {
    final roomId = _roomIdController.text.trim();
    if (roomId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Введите ID комнаты'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    context.read<RoomsBloc>().add(JoinRoomEvent(roomId: roomId));
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Присоединяемся к комнате...'),
        backgroundColor: Colors.green,
      ),
    );
    
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _roomIdController.dispose();
    super.dispose();
  }
}