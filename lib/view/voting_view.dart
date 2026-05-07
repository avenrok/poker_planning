import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poker_planning/bloc/voting/voting_bloc.dart';
// import 'package:poker_planning/bloc/voting/voting_state.dart';
import 'package:poker_planning/data/models/voting.dart' as models;

class VotingView extends StatefulWidget {
  final models.Voting voting;

  const VotingView({super.key, required this.voting});

  @override
  State<VotingView> createState() => _VotingViewState();
}

class _VotingViewState extends State<VotingView> {
  final List<String> _cardValues = [
    '0.5', '1', '2', '3', '5', '?', '☕'
  ];
  
  String? _selectedVote;
  bool _showResults = false;

  @override
  void initState() {
    super.initState();
    // Загружаем актуальные данные при открытии
    context.read<VotingBloc>().add(LoadVotingEvent(votingId: widget.voting.id));
    // Запускаем polling для обновлений в реальном времени
    context.read<VotingBloc>().add(StartVotingPollingEvent(roomId: widget.voting.roomId));
  }

  @override
  void dispose() {
    // Останавливаем polling при закрытии
    context.read<VotingBloc>().add(const StopVotingPollingEvent());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VotingBloc, VotingState>(
      listener: (context, state) {
        // Обработка ошибок
        if (state.status == VotingStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Произошла ошибка'),
              backgroundColor: Colors.red,
            ),
          );
        }
        
        // Обновляем локальное состояние если пришли новые данные
        if (state.currentVoting != null && state.currentVoting!.id == widget.voting.id) {
          setState(() {
            // Обновляем voting в widget нельзя, но можно показать уведомление
            _showResults = state.currentVoting!.status != models.VotingStatus.active;
          });
          
          // Показываем уведомление о новых голосах
          if (state.currentVoting!.votes.length > widget.voting.votes.length) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Поступили новые голоса'),
                backgroundColor: Colors.blue,
                duration: Duration(seconds: 1),
              ),
            );
          }
        }
      },
      builder: (context, state) {
        // Используем актуальные данные из state если они есть
        final currentVoting = state.currentVoting?.id == widget.voting.id 
            ? state.currentVoting! 
            : widget.voting;

        return Scaffold(
          appBar: AppBar(
            title: Text(currentVoting.title),
            actions: [
              if (currentVoting.status == models.VotingStatus.active)
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    context.read<VotingBloc>().add(
                      LoadVotingEvent(votingId: currentVoting.id),
                    );
                  },
                ),
            ],
          ),
          body: Column(
            children: [
              // Информация о голосовании
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.grey[100],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (currentVoting.description != null && currentVoting.description!.isNotEmpty)
                      Text(
                        currentVoting.description!,
                        style: const TextStyle(fontSize: 16),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(currentVoting.status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getStatusText(currentVoting.status),
                            style: TextStyle(
                              color: _getStatusColor(currentVoting.status),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Проголосовало: ${currentVoting.votes.length}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        if (state.status == VotingStatus.loading)
                          const Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Результаты или карточки для голосования
              Expanded(
                child: _showResults || currentVoting.status != models.VotingStatus.active
                    ? _buildResults(currentVoting)
                    : _buildVotingCards(currentVoting),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVotingCards(models.Voting voting) {
    return Column(
      children: [
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.7,
            ),
            itemCount: _cardValues.length,
            itemBuilder: (context, index) {
              final value = _cardValues[index];
              final isSelected = _selectedVote == value;
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedVote = value;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.grey[300]!,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        value,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 40,
                        height: 2,
                        color: isSelected ? Colors.white70 : Colors.grey[400],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        
        // Кнопки управления
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _selectedVote == null ? null : () {
                    setState(() {
                      _showResults = true;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Показать результаты'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _selectedVote == null ? null : () {
                    context.read<VotingBloc>().add(
                      SubmitVoteEvent(
                        votingId: voting.id,
                        vote: _selectedVote!,
                      ),
                    );
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Голос принят'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 1),
                      ),
                    );
                    
                    // Показываем результаты после голосования
                    setState(() {
                      _showResults = true;
                    });
                    
                    // Обновляем данные
                    context.read<VotingBloc>().add(
                      LoadVotingEvent(votingId: voting.id),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Проголосовать'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResults(models.Voting voting) {
    // Подсчет результатов
    final Map<String, int> voteCount = {};
    for (var vote in voting.votes.values) {
      voteCount[vote] = (voteCount[vote] ?? 0) + 1;
    }
    
    final sortedVotes = voteCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Результаты голосования',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Статистика
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                for (var entry in sortedVotes) ...[
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            entry.key,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Карта ${entry.key}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: voting.votes.isEmpty ? 0 : entry.value / voting.votes.length,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _getVoteColor(entry.key),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '${entry.value}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Список проголосовавших
        const Text(
          'Проголосовали:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...voting.results.map((result) {
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue[100],
                child: Text(
                  result.userName.isNotEmpty 
                      ? result.userName[0].toUpperCase() 
                      : '?',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
              title: Text(result.userName),
              subtitle: Text('Проголосовал: ${_formatTime(result.votedAt)}'),
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getVoteColor(result.vote).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  result.vote,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _getVoteColor(result.vote),
                  ),
                ),
              ),
            ),
          );
        }),
        
        if (voting.status == models.VotingStatus.active)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: ElevatedButton(
              onPressed: () {
                context.read<VotingBloc>().add(
                  FinishVotingEvent(
                    votingId: voting.id,
                    finalResult: sortedVotes.isNotEmpty ? sortedVotes.first.key : null,
                  ),
                );
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Голосование завершено'),
                    backgroundColor: Colors.green,
                  ),
                );
                
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Завершить голосование'),
            ),
          ),
        
        if (voting.finalResult != null)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Card(
              color: Colors.green[50],
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.emoji_events, color: Colors.amber),
                    const SizedBox(width: 8),
                    const Text(
                      'Итоговый результат: ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Text(
                        voting.finalResult!,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        
        // Кнопка "Назад к списку"
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 20),
          child: OutlinedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Вернуться к списку'),
          ),
        ),
      ],
    );
  }

  // Используем models.VotingStatus для параметров
  Color _getStatusColor(models.VotingStatus status) {
    switch (status) {
      case models.VotingStatus.active:
        return Colors.green;
      case models.VotingStatus.finished:
        return Colors.blue;
      case models.VotingStatus.cancelled:
        return Colors.red;
    }
  }

  String _getStatusText(models.VotingStatus status) {
    switch (status) {
      case models.VotingStatus.active:
        return 'Активно';
      case models.VotingStatus.finished:
        return 'Завершено';
      case models.VotingStatus.cancelled:
        return 'Отменено';
    }
  }

  Color _getVoteColor(String vote) {
    if (vote == '?') return Colors.purple;
    if (vote == '☕') return Colors.brown;
    
    final value = int.tryParse(vote);
    if (value != null) {
      if (value <= 3) return Colors.green;
      if (value <= 8) return Colors.orange;
      return Colors.red;
    }
    return Colors.blue;
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
           '${time.minute.toString().padLeft(2, '0')}';
  }
}