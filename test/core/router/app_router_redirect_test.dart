import 'package:flutter_test/flutter_test.dart';
import 'package:ipbict_test/core/router/app_router.dart';
import 'package:ipbict_test/core/router/app_routes.dart';
import 'package:ipbict_test/features/auth/domain/auth_state.dart';

void main() {
  group('authRedirect', () {
    test('redirects unauthenticated user from protected route to login', () {
      final result = authRedirect(const AuthUnauthenticated(), AppRoutes.home);
      expect(result, AppRoutes.login);
    });

    test('allows unauthenticated user on auth routes', () {
      final loginResult = authRedirect(
        const AuthUnauthenticated(),
        AppRoutes.login,
      );
      final registerResult = authRedirect(
        const AuthUnauthenticated(),
        AppRoutes.register,
      );

      expect(loginResult, isNull);
      expect(registerResult, isNull);
    });

    test('redirects authenticated user away from login/register to home', () {
      final loginResult = authRedirect(
        const AuthAuthenticated(),
        AppRoutes.login,
      );
      final registerResult = authRedirect(
        const AuthAuthenticated(),
        AppRoutes.register,
      );

      expect(loginResult, AppRoutes.home);
      expect(registerResult, AppRoutes.home);
    });

    test('keeps authenticated user on protected route', () {
      final result = authRedirect(const AuthAuthenticated(), AppRoutes.settings);
      expect(result, isNull);
    });

    test('treats auth error as unauthenticated', () {
      final result = authRedirect(
        const AuthError('auth_unknown_error'),
        AppRoutes.profile,
      );
      expect(result, AppRoutes.login);
    });

    test('does not force redirect during loading state', () {
      final result = authRedirect(const AuthLoading(), AppRoutes.home);
      expect(result, isNull);
    });
  });
}
