import 'package:flutter/material.dart';

abstract class SettingsRepository {
  Future<Locale> loadLocale();

  Future<void> saveLocale(Locale locale);

  Future<ThemeMode> loadThemeMode();

  Future<void> saveThemeMode(ThemeMode themeMode);
}
