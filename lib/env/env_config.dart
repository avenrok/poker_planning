import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static String get apiBaseUrl => dotenv.get('API_BASE_URL');
  static String get websocketUrl => dotenv.get('WEBSOCKET_URL');
  static String get localNetworkIp => dotenv.get('LOCAL_NETWORK_IP');
  static String get localNetworkPort => dotenv.get('LOCAL_NETWORK_PORT');
  static String get appName => dotenv.get('APP_NAME');
  static String get appVersion => dotenv.get('APP_VERSION');
  
  static String get localNetworkUrl => 'http://$localNetworkIp:$localNetworkPort';
  
  static Future<void> load() async {
    await dotenv.load(fileName: ".env");
  }
}