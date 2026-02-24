import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poker_planning/data/models/room.dart';
import 'package:poker_planning/data/repositories/room_repository.dart';

part 'rooms_event.dart';
part 'rooms_state.dart';

class RoomsBloc extends Bloc<RoomsEvent, RoomsState> {
  final RoomRepository _roomRepository;
  Timer? _pollingTimer;

  RoomsBloc({required RoomRepository roomRepository})
      : _roomRepository = roomRepository,
        super(const RoomsState()) {
    on<LoadRoomsEvent>(_onLoadRooms);
    on<LoadRoomEvent>(_onLoadRoom);
    on<CreateRoomEvent>(_onCreateRoom);
    on<JoinRoomEvent>(_onJoinRoom);
    on<LeaveRoomEvent>(_onLeaveRoom);
    on<DeleteRoomEvent>(_onDeleteRoom);
    on<StartPollingEvent>(_onStartPolling);
    on<StopPollingEvent>(_onStopPolling);
  }

  // Загрузка всех комнат пользователя
  Future<void> _onLoadRooms(
    LoadRoomsEvent event,
    Emitter<RoomsState> emit,
  ) async {
    emit(state.copyWith(status: RoomsStatus.loading));
    
    try {
      final rooms = await _roomRepository.getUserRooms();
      print('RoomsBloc: Loaded ${rooms.length} rooms');
      
      // Разделяем на созданные и посещаемые комнаты
      final myRooms = rooms.where((r) => r.creatorId == 'currentUserId').toList();
      final joinedRooms = rooms.where((r) => r.creatorId != 'currentUserId').toList();

      print('RoomsBloc: myRooms = ${myRooms.length}, joinedRooms = ${joinedRooms.length}');
      
      emit(state.copyWith(
        status: RoomsStatus.loaded,
        myRooms: myRooms,
        joinedRooms: joinedRooms,
      ));
    } catch (e) {
       print('RoomsBloc: Error loading rooms: $e');
      emit(state.copyWith(
        status: RoomsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  // Загрузка конкретной комнаты по ID (просмотр)
  Future<void> _onLoadRoom(
    LoadRoomEvent event,
    Emitter<RoomsState> emit,
  ) async {
    emit(state.copyWith(status: RoomsStatus.loading));
    
    try {
      final room = await _roomRepository.getRoom(event.roomId);
      
      emit(state.copyWith(
        status: RoomsStatus.loaded,
        currentRoom: room,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: RoomsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  // Создание новой комнаты
  Future<void> _onCreateRoom(
  CreateRoomEvent event,
  Emitter<RoomsState> emit,
) async {
  emit(state.copyWith(status: RoomsStatus.loading));
  
  try {
    final newRoom = await _roomRepository.createRoom(
      name: event.name,
      description: event.description,
      localUrl: event.localUrl,
    );
    
    print('Room created: ${newRoom.name}');
    
    // Перезагружаем список комнат
    add(const LoadRoomsEvent());
  } catch (e) {
    print('Create room error: $e');
    emit(state.copyWith(
      status: RoomsStatus.error,
      errorMessage: e.toString(),
    ));
  }
}

  // Присоединение к комнате
  Future<void> _onJoinRoom(
    JoinRoomEvent event,
    Emitter<RoomsState> emit,
  ) async {
    emit(state.copyWith(status: RoomsStatus.loading));
    
    try {
      // Исправлено: передаем только roomId, убираем roomUrl
      await _roomRepository.joinRoom(event.roomId);
      
      // После присоединения загружаем эту комнату
      add(LoadRoomEvent(roomId: event.roomId));
      add(const LoadRoomsEvent()); // Также обновляем список
    } catch (e) {
      emit(state.copyWith(
        status: RoomsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  // Покидание комнаты
  Future<void> _onLeaveRoom(
    LeaveRoomEvent event,
    Emitter<RoomsState> emit,
  ) async {
    try {
      await _roomRepository.leaveRoom(event.roomId);
      
      // Очищаем текущую комнату и обновляем список
      emit(state.copyWith(currentRoom: null));
      add(const LoadRoomsEvent());
    } catch (e) {
      emit(state.copyWith(
        status: RoomsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  // Удаление комнаты
  Future<void> _onDeleteRoom(
    DeleteRoomEvent event,
    Emitter<RoomsState> emit,
  ) async {
    try {
      await _roomRepository.deleteRoom(event.roomId);
      
      // Очищаем текущую комнату и обновляем список
      emit(state.copyWith(currentRoom: null));
      add(const LoadRoomsEvent());
    } catch (e) {
      emit(state.copyWith(
        status: RoomsStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  // Запуск polling для real-time обновлений (альтернатива WebSocket)
  void _onStartPolling(
    StartPollingEvent event,
    Emitter<RoomsState> emit,
  ) {
    _stopPolling();
    
    // Опрашиваем сервер каждые 5 секунд для обновления данных
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      // Если есть текущая комната, обновляем её
      if (state.currentRoom != null) {
        add(LoadRoomEvent(roomId: state.currentRoom!.id));
      }
      // Обновляем список комнат
      add(const LoadRoomsEvent());
    });
  }

  // Остановка polling
  void _onStopPolling(
    StopPollingEvent event,
    Emitter<RoomsState> emit,
  ) {
    _stopPolling();
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  @override
  Future<void> close() {
    _stopPolling();
    return super.close();
  }
}