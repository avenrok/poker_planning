part of 'menu_bloc.dart';

abstract class MenuEvent extends Equatable {
  const MenuEvent();

  @override
  List<Object> get props => [];
}

// Событие загрузки меню
class LoadMenuEvent extends MenuEvent {}

// Событие выбора пункта меню
class SelectMenuItemEvent extends MenuEvent {
  final String itemId;
  final String screenName;

  const SelectMenuItemEvent({
    required this.itemId,
    required this.screenName,
  });

  @override
  List<Object> get props => [itemId, screenName];
}

// Событие выхода из аккаунта
class LogoutEvent extends MenuEvent {}