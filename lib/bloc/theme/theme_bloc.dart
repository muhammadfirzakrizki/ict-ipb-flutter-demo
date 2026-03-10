import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'theme_event.dart';

class ThemeBloc extends HydratedBloc<ThemeEvent, ThemeMode> {
  ThemeBloc() : super(ThemeMode.light) {
    on<ThemeChanged>((event, emit) {
      final newMode = event.isDark ? ThemeMode.dark : ThemeMode.light;
      emit(newMode);
    });

    on<ThemeToggled>((event, emit) {
      emit(state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);
    });
  }

  @override
  ThemeMode? fromJson(Map<String, dynamic> json) {
    final mode = json['mode'] as String?;
    if (mode == 'dark') return ThemeMode.dark;
    if (mode == 'light') return ThemeMode.light;
    return ThemeMode.light;
  }

  @override
  Map<String, dynamic>? toJson(ThemeMode state) {
    return {
      'mode': state == ThemeMode.dark ? 'dark' : 'light',
    };
  }
}
