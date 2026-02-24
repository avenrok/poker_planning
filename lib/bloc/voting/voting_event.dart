part of 'voting_bloc.dart';

abstract class VotingEvent extends Equatable {
  const VotingEvent();

  @override
  List<Object> get props => [];
}

// Загрузка всех голосований
class LoadVotingsEvent extends VotingEvent {
  final String? roomId;

  const LoadVotingsEvent({this.roomId});

  @override
  List<Object> get props => [roomId ?? ''];
}

// Загрузка конкретного голосования
class LoadVotingEvent extends VotingEvent {
  final String votingId;

  const LoadVotingEvent({required this.votingId});

  @override
  List<Object> get props => [votingId];
}

// Создание голосования
class CreateVotingEvent extends VotingEvent {
  final String roomId;
  final String title;
  final String? description;

  const CreateVotingEvent({
    required this.roomId,
    required this.title,
    this.description,
  });

  @override
  List<Object> get props => [roomId, title];
}

// Отправка голоса
class SubmitVoteEvent extends VotingEvent {
  final String votingId;
  final String vote;

  const SubmitVoteEvent({
    required this.votingId,
    required this.vote,
  });

  @override
  List<Object> get props => [votingId, vote];
}

// Завершение голосования
class FinishVotingEvent extends VotingEvent {
  final String votingId;
  final String? finalResult;

  const FinishVotingEvent({
    required this.votingId,
    this.finalResult,
  });

  @override
  List<Object> get props => [votingId];
}

// Для polling
class StartVotingPollingEvent extends VotingEvent {
  final String? roomId;

  const StartVotingPollingEvent({this.roomId});

  @override
  List<Object> get props => [roomId ?? ''];
}

class StopVotingPollingEvent extends VotingEvent {
  const StopVotingPollingEvent();
}