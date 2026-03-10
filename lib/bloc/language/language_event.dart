import 'package:flutter/material.dart';

abstract class LanguageEvent {}

class LanguageChanged extends LanguageEvent {
  final Locale locale;

  LanguageChanged(this.locale);
}
