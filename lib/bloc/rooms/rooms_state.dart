part of 'rooms_bloc.dart';

enum RoomsStatus { initial, loading, loaded, error }

class RoomsState extends Equatable {
  final RoomsStatus status;
  final List<Room> myRooms;
  final List<Room> joinedRooms;
  final Room? currentRoom; // Текущая просматриваемая комната
  final String? errorMessage;

  const RoomsState({
    this.status = RoomsStatus.initial,
    this.myRooms = const [],
    this.joinedRooms = const [],
    this.currentRoom,
    this.errorMessage,
  });

  RoomsState copyWith({
    RoomsStatus? status,
    List<Room>? myRooms,
    List<Room>? joinedRooms,
    Room? currentRoom,
    String? errorMessage,
  }) {
    return RoomsState(
      status: status ?? this.status,
      myRooms: myRooms ?? this.myRooms,
      joinedRooms: joinedRooms ?? this.joinedRooms,
      currentRoom: currentRoom ?? this.currentRoom,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status, 
    myRooms, 
    joinedRooms, 
    currentRoom, 
    errorMessage
  ];
}