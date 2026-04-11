import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_localization.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/widgets/core_widgets.dart';
import '../../application/auth_controller.dart';
import '../../domain/auth_state.dart';
import 'auth_input_field.dart';

class RegisterView extends ConsumerStatefulWidget {
  const RegisterView({super.key});

  @override
  ConsumerState<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends ConsumerState<RegisterView>
    with SingleTickerProviderStateMixin {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _submitRegister() {
    final username = usernameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (username.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showSnackBar(context.tr('all_fields_required'));
      return;
    }

    if (password != confirmPassword) {
      _showSnackBar(context.tr('password_not_match'));
      return;
    }

    ref.read(authControllerProvider.notifier).register(
          username,
          email,
          password,
        );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
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
        _showSnackBar(context.tr(next.message));
      }
    });

    return Scaffold(
      // AppBar dibuat transparan agar menyatu dengan background vintage
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: colorScheme.primary),
          onPressed: () => context.pop(),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background dekoratif yang konsisten dengan Login
          Positioned(
            top: -50,
            left: -50,
            child: CircleAvatar(
              radius: 100,
              backgroundColor: colorScheme.primary.withValues(alpha: 0.05),
            ),
          ),
          
          FadeTransition(
                opacity: _fadeAnimation,
                child: Stack(
                  children: [
                    Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Column(
                          children: [
                            // --- HEADER ---
                            Text(
                              context.tr('join_us'),
                              style: theme.textTheme.headlineLarge?.copyWith(
                                letterSpacing: 8,
                                fontSize: 24,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              context.tr('create_account_subtitle'),
                              style: TextStyle(
                                color: colorScheme.secondary,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 40),

                            // --- REGISTER CARD ---
                            FadeSlideIn(
                              begin: const Offset(0, 22),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 420),
                                curve: Curves.easeOutCubic,
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: colorScheme.surface,
                                  borderRadius: BorderRadius.circular(32),
                                  boxShadow: [
                                    BoxShadow(
                                      color: colorScheme.primary.withValues(alpha:0.06),
                                      blurRadius: 30,
                                      offset: const Offset(0, 15),
                                    ),
                                  ],
                                ),
                                child: Column(
                                children: [
                                  AuthInputField(
                                    controller: usernameController,
                                    label: context.tr('username'),
                                    icon: Icons.person_outline_rounded,
                                  ),
                                  const SizedBox(height: 20),
                                  AuthInputField(
                                    controller: emailController,
                                    label: context.tr('email_address'),
                                    icon: Icons.email_outlined,
                                  ),
                                  const SizedBox(height: 20),
                                  AuthInputField(
                                    controller: passwordController,
                                    label: context.tr('password'),
                                    icon: Icons.lock_outline,
                                    isPassword: true,
                                    isVisible: _isPasswordVisible,
                                    onToggleVisibility: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                                  ),
                                  const SizedBox(height: 20),
                                  AuthInputField(
                                    controller: confirmPasswordController,
                                    label: context.tr('confirm_password'),
                                    icon: Icons.lock_person_outlined,
                                    isPassword: true,
                                    isVisible: _isConfirmPasswordVisible,
                                    onToggleVisibility: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                                  ),
                                ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 40),

                            // --- BUTTON ---
                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton(
                                onPressed: isLoading ? null : _submitRegister,
                                child: Text(context.tr('create_account')),
                              ),
                            ),

                            const SizedBox(height: 20),
                            TextButton(
                              onPressed: () => context.pop(),
                              child: Text(
                                context.tr('already_have_account'),
                                style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
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
}
