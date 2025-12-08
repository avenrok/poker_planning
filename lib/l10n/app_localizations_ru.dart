// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get loginTitle => 'Вход';

  @override
  String get loginHint => 'Введите имя пользователя';

  @override
  String get loginButton => 'Войти';
}
