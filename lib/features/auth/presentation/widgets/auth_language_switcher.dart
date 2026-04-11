import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../settings/application/settings_controller.dart';

class AuthLanguageSwitcher extends ConsumerWidget {
  const AuthLanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final locale = ref.watch(settingsControllerProvider).locale;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: locale.languageCode,
          isDense: true,
          borderRadius: BorderRadius.circular(12),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
          items: const [
            DropdownMenuItem(value: 'id', child: Text('ID')),
            DropdownMenuItem(value: 'en', child: Text('EN')),
          ],
          onChanged: (value) {
            if (value == null) return;
            ref.read(settingsControllerProvider.notifier).setLocale(
                  Locale(value),
                );
          },
        ),
      ),
    );
  }
}
