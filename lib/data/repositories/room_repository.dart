import 'package:poker_planning/data/models/room.dart';
import 'package:poker_planning/data/services/api_service.dart';

class RoomRepository {
  final ApiService _apiService;

  RoomRepository(this._apiService);

  Future<List<Room>> getUserRooms() async {
    try {
      final response = await _apiService.get('/rooms');
      print('getUserRooms response: ${response.data}');
      return (response.data as List)
          .map((json) => Room.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting user rooms: $e');
      return [];
    }
  }

  Future<Room> getRoom(String roomId) async {
    try {
      final response = await _apiService.get('/rooms/$roomId');
      return Room.fromJson(response.data);
    } catch (e) {
      print('Error getting room: $e');
      throw Exception('Failed to get room: $e');
    }
  }

  Future<Room> createRoom({
    required String name,
    String? description,
    String? localUrl,
  }) async {
    try {
      print('Creating room: $name');
      final response = await _apiService.post('/rooms', data: {
        'name': name,
        'description': description,
        'localUrl': localUrl,
      });
      print('Create room response: ${response.data}');
      return Room.fromJson(response.data);
    } catch (e) {
      print('Error creating room: $e');
      
      // Если сервер не доступен, создаем локальную комнату для теста
      final testRoom = Room(
        id: 'test_${DateTime.now().millisecondsSinceEpoch}',
        roomId: 'test_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        description: description,
        creatorId: 'currentUserId',
        creatorName: 'Current User',
        roomUrl: 'http://localhost:8000/room/test_${DateTime.now().millisecondsSinceEpoch}',
        localIpUrl: localUrl,
        participantIds: ['currentUserId'],
        participants: [],
        votingIds: [],
        createdAt: DateTime.now(),
        isActive: true,
      );
      
      return testRoom;
    }
  }

  Future<void> joinRoom(String roomId) async {
    try {
      await _apiService.post('/rooms/$roomId/join');
      print('Joined room: $roomId');
    } catch (e) {
      print('Error joining room: $e');
    }
  }

  Future<void> leaveRoom(String roomId) async {
    try {
      await _apiService.post('/rooms/$roomId/leave');
      print('Left room: $roomId');
    } catch (e) {
      print('Error leaving room: $e');
    }
  }

  Future<void> deleteRoom(String roomId) async {
    try {
      await _apiService.delete('/rooms/$roomId');
      print('Deleted room: $roomId');
    } catch (e) {
      print('Error deleting room: $e');
    }
  }
}