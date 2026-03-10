import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';
import '../l10n/app_localization.dart';
import '../widgets/app_animations.dart';
import '../widgets/fullscreen_loading_overlay.dart';
import 'home_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> with SingleTickerProviderStateMixin {
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

    context.read<AuthBloc>().add(RegisterRequested(username, email, password));
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

    return Scaffold(
      // AppBar dibuat transparan agar menyatu dengan background vintage
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: colorScheme.primary),
          onPressed: () => Navigator.pop(context),
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
          
          BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthAuthenticated) {
                Navigator.of(context).pushAndRemoveUntil(
                  AppAnimations.pageRoute(const HomePage()),
                  (route) => false,
                );
              } else if (state is AuthError) {
                _showSnackBar(context.tr(state.message));
              }
            },
            builder: (context, state) {
              final isLoading = state is AuthLoading;
              return FadeTransition(
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
                                  _buildInputField(
                                    controller: usernameController,
                                    label: context.tr('username'),
                                    icon: Icons.person_outline_rounded,
                                  ),
                                  const SizedBox(height: 20),
                                  _buildInputField(
                                    controller: emailController,
                                    label: context.tr('email_address'),
                                    icon: Icons.email_outlined,
                                  ),
                                  const SizedBox(height: 20),
                                  _buildInputField(
                                    controller: passwordController,
                                    label: context.tr('password'),
                                    icon: Icons.lock_outline,
                                    isPassword: true,
                                    isVisible: _isPasswordVisible,
                                    onToggle: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                                  ),
                                  const SizedBox(height: 20),
                                  _buildInputField(
                                    controller: confirmPasswordController,
                                    label: context.tr('confirm_password'),
                                    icon: Icons.lock_person_outlined,
                                    isPassword: true,
                                    isVisible: _isConfirmPasswordVisible,
                                    onToggle: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
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
                              onPressed: () => Navigator.pop(context),
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
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool isVisible = false,
    VoidCallback? onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.grey),
        ),
        TextField(
          controller: controller,
          obscureText: isPassword && !isVisible,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20),
            suffixIcon: isPassword
                ? IconButton(icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off), onPressed: onToggle)
                : null,
            enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.black12)),
          ),
        ),
      ],
    );
  }
}
