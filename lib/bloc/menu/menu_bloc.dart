import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'menu_event.dart';
part 'menu_state.dart';

class MenuBloc extends Bloc<MenuEvent, MenuState> {
  MenuBloc() : super(const MenuState()) {
    on<LoadMenuEvent>(_onLoadMenu);
    on<SelectMenuItemEvent>(_onSelectMenuItem);
    on<LogoutEvent>(_onLogout);
  }

  Future<void> _onLoadMenu(
    LoadMenuEvent event,
    Emitter<MenuState> emit,
  ) async {
    emit(state.copyWith(status: MenuStatus.loading));
    
    try {
      // Загружаем пункты меню (можно заменить на загрузку из API или базы данных)
      await Future.delayed(const Duration(milliseconds: 500)); // Симуляция загрузки
      
      final menuItems = [
        {'id': '1', 'title': 'Главная', 'screen': 'Home', 'icon': 'home'},
        {'id': '2', 'title': 'Профиль', 'screen': 'Profile', 'icon': 'person'},
        {'id': '3', 'title': 'Настройки', 'screen': 'Settings', 'icon': 'settings'},
        {'id': '4', 'title': 'Помощь', 'screen': 'Help', 'icon': 'help'},
      ];
      
      emit(state.copyWith(
        status: MenuStatus.loaded,
        menuItems: menuItems,
        currentScreen: 'Home',
        selectedItemId: '1',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: MenuStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onSelectMenuItem(
    SelectMenuItemEvent event,
    Emitter<MenuState> emit,
  ) {
    emit(state.copyWith(
      currentScreen: event.screenName,
      selectedItemId: event.itemId,
      status: MenuStatus.loaded,
    ));
  }

  void _onLogout(
    LogoutEvent event,
    Emitter<MenuState> emit,
  ) {
    // Сбрасываем состояние при выходе
    emit(const MenuState(
      status: MenuStatus.initial,
      currentScreen: 'Home',
    ));
  }
}