import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_localization.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/core_widgets.dart';
import '../../../auth/application/auth_controller.dart';
import '../../../auth/domain/auth_state.dart';
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

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    if (query.length < 3) return;

    _debounce = Timer(const Duration(milliseconds: 600), () {
      ref.read(weatherControllerProvider.notifier).queryChanged(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final weatherState = ref.watch(weatherControllerProvider);

    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (next is AuthUnauthenticated) {
        context.go(AppRoutes.login);
      }
    });

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
            // Agar area klik stabil, kita hilangkan Transform.translate
            child: Column(
              children: [
                // Menggunakan Stack untuk Header dan SearchBar
                Stack(
                  clipBehavior: Clip
                      .none, // Agar SearchBar yang meluncur ke bawah tidak terpotong
                  children: [
                    // 1. Header Blue Gradient
                    DashboardHeader(colorScheme: colorScheme),

                    // 2. SearchBar diposisikan menempel di bawah header
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom:
                          -25, // Membuatnya "mengambang" di antara header dan body
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

                // 3. Memberi jarak (SizedBox) karena SearchBar ditaruh di Positioned
                const SizedBox(height: 50),

                // 4. Bagian Weather Card
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
