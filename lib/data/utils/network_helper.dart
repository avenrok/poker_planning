import 'dart:io' show NetworkInterface, InternetAddressType, Socket;

import 'package:flutter/foundation.dart' show kIsWeb;

class NetworkHelper {
  static Future<String> getLocalIpAddress() async {
    // В вебе возвращаем localhost
    if (kIsWeb) {
      return 'localhost';
    }
    
    // На мобильных платформах пытаемся получить реальный IP
    try {
      for (var interface in await NetworkInterface.list()) {
        for (var addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
            return addr.address;
          }
        }
      }
    } catch (e) {
      print('Error getting local IP: $e');
    }
    return 'localhost'; // Значение по умолчанию
  }

  static Future<bool> isLocalServerReachable(String ip, int port) async {
    // В вебе всегда возвращаем true для теста
    if (kIsWeb) {
      return true;
    }
    
    try {
      final socket = await Socket.connect(ip, port, timeout: const Duration(seconds: 2));
      socket.destroy();
      return true;
    } catch (e) {
      return false;
    }
  }
}