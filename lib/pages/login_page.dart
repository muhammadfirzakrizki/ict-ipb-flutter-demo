import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/language/language_bloc.dart';
import '../bloc/language/language_event.dart';
import '../l10n/app_localization.dart';
import '../widgets/app_animations.dart';
import '../widgets/fullscreen_loading_overlay.dart';
import 'home_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
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

    return Scaffold(
      // Menggunakan Stack untuk layer background dan konten
      body: Stack(
        children: [
          // 1. Background Dekoratif (Vintage Glow)
          _buildBackgroundDecor(colorScheme),
          Positioned(
            top: 52,
            right: 20,
            child: _buildLanguageSwitcher(context),
          ),

          // 2. Konten Utama
          BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthAuthenticated) {
                Navigator.of(
                  context,
                ).pushReplacement(AppAnimations.pageRoute(const HomePage()));
              } else if (state is AuthError) {
                _showErrorSnackBar(context, context.tr(state.message));
              }
            },
            builder: (context, state) {
              final isLoading = state is AuthLoading;
              return FadeTransition(
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
                              _buildHeader(theme, colorScheme),

                              const SizedBox(height: 40),

                              // --- LOGIN CARD ---
                              _buildLoginCard(colorScheme, state),

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
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSwitcher(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return BlocBuilder<LanguageBloc, Locale>(
      builder: (context, locale) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: colorScheme.surface.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.2),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: locale.languageCode,
              isDense: true,
              borderRadius: BorderRadius.circular(12),
              icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
              items: const [
                DropdownMenuItem(value: 'id', child: Text('ID')),
                DropdownMenuItem(value: 'en', child: Text('EN')),
              ],
              onChanged: (value) {
                if (value == null) return;
                context.read<LanguageBloc>().add(
                  LanguageChanged(Locale(value)),
                );
              },
            ),
          ),
        );
      },
    );
  }

  // --- WIDGET HELPER SECTIONS ---

  Widget _buildBackgroundDecor(ColorScheme colorScheme) {
    return Stack(
      children: [
        Positioned(
          top: -60,
          left: -60,
          child: CircleAvatar(
            radius: 120,
            backgroundColor: colorScheme.primary.withValues(alpha: 0.07),
          ),
        ),
        Positioned(
          bottom: -80,
          right: -40,
          child: CircleAvatar(
            radius: 150,
            backgroundColor: colorScheme.secondary.withValues(alpha: 0.05),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      children: [
        // Mengganti Icon dengan Logo IPB
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Image.asset(
            'assets/images/ict_ipb_logo.png', // Sesuaikan dengan nama file Anda
            height: 100, // Ukuran logo
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          "IPB UNIVERSITY",
          style: theme.textTheme.headlineLarge?.copyWith(
            letterSpacing: 6,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 2,
          width: 30,
          decoration: BoxDecoration(
            color: colorScheme.secondary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
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
            _customTextField(
              controller: emailController,
              label: context.tr('email_address'),
              icon: Icons.alternate_email_rounded,
            ),
            const SizedBox(height: 24),
            _customTextField(
              controller: passwordController,
              label: context.tr('password'),
              icon: Icons.lock_outline_rounded,
              isPassword: true,
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
                        context.read<AuthBloc>().add(
                          LoginRequested(
                            emailController.text,
                            passwordController.text,
                          ),
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

  Widget _customTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: Colors.grey,
          ),
        ),
        TextField(
          controller: controller,
          obscureText: isPassword && !_isPasswordVisible,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () => setState(
                      () => _isPasswordVisible = !_isPasswordVisible,
                    ),
                  )
                : null,
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterLink(ThemeData theme, ColorScheme colorScheme) {
    return TextButton(
      onPressed: () {
        Navigator.of(
          context,
        ).push(AppAnimations.pageRoute(const RegisterPage()));
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
