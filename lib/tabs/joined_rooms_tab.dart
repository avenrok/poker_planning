import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poker_planning/bloc/rooms/rooms_bloc.dart';
// import 'package:poker_planning/bloc/rooms/rooms_state.dart';
import 'package:poker_planning/data/models/room.dart';
import 'package:poker_planning/view/room_details.dart';
import 'package:poker_planning/view/join_room.dart';

class JoinedRoomsTab extends StatelessWidget {
  const JoinedRoomsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RoomsBloc, RoomsState>(
      builder: (context, state) {
        // Проверяем статус через enum, а не через тип состояния
        switch (state.status) {
          case RoomsStatus.loading:
            return const Center(child: CircularProgressIndicator());
          
          case RoomsStatus.error:
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Ошибка: ${state.errorMessage ?? "Неизвестная ошибка"}',
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<RoomsBloc>().add( LoadRoomsEvent());
                    },
                    child: const Text('Повторить'),
                  ),
                ],
              ),
            );
          
          case RoomsStatus.initial:
          case RoomsStatus.loaded:
            final rooms = state.joinedRooms;
            
            return RefreshIndicator(
              onRefresh: () async {
                context.read<RoomsBloc>().add( LoadRoomsEvent());
              },
              child: rooms.isEmpty
                  ? _buildEmptyState(context)
                  : _buildRoomsList(context, rooms),
            );
        }
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.group,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Вы еще не присоединились ни к одной комнате',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const JoinRoomView(),
                    ),
                  );
                },
                icon: const Icon(Icons.login),
                label: const Text('Присоединиться к комнате'),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () {
                  // TODO: Показать сканер QR-кода
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Функция сканирования QR-кода будет доступна скоро'),
                    ),
                  );
                },
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Сканировать QR-код'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRoomsList(BuildContext context, List<Room> rooms) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: rooms.length,
      itemBuilder: (context, index) {
        final room = rooms[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(
              room.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text('Создатель: ${room.creatorName}'),
                Text('Участников: ${room.participants.length}'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Активна',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => RoomDetailView(room: room),
                ),
              );
            },
          ),
        );
      },
    );
  }
}