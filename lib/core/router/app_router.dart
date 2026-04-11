import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/domain/auth_state.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/profile_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/settings/presentation/pages/setting_page.dart';
import '../../features/weather/presentation/pages/home_page.dart';
import 'app_routes.dart';
import 'router_notifier.dart';

class AppRouter {
  AppRouter._({
    required this.router,
    required this.routerNotifier,
  });

  final GoRouter router;
  final RouterNotifier routerNotifier;

  static AppRouter? _instance;

  static AppRouter initialize(ProviderContainer container) {
    if (_instance != null) return _instance!;

    final notifier = RouterNotifier(container);
    final router = GoRouter(
      initialLocation: AppRoutes.home,
      refreshListenable: notifier,
      redirect: (context, state) {
        return authRedirect(notifier.authState, state.matchedLocation);
      },
      routes: [
        GoRoute(
          path: AppRoutes.home,
          builder: (context, state) => const HomePage(),
        ),
        GoRoute(
          path: AppRoutes.login,
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: AppRoutes.register,
          builder: (context, state) => const RegisterPage(),
        ),
        GoRoute(
          path: AppRoutes.profile,
          builder: (context, state) => const ProfilePage(),
        ),
        GoRoute(
          path: AppRoutes.settings,
          builder: (context, state) => const SettingPage(),
        ),
      ],
    );

    _instance = AppRouter._(router: router, routerNotifier: notifier);
    return _instance!;
  }

  static AppRouter get instance {
    final appRouter = _instance;
    if (appRouter == null) {
      throw StateError('AppRouter is not initialized.');
    }
    return appRouter;
  }
}

String? authRedirect(AuthState authState, String location) {
  final isAuthRoute =
      location == AppRoutes.login || location == AppRoutes.register;
  final isAuthenticated = authState is AuthAuthenticated;
  final isUnauthenticated =
      authState is AuthUnauthenticated || authState is AuthError;

  if (isAuthenticated && isAuthRoute) {
    return AppRoutes.home;
  }

  if (isUnauthenticated && !isAuthRoute) {
    return AppRoutes.login;
  }

  // Keep current location while state is transitional (initial/loading)
  // to avoid redirect race conditions.
  return null;
}
