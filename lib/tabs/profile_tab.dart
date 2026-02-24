import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poker_planning/bloc/voting/voting_bloc.dart';
// import 'package:poker_planning/bloc/voting/voting_state.dart'; 
import 'package:poker_planning/bloc/auth/auth_bloc.dart';
// import 'package:poker_planning/bloc/auth/auth_state.dart';
import 'package:poker_planning/view/edit_profile.dart';
import 'package:poker_planning/data/models/voting.dart' as models; // Импортируем модель с алиасом

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        // Проверяем статус аутентификации через enum
        if (authState.status != AuthStatus.authenticated) {
          return const Center(
            child: Text('Необходимо авторизоваться'),
          );
        }

        final user = authState.user;
        if (user == null) {
          return const Center(
            child: Text('Ошибка загрузки пользователя'),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Информация о пользователе
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.blue[100],
                        backgroundImage: user.avatarUrl != null 
                            ? NetworkImage(user.avatarUrl!) 
                            : null,
                        child: user.avatarUrl == null
                            ? Text(
                                user.userName.isNotEmpty 
                                    ? user.userName[0].toUpperCase() 
                                    : '?',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.userName,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user.email ?? 'Email не указан',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const EditProfileView(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.edit),
                              label: const Text('Редактировать'),
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(120, 36),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Записи голосований
              const Text(
                'История голосований',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Блок с записями голосований
              BlocBuilder<VotingBloc, VotingState>(
                builder: (context, votingState) {
                  // Проверяем статус через enum
                  switch (votingState.status) {
                    case VotingStatus.loading:
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    
                    case VotingStatus.error:
                      return Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Colors.red[300],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Ошибка загрузки: ${votingState.errorMessage ?? "Неизвестная ошибка"}',
                              style: const TextStyle(fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () {
                                context.read<VotingBloc>().add(
                                  const LoadVotingsEvent(),
                                );
                              },
                              child: const Text('Повторить'),
                            ),
                          ],
                        ),
                      );
                    
                    case VotingStatus.initial:
                    case VotingStatus.loaded:
                      final votings = votingState.userVotings;
                      
                      if (votings.isEmpty) {
                        return Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.how_to_vote,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'У вас пока нет записей голосований',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: votings.length,
                        itemBuilder: (context, index) {
                          final voting = votings[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ExpansionTile(
                              leading: CircleAvatar(
                                backgroundColor: _getVotingStatusColor(voting.status),
                                radius: 18,
                                child: Text(
                                  voting.votes.length.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                voting.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                'Комната: ${voting.roomId}\n'
                                'Дата: ${_formatDate(voting.createdAt)}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Результаты голосования:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      ...voting.results.map((result) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 4),
                                          child: Row(
                                            children: [
                                              Text(
                                                '${result.userName}: ',
                                                style: const TextStyle(fontSize: 13),
                                              ),
                                              const SizedBox(width: 4),
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.blue[50],
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  result.vote,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.blue,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                      if (voting.finalResult != null) ...[
                                        const Divider(height: 24),
                                        Row(
                                          children: [
                                            const Text(
                                              'Итоговый результат: ',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.green[50],
                                                borderRadius: BorderRadius.circular(16),
                                              ),
                                              child: Text(
                                                voting.finalResult!,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.green,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Функция для цвета статуса голосования (из модели данных)
  Color _getVotingStatusColor(models.VotingStatus status) {
    switch (status) {
      case models.VotingStatus.active:
        return Colors.green;
      case models.VotingStatus.finished:
        return Colors.blue;
      case models.VotingStatus.cancelled:
        return Colors.red;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.'
           '${date.month.toString().padLeft(2, '0')}.'
           '${date.year} '
           '${date.hour.toString().padLeft(2, '0')}:'
           '${date.minute.toString().padLeft(2, '0')}';
  }
}