import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_localization.dart';
import '../../../../core/widgets/core_widgets.dart';
import '../../application/weather_controller.dart';
import 'dashboard_header.dart';
import 'dashboard_menu.dart';
import 'weather_card.dart';
import 'weather_search_bar.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  Timer? _debounce;
  String _lastQuery = '';

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (query == _lastQuery) return;
    final isDeleting = query.length < _lastQuery.length;
    _lastQuery = query;

    _debounce?.cancel();

    if (query.trim().length < 2) {
      ref.read(weatherControllerProvider.notifier).queryChanged(query);
      return;
    }

    final debounceDuration = isDeleting
        ? const Duration(milliseconds: 120)
        : const Duration(milliseconds: 250);

    _debounce = Timer(debounceDuration, () {
      ref.read(weatherControllerProvider.notifier).queryChanged(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final weatherState = ref.watch(weatherControllerProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          context.tr('dashboard'),
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 14,
            letterSpacing: 2,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
        actions: const [DashboardMenu()],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    DashboardHeader(colorScheme: colorScheme),
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: -25,
                      child: WeatherSearchBar(
                        state: weatherState,
                        colorScheme: colorScheme,
                        onQueryChanged: _onSearchChanged,
                        onLocationSelected: (option) => ref
                            .read(weatherControllerProvider.notifier)
                            .locationSelected(option),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 50),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 560),
                    reverseDuration: const Duration(milliseconds: 320),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(
                          scale: Tween<double>(
                            begin: 0.96,
                            end: 1,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: KeyedSubtree(
                      key: ValueKey(
                        weatherState.weather == null
                            ? 'empty'
                            : '${weatherState.weather!.weatherCode}-${weatherState.selectedLocation?.label}',
                      ),
                      child: WeatherCard(
                        state: weatherState,
                        colorScheme: colorScheme,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          FullScreenLoadingOverlay(visible: weatherState.isLoadingWeather),
        ],
      ),
    );
  }
}
