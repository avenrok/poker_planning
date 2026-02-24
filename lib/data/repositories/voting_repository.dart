import 'package:poker_planning/data/models/voting.dart';
import 'package:poker_planning/data/services/api_service.dart';

class VotingRepository {
  final ApiService _apiService;

  VotingRepository(this._apiService);

  // Получить все голосования в комнате
  Future<List<Voting>> getRoomVotings(String roomId) async {
    try {
      final response = await _apiService.get('/rooms/$roomId/votings');
      return (response.data as List)
          .map((json) => Voting.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting room votings: $e');
      return [];
    }
  }

  // Получить все голосования пользователя
  Future<List<Voting>> getUserVotings() async {
    try {
      final response = await _apiService.get('/user/votings');
      return (response.data as List)
          .map((json) => Voting.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting user votings: $e');
      return [];
    }
  }

  // Получить конкретное голосование
  Future<Voting> getVoting(String votingId) async {
    try {
      final response = await _apiService.get('/votings/$votingId');
      return Voting.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to get voting: $e');
    }
  }

  // Создать голосование
  Future<Voting> createVoting({
    required String roomId,
    required String title,
    String? description,
  }) async {
    try {
      final response = await _apiService.post('/rooms/$roomId/votings', data: {
        'title': title,
        'description': description,
      });
      return Voting.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to create voting: $e');
    }
  }

  // Отправить голос
  Future<void> submitVote({
    required String votingId,
    required String vote,
  }) async {
    try {
      await _apiService.post('/votings/$votingId/vote', data: {
        'vote': vote,
      });
    } catch (e) {
      print('Error submitting vote: $e');
      rethrow;
    }
  }

  // Завершить голосование
  Future<void> finishVoting({
    required String votingId,
    String? finalResult,
  }) async {
    try {
      await _apiService.post('/votings/$votingId/finish', data: {
        'finalResult': finalResult,
      });
    } catch (e) {
      print('Error finishing voting: $e');
      rethrow;
    }
  }
}