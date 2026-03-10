import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/weather/weather_bloc.dart';
import '../bloc/weather/weather_event.dart';
import '../bloc/weather/weather_state.dart';
import '../l10n/app_localization.dart';
import '../models/location_option.dart';
import '../services/weather_service.dart';
import '../widgets/app_animations.dart';
import '../widgets/fullscreen_loading_overlay.dart';
import 'login_page.dart';
import 'profile_page.dart';
import 'setting_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(BuildContext context, String query) {
    _debounce?.cancel();
    if (query.length < 3) return;

    _debounce = Timer(const Duration(milliseconds: 600), () {
      context.read<WeatherBloc>().add(WeatherQueryChanged(query));
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return BlocProvider(
      create: (_) => WeatherBloc(weatherService: WeatherService()),
      child: Scaffold(
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
          actions: [_buildPopupMenu(context)],
        ),
        body: MultiBlocListener(
          listeners: [
            BlocListener<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is AuthUnauthenticated) {
                  Navigator.of(context).pushReplacement(
                    AppAnimations.pageRoute(const LoginPage()),
                  );
                }
              },
            ),
          ],
          child: BlocBuilder<WeatherBloc, WeatherState>(
            builder: (context, state) {
              return Stack(
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
                            _buildHeader(colorScheme, isDark, theme),

                            // 2. SearchBar diposisikan menempel di bawah header
                            Positioned(
                              left: 20,
                              right: 20,
                              bottom:
                                  -25, // Membuatnya "mengambang" di antara header dan body
                              child: _buildSearchBar(context, state, colorScheme),
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
                                state.weather == null
                                    ? 'empty'
                                    : '${state.weather!.weatherCode}-${state.selectedLocation?.label}',
                              ),
                              child: _buildWeatherCard(
                                state,
                                theme,
                                colorScheme,
                                isDark,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                  FullScreenLoadingOverlay(visible: state.isLoadingWeather),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme, bool isDark, ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(25, 120, 25, 80),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colorScheme.primary, colorScheme.primary.withBlue(200)],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr('welcome'),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          StreamBuilder<User?>(
            stream: FirebaseAuth.instance.userChanges(),
            builder: (context, snapshot) {
              final user = snapshot.data ?? FirebaseAuth.instance.currentUser;
              final headerName = user?.displayName?.trim().isNotEmpty == true
                  ? user!.displayName!
                  : (user?.email?.split('@').first ?? context.tr('default_user'));

              return Text(
                headerName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(
    BuildContext context,
    WeatherState state,
    ColorScheme colorScheme,
  ) {
    return FadeSlideIn(
      begin: const Offset(0, 18),
      child: Container(
        // Gunakan margin agar bayangan tidak terpotong dan area klik jelas
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        // Bungkus dengan Material agar efek ripple (cipratan klik) muncul
        child: Material(
          color: Colors.transparent,
          child: Autocomplete<LocationOption>(
          displayStringForOption: (option) => option.label,
          optionsBuilder: (textEditingValue) {
            _onSearchChanged(context, textEditingValue.text);
            return textEditingValue.text.isEmpty
                ? const Iterable<LocationOption>.empty()
                : state.suggestions;
          },
          onSelected: (option) =>
              context.read<WeatherBloc>().add(WeatherLocationSelected(option)),
          // Bagian Krusial: Pastikan fieldViewBuilder menangani Focus & Klik
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            return TextField(
              controller: controller,
              focusNode: focusNode,
              style: const TextStyle(fontWeight: FontWeight.w600),
              // Tambahkan onTap agar saat di-klik di area manapun dalam bar, field langsung aktif
              onTap: () {
                if (!focusNode.hasFocus) {
                  focusNode.requestFocus();
                }
              },
              decoration: InputDecoration(
                hintText: context.tr('search_hint'),
                hintStyle: TextStyle(color: Colors.grey.withValues(alpha: 0.6)),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: colorScheme.primary,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                // Gunakan contentPadding yang proporsional
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                suffixIcon: controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 20),
                        onPressed: () => controller.clear(),
                      )
                    : null,
              ),
            );
          },
          // Opsional: Atur lebar dropdown agar pas dengan bar
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(15),
                child: SizedBox(
                  width:
                      MediaQuery.of(context).size.width -
                      40, // Lebar dikurangi padding luar
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final option = options.elementAt(index);
                      return ListTile(
                        title: Text(
                          option.label,
                          style: const TextStyle(fontSize: 14),
                        ),
                        onTap: () => onSelected(option),
                      );
                    },
                  ),
                ),
              ),
            );
          },
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherCard(
    WeatherState state,
    ThemeData theme,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    if (state.weather == null) {
      return _buildEmptyCard(colorScheme);
    }

    final weather = state.weather!;
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.08),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.selectedLocation?.label.split(',')[0] ?? '',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: colorScheme.primary,
                    ),
                  ),
                  Text(
                    context.tr('current_condition'),
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              _buildWeatherBadge(weather, colorScheme),
            ],
          ),
          const SizedBox(height: 35),

          // Temperature Display
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                weather.temperatureC.toStringAsFixed(0),
                style: TextStyle(
                  fontSize: 100,
                  fontWeight: FontWeight.w900,
                  color: colorScheme.primary,
                  height: 1,
                  letterSpacing: -5,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Text(
                  '°',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.secondary,
                  ),
                ),
              ),
            ],
          ),

          Text(
            _localizedWeatherDescription(context, weather.weatherDescription)
                .toUpperCase(),
            style: TextStyle(
              letterSpacing: 4,
              fontWeight: FontWeight.w900,
              color: colorScheme.secondary,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 35),

          // Detail Grid
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildModernDetail(
                  Icons.water_drop_rounded,
                  '${weather.humidity}%',
                  'RH',
                  Colors.blue,
                ),
                _buildModernDetail(
                  Icons.air_rounded,
                  weather.windSpeedKmh.toStringAsFixed(1),
                  'KM/H',
                  Colors.teal,
                ),
                _buildModernDetail(
                  Icons.speed_rounded,
                  weather.pressureMb.toStringAsFixed(0),
                  'HPA',
                  Colors.orange,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherBadge(dynamic weather, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.secondary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(
            weather.isDay ? Icons.wb_sunny_rounded : Icons.nightlight_round,
            color: colorScheme.secondary,
            size: 18,
          ),
          const SizedBox(width: 6),
          Text(
            weather.isDay ? context.tr('day') : context.tr('night'),
            style: TextStyle(
              color: colorScheme.secondary,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernDetail(
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, size: 24, color: color),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  String _localizedWeatherDescription(
    BuildContext context,
    String description,
  ) {
    if (Localizations.localeOf(context).languageCode != 'id') {
      return description;
    }

    const translated = {
      'sunny': 'Cerah',
      'clear': 'Cerah',
      'partly cloudy': 'Cerah Berawan',
      'cloudy': 'Berawan',
      'overcast': 'Mendung',
      'mist': 'Berkabut',
      'fog': 'Kabut',
      'freezing fog': 'Kabut Beku',
      'rain': 'Hujan',
      'patchy rain possible': 'Kemungkinan Hujan Lokal',
      'light rain': 'Hujan Ringan',
      'moderate rain': 'Hujan Sedang',
      'heavy rain': 'Hujan Lebat',
      'light drizzle': 'Gerimis Ringan',
      'drizzle': 'Gerimis',
      'thunderstorm': 'Badai Petir',
      'thundery outbreaks possible': 'Potensi Badai Petir',
      'patchy light rain with thunder': 'Hujan Ringan Petir Lokal',
      'moderate or heavy rain with thunder': 'Hujan Petir Sedang Hingga Lebat',
      'patchy snow possible': 'Kemungkinan Salju Lokal',
      'light snow': 'Salju Ringan',
      'moderate snow': 'Salju Sedang',
      'heavy snow': 'Salju Lebat',
      'unknown weather': 'Cuaca Tidak Diketahui',
    };

    final key = description.trim().toLowerCase();
    return translated[key] ?? description;
  }

  Widget _buildPopupMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      onSelected: (value) {
        if (value == 'logout') {
          context.read<AuthBloc>().add(LogoutRequested());
        } else if (value == 'info') {
          Navigator.push(
            context,
            AppAnimations.pageRoute(const ProfilePage()),
          );
        } else if (value == 'settings') {
          Navigator.push(
            context,
            AppAnimations.pageRoute(const SettingPage()),
          );
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'info',
          child: ListTile(
            leading: const Icon(Icons.person_outline),
            title: Text(context.tr('profile')),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        PopupMenuItem(
          value:
              'settings', // Pastikan ini sama dengan pengecekan di onSelected
          child: ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: Text(context.tr('settings_menu')),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const PopupMenuDivider(), // Tambahkan divider agar lebih rapi
        PopupMenuItem(
          value: 'logout',
          child: ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: Text(
              context.tr('logout'),
              style: const TextStyle(color: Colors.red),
            ),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyCard(ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        children: [
          const Icon(Icons.location_on_outlined, size: 50, color: Colors.grey),
          const SizedBox(height: 10),
          Text(
            context.tr('search_empty'),
            style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
