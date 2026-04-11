import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_localization.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/core_widgets.dart';
import '../../application/auth_controller.dart';
import '../../domain/auth_state.dart';
import 'auth_background_decor.dart';
import 'auth_brand_header.dart';
import 'auth_input_field.dart';
import 'auth_language_switcher.dart';

class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView>
    with SingleTickerProviderStateMixin {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  // Animasi Variabel
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    // Inisialisasi Controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Animasi Muncul (Fade)
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    // Animasi Bergeser (Slide Up)
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    // Jalankan animasi
    _controller.forward();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    _controller.dispose(); // Wajib di-dispose agar tidak memory leak
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState is AuthLoading;

    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (next is AuthAuthenticated) {
        context.go(AppRoutes.home);
      } else if (next is AuthError) {
        _showErrorSnackBar(context, context.tr(next.message));
      }
    });

    return Scaffold(
      // Menggunakan Stack untuk layer background dan konten
      body: Stack(
        children: [
          // 1. Background Dekoratif (Vintage Glow)
          AuthBackgroundDecor(colorScheme: colorScheme),
          Positioned(
            top: 52,
            right: 20,
            child: AuthLanguageSwitcher(),
          ),

          // 2. Konten Utama
          FadeTransition(
                opacity: _fadeAnimation,
                child: Stack(
                  children: [
                    SlideTransition(
                      position: _slideAnimation,
                      child: Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 32.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // --- LOGO AREA ---
                              AuthBrandHeader(
                                theme: theme,
                                colorScheme: colorScheme,
                              ),

                              const SizedBox(height: 40),

                              // --- LOGIN CARD ---
                              _buildLoginCard(colorScheme, authState),

                              const SizedBox(height: 32),

                              // --- REGISTER LINK ---
                              _buildRegisterLink(theme, colorScheme),
                            ],
                          ),
                        ),
                      ),
                    ),
                    FullScreenLoadingOverlay(visible: isLoading),
                  ],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginCard(ColorScheme colorScheme, AuthState state) {
    bool isLoading = state is AuthLoading;

    return FadeSlideIn(
      begin: const Offset(0, 20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: colorScheme.primary.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.06),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Column(
          children: [
            AuthInputField(
              controller: emailController,
              label: context.tr('email_address'),
              icon: Icons.alternate_email_rounded,
              focusedBorderColor: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            AuthInputField(
              controller: passwordController,
              label: context.tr('password'),
              icon: Icons.lock_outline_rounded,
              isPassword: true,
              isVisible: _isPasswordVisible,
              onToggleVisibility: () => setState(
                () => _isPasswordVisible = !_isPasswordVisible,
              ),
              focusedBorderColor: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 32),

            // Tombol Masuk dengan Animasi Loading
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () {
                        ref.read(authControllerProvider.notifier).login(
                            emailController.text,
                            passwordController.text,
                        );
                      },
                style: ElevatedButton.styleFrom(
                  // --- WARNA MODERN VINTAGE ---
                  backgroundColor: const Color(
                    0xFF004D91,
                  ), // Charcoal (Vintage Dark)
                  foregroundColor: const Color(
                    0xFFF5F2ED,
                  ), // Warm Cream (Pengganti putih)
                  disabledBackgroundColor: const Color(
                    0xFF2C2C2C,
                  ).withValues(alpha: 0.6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      12,
                    ), // Sedikit rounded agar modern
                  ),
                  elevation: 2,
                ),
                child: Text(
                  context.tr('sign_in'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1, // Memberikan kesan tipografi premium
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterLink(ThemeData theme, ColorScheme colorScheme) {
    return TextButton(
      onPressed: () {
        context.push(AppRoutes.register);
      },
      child: RichText(
        text: TextSpan(
          style: theme.textTheme.bodyMedium,
          children: [
            TextSpan(text: context.tr('dont_have_account')),
            TextSpan(
              text: context.tr('register'),
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
