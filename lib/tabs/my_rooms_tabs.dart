import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poker_planning/bloc/rooms/rooms_bloc.dart';
// import 'package:poker_planning/bloc/rooms/rooms_state.dart';
import 'package:poker_planning/data/models/room.dart';
import 'package:poker_planning/view/create_room.dart';
import 'package:poker_planning/view/room_details.dart';

class MyRoomsTab extends StatelessWidget {
  const MyRoomsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RoomsBloc, RoomsState>(
      builder: (context, state) {
        print('MyRoomsTab building with status: ${state.status}');
        // Проверяем статус через enum
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
            final rooms = state.myRooms;
            
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
                Icons.meeting_room,
                size: 80,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'У вас пока нет созданных комнат',
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
                      builder: (context) => const CreateRoomView(),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Создать комнату'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRoomsList(BuildContext context, List<Room> rooms) {
    print('Building rooms list with ${rooms.length} rooms');
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: rooms.length + 1, // +1 для кнопки создания
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CreateRoomView(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Создать новую комнату'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          );
        }

        final room = rooms[index - 1];
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
                Text('Участников: ${room.participants.length}'),
                Text('Голосований: ${room.votingIds.length}'),
                if (room.roomUrl.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.link, size: 16, color: Colors.blue),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            room.roomUrl,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.blue,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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