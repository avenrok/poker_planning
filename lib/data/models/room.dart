class Room {
  final String id;
  final String roomId;
  final String name;
  final String? description;
  final String creatorId;
  final String creatorName;
  final String roomUrl;
  final String? localIpUrl;
  final List<String> participantIds;
  final List<Participant> participants;
  final List<String> votingIds;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;

  Room({
    required this.id,
    required this.roomId,
    required this.name,
    this.description,
    required this.creatorId,
    required this.creatorName,
    required this.roomUrl,
    this.localIpUrl,
    this.participantIds = const [],
    this.participants = const [],
    this.votingIds = const [],
    required this.createdAt,
    this.updatedAt,
    this.isActive = true,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'] ?? json['RoomID'] ?? '',
      roomId: json['roomId'] ?? json['RoomID'] ?? '',
      name: json['name'] ?? json['roomName'] ?? 'Без названия',
      description: json['description'],
      creatorId: json['creatorId'] ?? json['creatorID'] ?? '',
      creatorName: json['creatorName'] ?? '',
      roomUrl: json['roomUrl'] ?? json['RoomURL'] ?? '',
      localIpUrl: json['localIpUrl'],
      participantIds: List<String>.from(json['participantIds'] ?? []),
      participants: (json['participants'] as List? ?? [])
          .map((p) => Participant.fromJson(p))
          .toList(),
      votingIds: List<String>.from(json['votingIds'] ?? []),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'RoomID': roomId,
      'name': name,
      'description': description,
      'creatorID': creatorId,
      'creatorName': creatorName,
      'RoomURL': roomUrl,
      'localIpUrl': localIpUrl,
      'participantIds': participantIds,
      'participants': participants.map((p) => p.toJson()).toList(),
      'votingIds': votingIds,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isActive': isActive,
    };
  }
}

class Participant {
  final String userId;
  final String userName;
  final DateTime joinedAt;
  final bool isOnline;

  Participant({
    required this.userId,
    required this.userName,
    required this.joinedAt,
    this.isOnline = false,
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      userId: json['userId'] ?? json['userID'] ?? '',
      userName: json['userName'] ?? '',
      joinedAt: DateTime.parse(json['joinedAt'] ?? DateTime.now().toIso8601String()),
      isOnline: json['isOnline'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userID': userId,
      'userName': userName,
      'joinedAt': joinedAt.toIso8601String(),
      'isOnline': isOnline,
    };
  }
}