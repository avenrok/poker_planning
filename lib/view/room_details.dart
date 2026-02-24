import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:poker_planning/bloc/rooms/rooms_bloc.dart';
// import 'package:poker_planning/bloc/rooms/rooms_state.dart';
import 'package:poker_planning/bloc/voting/voting_bloc.dart';
// import 'package:poker_planning/bloc/voting/voting_state.dart';
import 'package:poker_planning/data/models/room.dart';
import 'package:poker_planning/data/models/voting.dart' as models; 
import 'package:poker_planning/view/voting_view.dart';

class RoomDetailView extends StatefulWidget {
  final Room room;

  const RoomDetailView({super.key, required this.room});

  @override
  State<RoomDetailView> createState() => _RoomDetailViewState();
}

class _RoomDetailViewState extends State<RoomDetailView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Загружаем голосования для этой комнаты
    context.read<VotingBloc>().add(LoadVotingsEvent(roomId: widget.room.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.room.name),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Участники', icon: Icon(Icons.people)),
            Tab(text: 'Голосования', icon: Icon(Icons.how_to_vote)),
            Tab(text: 'Настройки', icon: Icon(Icons.settings)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _showShareOptions,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildParticipantsTab(),
          _buildVotingsTab(),
          _buildSettingsTab(),
        ],
      ),
      floatingActionButton: _tabController.index == 1
          ? FloatingActionButton(
              onPressed: _showCreateVotingDialog,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildParticipantsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.room.participants.length,
      itemBuilder: (context, index) {
        final participant = widget.room.participants[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: participant.isOnline ? Colors.green : Colors.grey,
              child: Text(
                participant.userName.isNotEmpty 
                    ? participant.userName[0].toUpperCase() 
                    : '?',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(participant.userName),
            subtitle: Text(
              participant.isOnline ? 'В сети' : 'Не в сети',
              style: TextStyle(
                color: participant.isOnline ? Colors.green : Colors.grey,
              ),
            ),
            trailing: participant.userId == widget.room.creatorId
                ? const Chip(
                    label: Text('Создатель'),
                    backgroundColor: Colors.blue,
                    labelStyle: TextStyle(color: Colors.white, fontSize: 12),
                  )
                : null,
          ),
        );
      },
    );
  }

  Widget _buildVotingsTab() {
    return BlocBuilder<VotingBloc, VotingState>(
      builder: (context, state) {
        // Проверяем статус загрузки
        switch (state.status) {
          case VotingStatus.loading:
            return const Center(child: CircularProgressIndicator());
          
          case VotingStatus.error:
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Ошибка загрузки: ${state.errorMessage ?? "Неизвестная ошибка"}',
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<VotingBloc>().add(
                        LoadVotingsEvent(roomId: widget.room.id),
                      );
                    },
                    child: const Text('Повторить'),
                  ),
                ],
              ),
            );
          
          case VotingStatus.initial:
          case VotingStatus.loaded:
            if (state.roomVotings.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.how_to_vote,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'В этой комнате пока нет голосований',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _showCreateVotingDialog,
                      icon: const Icon(Icons.add),
                      label: const Text('Создать голосование'),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.roomVotings.length,
              itemBuilder: (context, index) {
                final voting = state.roomVotings[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      voting.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        if (voting.description != null && voting.description!.isNotEmpty)
                          Text(voting.description!),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getVotingStatusColor(voting.status).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _getVotingStatusText(voting.status),
                                style: TextStyle(
                                  color: _getVotingStatusColor(voting.status),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Проголосовало: ${voting.votes.length}',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => VotingView(voting: voting),
                        ),
                      );
                    },
                  ),
                );
              },
            );
        }
      },
    );
  }

  Widget _buildSettingsTab() {
    // TODO: получить реальный ID из AuthBloc
    final isCreator = widget.room.creatorId == 'currentUserId';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Информация о комнате',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Название', widget.room.name),
                const Divider(),
                _buildInfoRow('Создатель', widget.room.creatorName),
                const Divider(),
                _buildInfoRow('Дата создания', _formatDate(widget.room.createdAt)),
                const Divider(),
                _buildInfoRow('Участников', '${widget.room.participants.length}'),
                const Divider(),
                _buildInfoRow('Голосований', '${widget.room.votingIds.length}'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        if (widget.room.localIpUrl != null) ...[
          const Text(
            'Локальный URL',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Подключайтесь по локальной сети:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: SelectableText(  // Используем SelectableText
                            widget.room.localIpUrl!,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: widget.room.localIpUrl!));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('URL скопирован'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 24),
        if (isCreator)
          ElevatedButton(
            onPressed: _showDeleteRoomDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Удалить комнату'),
          )
        else
          OutlinedButton(
            onPressed: _showLeaveRoomDialog,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Покинуть комнату'),
          ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  void _showShareOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.copy, color: Colors.blue),
                title: const Text('Копировать URL'),
                onTap: () {
                  Navigator.pop(context);
                  // Копировать URL
                },
              ),
              ListTile(
                leading: const Icon(Icons.qr_code, color: Colors.blue),
                title: const Text('Показать QR-код'),
                onTap: () {
                  Navigator.pop(context);
                  _showQRCode();
                },
              ),
              ListTile(
                leading: const Icon(Icons.share, color: Colors.blue),
                title: const Text('Поделиться'),
                onTap: () {
                  Navigator.pop(context);
                  // Поделиться
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showQRCode() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('QR-код комнаты'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 200,
                width: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(Icons.qr_code, size: 100),
                ),
              ),
              const SizedBox(height: 16),
              SelectableText(
                widget.room.roomUrl,
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Закрыть'),
            ),
          ],
        );
      },
    );
  }

  void _showCreateVotingDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Создать голосование'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Название *',
                  border: OutlineInputBorder(),
                  hintText: 'Введите название голосования',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Описание',
                  border: OutlineInputBorder(),
                  hintText: 'Введите описание (необязательно)',
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  context.read<VotingBloc>().add(
                    CreateVotingEvent(
                      roomId: widget.room.id,
                      title: titleController.text,
                      description: descriptionController.text.isNotEmpty 
                          ? descriptionController.text 
                          : null,
                    ),
                  );
                  Navigator.pop(context);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Голосование создано'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text('Создать'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteRoomDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Удалить комнату'),
          content: const Text('Вы уверены, что хотите удалить эту комнату? Это действие нельзя отменить.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<RoomsBloc>().add(DeleteRoomEvent(roomId: widget.room.id));
                Navigator.pop(context);
                Navigator.pop(context);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Комната удалена'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Удалить'),
            ),
          ],
        );
      },
    );
  }

  void _showLeaveRoomDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Покинуть комнату'),
          content: const Text('Вы уверены, что хотите покинуть эту комнату?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<RoomsBloc>().add(LeaveRoomEvent(roomId: widget.room.id));
                Navigator.pop(context);
                Navigator.pop(context);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Вы покинули комнату'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Покинуть'),
            ),
          ],
        );
      },
    );
  }

  // Используем models.VotingStatus для статуса голосования из модели
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

  String _getVotingStatusText(models.VotingStatus status) {
    switch (status) {
      case models.VotingStatus.active:
        return 'Активно';
      case models.VotingStatus.finished:
        return 'Завершено';
      case models.VotingStatus.cancelled:
        return 'Отменено';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.'
           '${date.month.toString().padLeft(2, '0')}.'
           '${date.year}';
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}