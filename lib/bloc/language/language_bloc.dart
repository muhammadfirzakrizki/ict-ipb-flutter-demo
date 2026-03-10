import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'language_event.dart';

class LanguageBloc extends HydratedBloc<LanguageEvent, Locale> {
  LanguageBloc() : super(const Locale('id')) {
    on<LanguageChanged>((event, emit) {
      emit(event.locale);
    });
  }

  @override
  Locale? fromJson(Map<String, dynamic> json) {
    final code = json['languageCode'] as String?;
    if (code == null || code.isEmpty) {
      return const Locale('id');
    }
    return Locale(code);
  }

  @override
  Map<String, dynamic>? toJson(Locale state) {
    return {'languageCode': state.languageCode};
  }
}
