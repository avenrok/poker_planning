// import 'dart:async';
// import 'package:socket_io_client/socket_io_client.dart' as IO;
// import 'package:poker_planning/env/env_config.dart';

// class WebSocketService {
//   late IO.Socket _socket;
//   final _roomController = StreamController<Map<String, dynamic>>.broadcast();
//   final _votingController = StreamController<Map<String, dynamic>>.broadcast();

//   Stream<Map<String, dynamic>> get roomUpdates => _roomController.stream;
//   Stream<Map<String, dynamic>> get votingUpdates => _votingController.stream;

//   WebSocketService() {
//     _initSocket();
//   }

//   void _initSocket() {
//     _socket = IO.io(EnvConfig.websocketUrl, <String, dynamic>{
//       'transports': ['websocket'],
//       'autoConnect': true,
//     });

//     _socket.onConnect((_) {
//       print('WebSocket connected');
//     });

//     _socket.on('room:updated', (data) {
//       _roomController.add(data);
//     });

//     _socket.on('voting:updated', (data) {
//       _votingController.add(data);
//     });

//     _socket.onDisconnect((_) {
//       print('WebSocket disconnected');
//     });

//     _socket.onError((error) {
//       print('WebSocket error: $error');
//     });
//   }

//   void joinRoom(String roomId) {
//     _socket.emit('room:join', {'roomId': roomId});
//   }

//   void leaveRoom(String roomId) {
//     _socket.emit('room:leave', {'roomId': roomId});
//   }

//   void sendVote(String votingId, String vote) {
//     _socket.emit('vote:submit', {
//       'votingId': votingId,
//       'vote': vote,
//     });
//   }

//   void dispose() {
//     _roomController.close();
//     _votingController.close();
//     _socket.dispose();
//   }
// }
//  Можно его использовать,если дописать сервер через Websoket, пока что нет времени с ним разбираться