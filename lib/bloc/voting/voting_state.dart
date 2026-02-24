part of 'voting_bloc.dart';

enum VotingStatus { initial, loading, loaded, error }

class VotingState extends Equatable {
  final VotingStatus status;
  final List<Voting> roomVotings;
  final List<Voting> userVotings;
  final Voting? currentVoting;
  final String? errorMessage;

  const VotingState({
    this.status = VotingStatus.initial,
    this.roomVotings = const [],
    this.userVotings = const [],
    this.currentVoting,
    this.errorMessage,
  });

  VotingState copyWith({
    VotingStatus? status,
    List<Voting>? roomVotings,
    List<Voting>? userVotings,
    Voting? currentVoting,
    String? errorMessage,
  }) {
    return VotingState(
      status: status ?? this.status,
      roomVotings: roomVotings ?? this.roomVotings,
      userVotings: userVotings ?? this.userVotings,
      currentVoting: currentVoting ?? this.currentVoting,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status, 
    roomVotings, 
    userVotings, 
    currentVoting, 
    errorMessage
  ];
}