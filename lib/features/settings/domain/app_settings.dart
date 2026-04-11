import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class AppSettings extends Equatable {
  const AppSettings({
    this.locale = const Locale('id'),
    this.themeMode = ThemeMode.light,
  });

  final Locale locale;
  final ThemeMode themeMode;

  bool get isDark => themeMode == ThemeMode.dark;

  AppSettings copyWith({
    Locale? locale,
    ThemeMode? themeMode,
  }) {
    return AppSettings(
      locale: locale ?? this.locale,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  @override
  List<Object?> get props => [locale, themeMode];
}
