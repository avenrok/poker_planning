import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

class RoomSocketManager {
  static final Map<String, List<WebSocketChannel>> rooms = {};

  static void joinRoom(
    String roomId,
    WebSocketChannel socket,
  ) {
    rooms.putIfAbsent(roomId, () => []);
    rooms[roomId]!.add(socket);
  }

  static void broadcast(
    String roomId,
    Map<String, dynamic> data,
  ) {
    final encoded = jsonEncode(data);

    for (final socket in rooms[roomId] ?? []) {
      socket.sink.add(encoded);
    }
  }
}