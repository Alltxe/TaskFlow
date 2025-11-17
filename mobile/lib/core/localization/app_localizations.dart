import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ManualAppLocalizations {
  final Locale locale;
  ManualAppLocalizations(this.locale);

  static ManualAppLocalizations of(BuildContext context) {
    final result = Localizations.of<ManualAppLocalizations>(context, ManualAppLocalizations);
    if (result == null) throw FlutterError('ManualAppLocalizations not found in context');
    return result;
  }

  static const LocalizationsDelegate<ManualAppLocalizations> delegate =
      _ManualAppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedStrings = {
    'ru': {
      'appTitle': 'TaskFlow',
      'ok': 'ОК',
      'cancel': 'Отмена',
      'yes': 'Да',
      'no': 'Нет',
      'loading': 'Загрузка...',
    },
    'en': {
      'appTitle': 'TaskFlow',
      'ok': 'OK',
      'cancel': 'Cancel',
      'yes': 'Yes',
      'no': 'No',
      'loading': 'Loading...',
    },
  };

  String translate(String key) {
    return _localizedStrings[locale.languageCode]?[key] ?? _localizedStrings['ru']?[key] ?? key;
  }

  String get appTitle => translate('appTitle');
}

class _ManualAppLocalizationsDelegate extends LocalizationsDelegate<ManualAppLocalizations> {
  const _ManualAppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['ru', 'en'].contains(locale.languageCode);

  @override
  Future<ManualAppLocalizations> load(Locale locale) {
    // SynchronousFuture is fine here because loading is immediate from memory
    return SynchronousFuture<ManualAppLocalizations>(ManualAppLocalizations(locale));
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<ManualAppLocalizations> old) => false;
}
