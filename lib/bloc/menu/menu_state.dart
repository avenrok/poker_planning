part of 'menu_bloc.dart';

enum MenuStatus { initial, loading, loaded, error }

class MenuState extends Equatable {
  final MenuStatus status;
  final List<Map<String, String>> menuItems;
  final String currentScreen;
  final String? selectedItemId;
  final String? errorMessage;

  const MenuState({
    this.status = MenuStatus.initial,
    this.menuItems = const [],
    this.currentScreen = 'Home',
    this.selectedItemId,
    this.errorMessage,
  });

  MenuState copyWith({
    MenuStatus? status,
    List<Map<String, String>>? menuItems,
    String? currentScreen,
    String? selectedItemId,
    String? errorMessage,
  }) {
    return MenuState(
      status: status ?? this.status,
      menuItems: menuItems ?? this.menuItems,
      currentScreen: currentScreen ?? this.currentScreen,
      selectedItemId: selectedItemId ?? this.selectedItemId,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status, 
    menuItems, 
    currentScreen, 
    selectedItemId, 
    errorMessage
  ];
}