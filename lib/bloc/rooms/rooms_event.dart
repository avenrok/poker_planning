part of 'rooms_bloc.dart';

abstract class RoomsEvent extends Equatable {
  const RoomsEvent();

  @override
  List<Object> get props => [];
}

// Загрузка всех комнат
class LoadRoomsEvent extends RoomsEvent {
  const LoadRoomsEvent();
}

// Загрузка конкретной комнаты (просмотр)
class LoadRoomEvent extends RoomsEvent {
  final String roomId;

  const LoadRoomEvent({required this.roomId});

  @override
  List<Object> get props => [roomId];
}

// Создание комнаты
class CreateRoomEvent extends RoomsEvent {
  final String name;
  final String? description;
  final String? localUrl;

  const CreateRoomEvent({
    required this.name,
    this.description,
    this.localUrl,
  });

  @override
  List<Object> get props => [name];
}

// Присоединение к комнате
class JoinRoomEvent extends RoomsEvent {
  final String roomId;

  const JoinRoomEvent({required this.roomId});

  @override
  List<Object> get props => [roomId];
}

// Покидание комнаты
class LeaveRoomEvent extends RoomsEvent {
  final String roomId;

  const LeaveRoomEvent({required this.roomId});

  @override
  List<Object> get props => [roomId];
}

// Удаление комнаты
class DeleteRoomEvent extends RoomsEvent {
  final String roomId;

  const DeleteRoomEvent({required this.roomId});

  @override
  List<Object> get props => [roomId];
}

// Для polling (альтернатива WebSocket)
class StartPollingEvent extends RoomsEvent {
  const StartPollingEvent();
}

class StopPollingEvent extends RoomsEvent {
  const StopPollingEvent();
}