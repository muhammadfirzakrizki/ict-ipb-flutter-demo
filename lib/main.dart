import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
// Import paket splash screen
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'firebase_options.dart';
import 'bloc/auth/auth_bloc.dart';
import 'bloc/auth/auth_state.dart';
import 'bloc/language/language_bloc.dart';
import 'bloc/theme/theme_bloc.dart';
import 'services/auth_service.dart';
import 'l10n/app_localization.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'theme/app_theme.dart';

void main() async {
  // 1. Inisialisasi binding dan simpan dalam variabel
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // 2. Tahan splash screen agar tidak langsung hilang
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Inisialisasi Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Inisialisasi Storage untuk BLoC
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorageDirectory.web
        : HydratedStorageDirectory((await getTemporaryDirectory()).path),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthBloc(authService: AuthService())),
        BlocProvider(create: (context) => ThemeBloc()),
        BlocProvider(create: (context) => LanguageBloc()),
      ],
      child: BlocBuilder<LanguageBloc, Locale>(
        builder: (context, locale) {
          return BlocBuilder<ThemeBloc, ThemeMode>(
            builder: (context, themeMode) {
              return MaterialApp(
                title: 'IPB ICT Mini Project',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeMode,
                themeAnimationDuration: const Duration(milliseconds: 450),
                themeAnimationCurve: Curves.easeOutCubic,
                locale: locale,
                supportedLocales: AppLocalization.supportedLocales,
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                // Gunakan BlocListener untuk menghapus splash screen setelah inisialisasi selesai
                home: BlocListener<AuthBloc, AuthState>(
                  listener: (context, state) {
                    // 3. Hapus splash screen segera setelah status Auth diketahui
                    FlutterNativeSplash.remove();
                  },
                  child: BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, authState) {
                      if (authState is AuthAuthenticated) {
                        return const HomePage();
                      }
                      // Jika belum login atau loading, tampilkan LoginPage
                      return const LoginPage();
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
