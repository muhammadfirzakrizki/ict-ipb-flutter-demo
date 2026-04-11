import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/shared_preferences_settings_repository.dart';
import '../domain/app_settings.dart';
import '../domain/settings_repository.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be provided at startup.');
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SharedPreferencesSettingsRepository(
    ref.watch(sharedPreferencesProvider),
  );
});

final settingsControllerProvider =
    NotifierProvider<SettingsController, AppSettings>(
  SettingsController.new,
);

class SettingsController extends Notifier<AppSettings> {
  late final SettingsRepository _settingsRepository;

  @override
  AppSettings build() {
    _settingsRepository = ref.watch(settingsRepositoryProvider);
    _loadPersistedSettings();
    return const AppSettings();
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    state = state.copyWith(themeMode: themeMode);
    await _settingsRepository.saveThemeMode(themeMode);
  }

  Future<void> setDarkMode(bool isDark) {
    return setThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> setLocale(Locale locale) async {
    state = state.copyWith(locale: locale);
    await _settingsRepository.saveLocale(locale);
  }

  Future<void> _loadPersistedSettings() async {
    final results = await Future.wait([
      _settingsRepository.loadLocale(),
      _settingsRepository.loadThemeMode(),
    ]);

    state = AppSettings(
      locale: results[0] as Locale,
      themeMode: results[1] as ThemeMode,
    );
  }
}
