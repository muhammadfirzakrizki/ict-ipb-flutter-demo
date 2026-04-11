import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/settings_repository.dart';

class SharedPreferencesSettingsRepository implements SettingsRepository {
  SharedPreferencesSettingsRepository(this._preferences);

  static const _localeKey = 'settings.locale';
  static const _themeModeKey = 'settings.themeMode';

  final SharedPreferences _preferences;

  @override
  Future<Locale> loadLocale() async {
    final languageCode = _preferences.getString(_localeKey);
    if (languageCode == null || languageCode.isEmpty) {
      return const Locale('id');
    }
    return Locale(languageCode);
  }

  @override
  Future<void> saveLocale(Locale locale) async {
    await _preferences.setString(_localeKey, locale.languageCode);
  }

  @override
  Future<ThemeMode> loadThemeMode() async {
    final value = _preferences.getString(_themeModeKey);
    return value == 'dark' ? ThemeMode.dark : ThemeMode.light;
  }

  @override
  Future<void> saveThemeMode(ThemeMode themeMode) async {
    await _preferences.setString(
      _themeModeKey,
      themeMode == ThemeMode.dark ? 'dark' : 'light',
    );
  }
}
