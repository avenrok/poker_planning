class Voting {
  final String id;
  final String votingId;
  final String roomId;
  final String title;
  final String? description;
  final String creatorId;
  final DateTime createdAt;
  final DateTime? endedAt;
  final VotingStatus status;
  final Map<String, String> votes; // userId -> vote value
  final List<VoteResult> results;
  final String? finalResult;

  Voting({
    required this.id,
    required this.votingId,
    required this.roomId,
    required this.title,
    this.description,
    required this.creatorId,
    required this.createdAt,
    this.endedAt,
    this.status = VotingStatus.active,
    this.votes = const {},
    this.results = const [],
    this.finalResult,
  });

  factory Voting.fromJson(Map<String, dynamic> json) {
    return Voting(
      id: json['id'] ?? json['votingID'] ?? '',
      votingId: json['votingId'] ?? json['votingID'] ?? '',
      roomId: json['roomId'] ?? json['RoomID'] ?? '',
      title: json['title'] ?? 'Голосование',
      description: json['description'],
      creatorId: json['creatorId'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      endedAt: json['endedAt'] != null 
          ? DateTime.parse(json['endedAt']) 
          : null,
      status: VotingStatus.values.firstWhere(
        (e) => e.toString() == 'VotingStatus.${json['status']}',
        orElse: () => VotingStatus.active,
      ),
      votes: Map<String, String>.from(json['votes'] ?? {}),
      results: (json['results'] as List? ?? [])
          .map((r) => VoteResult.fromJson(r))
          .toList(),
      finalResult: json['finalResult'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'votingID': votingId,
      'RoomID': roomId,
      'title': title,
      'description': description,
      'creatorId': creatorId,
      'createdAt': createdAt.toIso8601String(),
      'endedAt': endedAt?.toIso8601String(),
      'status': status.toString().split('.').last,
      'votes': votes,
      'results': results.map((r) => r.toJson()).toList(),
      'finalResult': finalResult,
    };
  }
}

enum VotingStatus {
  active,
  finished,
  cancelled
}

class VoteResult {
  final String userId;
  final String userName;
  final String vote;
  final DateTime votedAt;

  VoteResult({
    required this.userId,
    required this.userName,
    required this.vote,
    required this.votedAt,
  });

  factory VoteResult.fromJson(Map<String, dynamic> json) {
    return VoteResult(
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      vote: json['vote'] ?? '',
      votedAt: DateTime.parse(json['votedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'vote': vote,
      'votedAt': votedAt.toIso8601String(),
    };
  }
}