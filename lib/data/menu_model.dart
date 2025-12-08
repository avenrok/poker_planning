import 'package:flutter/material.dart';

class MenuModel extends ChangeNotifier {
  String _currentScreen = 'Home';

  String get currentScreen => _currentScreen;

  void updateScreen(String newScreen) {
    _currentScreen = newScreen;
    notifyListeners(); 
  }
}