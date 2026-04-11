import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/application/auth_controller.dart';
import '../../features/auth/domain/auth_state.dart';

class RouterNotifier extends ChangeNotifier {
  RouterNotifier(this._container) {
    _authSubscription = _container.listen<AuthState>(
      authControllerProvider,
      (previous, next) {
        if (previous != next) {
          notifyListeners();
        }
      },
      fireImmediately: true,
    );
  }

  final ProviderContainer _container;
  late final ProviderSubscription<AuthState> _authSubscription;

  AuthState get authState => _container.read(authControllerProvider);

  @override
  void dispose() {
    _authSubscription.close();
    super.dispose();
  }
}
