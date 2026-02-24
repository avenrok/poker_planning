import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poker_planning/data/models/voting.dart';
import 'package:poker_planning/data/repositories/voting_repository.dart';

part 'voting_event.dart';
part 'voting_state.dart';

class VotingBloc extends Bloc<VotingEvent, VotingState> {
  final VotingRepository _votingRepository;
  Timer? _pollingTimer;

  VotingBloc({required VotingRepository votingRepository})
      : _votingRepository = votingRepository,
        super(const VotingState()) {
    on<LoadVotingsEvent>(_onLoadVotings);
    on<LoadVotingEvent>(_onLoadVoting); // Новый метод для загрузки одного голосования
    on<CreateVotingEvent>(_onCreateVoting);
    on<SubmitVoteEvent>(_onSubmitVote);
    on<FinishVotingEvent>(_onFinishVoting);
    on<StartVotingPollingEvent>(_onStartPolling);
    on<StopVotingPollingEvent>(_onStopPolling);
  }

  // Загрузка всех голосований
  Future<void> _onLoadVotings(
    LoadVotingsEvent event,
    Emitter<VotingState> emit,
  ) async {
    emit(state.copyWith(status: VotingStatus.loading));
    
    try {
      if (event.roomId != null) {
        // Загружаем голосования для конкретной комнаты
        final votings = await _votingRepository.getRoomVotings(event.roomId!);
        emit(state.copyWith(
          status: VotingStatus.loaded,
          roomVotings: votings,
        ));
      } else {
        // Загружаем все голосования пользователя
        final userVotings = await _votingRepository.getUserVotings();
        emit(state.copyWith(
          status: VotingStatus.loaded,
          userVotings: userVotings,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: VotingStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  // Загрузка конкретного голосования
  Future<void> _onLoadVoting(
    LoadVotingEvent event,
    Emitter<VotingState> emit,
  ) async {
    emit(state.copyWith(status: VotingStatus.loading));
    
    try {
      final voting = await _votingRepository.getVoting(event.votingId);
      
      emit(state.copyWith(
        status: VotingStatus.loaded,
        currentVoting: voting,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: VotingStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  // Создание нового голосования
  Future<void> _onCreateVoting(
    CreateVotingEvent event,
    Emitter<VotingState> emit,
  ) async {
    emit(state.copyWith(status: VotingStatus.loading));
    
    try {
      await _votingRepository.createVoting(
        roomId: event.roomId,
        title: event.title,
        description: event.description,
      );
      
      // Перезагружаем список голосований
      add(LoadVotingsEvent(roomId: event.roomId));
    } catch (e) {
      emit(state.copyWith(
        status: VotingStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  // Отправка голоса
  Future<void> _onSubmitVote(
    SubmitVoteEvent event,
    Emitter<VotingState> emit,
  ) async {
    try {
      await _votingRepository.submitVote(
        votingId: event.votingId,
        vote: event.vote,
      );
      
      // После голосования обновляем данные
      add(LoadVotingEvent(votingId: event.votingId));
      if (state.currentVoting?.roomId != null) {
        add(LoadVotingsEvent(roomId: state.currentVoting!.roomId));
      }
    } catch (e) {
      emit(state.copyWith(
        status: VotingStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  // Завершение голосования
  Future<void> _onFinishVoting(
    FinishVotingEvent event,
    Emitter<VotingState> emit,
  ) async {
    try {
      await _votingRepository.finishVoting(
        votingId: event.votingId,
        finalResult: event.finalResult,
      );
      
      // Обновляем данные
      add(LoadVotingEvent(votingId: event.votingId));
      if (state.currentVoting?.roomId != null) {
        add(LoadVotingsEvent(roomId: state.currentVoting!.roomId));
      }
    } catch (e) {
      emit(state.copyWith(
        status: VotingStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  // Запуск polling для real-time обновлений
  void _onStartPolling(
    StartVotingPollingEvent event,
    Emitter<VotingState> emit,
  ) {
    _stopPolling();
    
    // Опрашиваем сервер каждые 3 секунды
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      // Если есть текущее голосование, обновляем его
      if (state.currentVoting != null) {
        add(LoadVotingEvent(votingId: state.currentVoting!.id));
      }
      // Если есть текущая комната, обновляем список голосований
      if (event.roomId != null) {
        add(LoadVotingsEvent(roomId: event.roomId));
      }
    });
  }

  // Остановка polling
  void _onStopPolling(
    StopVotingPollingEvent event,
    Emitter<VotingState> emit,
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