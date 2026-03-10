import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/language/language_bloc.dart';
import '../bloc/language/language_event.dart';
import '../bloc/theme/theme_bloc.dart';
import '../bloc/theme/theme_event.dart';
import '../l10n/app_localization.dart';
import '../widgets/app_animations.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageBloc, Locale>(
      builder: (context, locale) {
        return BlocBuilder<ThemeBloc, ThemeMode>(
          builder: (context, themeMode) {
            final theme = Theme.of(context);
            final colorScheme = theme.colorScheme;
            final isDark = themeMode == ThemeMode.dark;
            final isIndonesian = locale.languageCode == 'id';

            return Scaffold(
              appBar: AppBar(
                title: Text(context.tr('settings').toUpperCase()),
                centerTitle: true,
              ),
              body: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(
                    context.tr('appearance'),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 15),
                  FadeSlideIn(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 420),
                      curve: Curves.easeOutCubic,
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.shadow.withValues(
                              alpha: isDark ? 0.2 : 0.07,
                            ),
                            blurRadius: 12,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(
                            alpha: isDark ? 0.24 : 0.12,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isDark
                              ? Icons.dark_mode_rounded
                              : Icons.light_mode_rounded,
                          color: colorScheme.primary,
                        ),
                      ),
                      title: Text(
                        context.tr('dark_mode'),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        isDark
                            ? context.tr('theme_current_dark')
                            : context.tr('theme_current_light'),
                        style: theme.textTheme.bodySmall,
                      ),
                      trailing: Switch.adaptive(
                        value: isDark,
                        onChanged: (value) {
                          context.read<ThemeBloc>().add(ThemeChanged(value));
                        },
                      ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  FadeSlideIn(
                    begin: const Offset(0, 24),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 420),
                      curve: Curves.easeOutCubic,
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.shadow.withValues(
                              alpha: isDark ? 0.2 : 0.07,
                            ),
                            blurRadius: 12,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.language_rounded,
                          color: colorScheme.primary,
                        ),
                      ),
                      title: Text(
                        context.tr('language'),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        isIndonesian
                            ? context.tr('language_current_id')
                            : context.tr('language_current_en'),
                        style: theme.textTheme.bodySmall,
                      ),
                      trailing: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: locale.languageCode,
                          borderRadius: BorderRadius.circular(12),
                          items: [
                            DropdownMenuItem(
                              value: 'id',
                              child: Text(context.tr('indonesian')),
                            ),
                            DropdownMenuItem(
                              value: 'en',
                              child: Text(context.tr('english')),
                            ),
                          ],
                          onChanged: (value) {
                            if (value == null) return;
                            context.read<LanguageBloc>().add(
                              LanguageChanged(Locale(value)),
                            );
                          },
                        ),
                      ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: Text(
                      context.tr('app_version'),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
