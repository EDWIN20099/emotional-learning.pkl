import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Email dan password wajib diisi ya! ✨',
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF5C6BC0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response =
          await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;

      if (response.user != null) {
        Navigator.pushReplacementNamed(
          context,
          '/loading',
        );
      }
    } on AuthException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFFE57373),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFFE57373),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Color(0xFF98A8C7),
      ),
      floatingLabelStyle: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        color: Color(0xFFFFC107),
      ),
      prefixIcon: Icon(
        icon,
        color: const Color(0xFFFFC107),
        size: 21,
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFFFF9C4),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 17,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: Color(0xFFFFE082),
          width: 1.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: Color(0xFFFFC107),
          width: 2,
        ),
      ),
    );
  }

  Widget _buildBackground() {
    return Stack(
      children: [
        Positioned(
          top: -90,
          left: -80,
          child: Container(
            width: 230,
            height: 230,
            decoration: BoxDecoration(
              color: const Color(0xFFFFD966).withValues(alpha: 0.40),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          top: -30,
          right: -40,
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: const Color(0xFFA8E6CF).withValues(alpha: 0.50),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          bottom: -100,
          left: -70,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              color: const Color(0xFFFFB6C1).withValues(alpha: 0.35),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          bottom: -70,
          right: -50,
          child: Container(
            width: 190,
            height: 190,
            decoration: BoxDecoration(
              color: const Color(0xFFB8D8FF).withValues(alpha: 0.40),
              shape: BoxShape.circle,
            ),
          ),
        ),

        const Positioned(
          top: 55,
          left: 75,
          child: Text(
            '✦',
            style: TextStyle(
              fontSize: 25,
              color: Color(0xFFFFB52E),
            ),
          ),
        ),

        const Positioned(
          top: 100,
          right: 100,
          child: Text(
            '✦',
            style: TextStyle(
              fontSize: 21,
              color: Color(0xFF6C63FF),
            ),
          ),
        ),

        const Positioned(
          bottom: 80,
          left: 130,
          child: Text(
            '✦',
            style: TextStyle(
              fontSize: 19,
              color: Color(0xFFFF8FA3),
            ),
          ),
        ),

        const Positioned(
          bottom: 110,
          right: 70,
          child: Text(
            '✧',
            style: TextStyle(
              fontSize: 25,
              color: Color(0xFFFFC107),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        maxWidth: 470,
      ),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6274A8).withValues(alpha: 0.12),
            blurRadius: 35,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3D6),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Center(
                  child: Text(
                    '💛',
                    style: TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selamat datang!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF263B73),
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Isi dulu yuk untuk masuk',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF9AA8C4),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          const Text(
            'Email kamu',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Color(0xFF52668F),
            ),
          ),

          const SizedBox(height: 8),

          TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF263B73),
            ),
            decoration: _inputDecoration(
              label: 'Masukkan email',
              icon: Icons.mail_rounded,
            ),
          ),

          const SizedBox(height: 17),

          const Text(
            'Password',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Color(0xFF52668F),
            ),
          ),

          const SizedBox(height: 8),

          TextField(
            controller: passwordController,
            obscureText: obscurePassword,
            textInputAction: TextInputAction.done,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF263B73),
            ),
            onSubmitted: (_) {
              if (!isLoading) {
                login();
              }
            },
            decoration: _inputDecoration(
              label: 'Masukkan password',
              icon: Icons.lock_rounded,
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    obscurePassword = !obscurePassword;
                  });
                },
                icon: Icon(
                  obscurePassword
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  color: const Color(0xFFFFC107),
                  size: 21,
                ),
              ),
            ),
          ),

          const SizedBox(height: 23),

          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: isLoading ? null : login,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD43B),
                disabledBackgroundColor: const Color(0xFFFFE99A),
                foregroundColor: const Color(0xFF263B73),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 23,
                      height: 23,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: Color(0xFF263B73),
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Mulai Petualangan',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(width: 9),
                        Text(
                          '🚀',
                          style: TextStyle(fontSize: 19),
                        ),
                      ],
                    ),
            ),
          ),

          const SizedBox(height: 15),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Belum punya akun?',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF8B9ABB),
                ),
              ),
              TextButton(
                onPressed: isLoading
                    ? null
                    : () {
                        Navigator.pushNamed(
                          context,
                          '/register',
                        );
                      },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                ),
                child: const Text(
                  'Daftar yuk! ✨',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFFF8E42),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 2),

          const Center(
            child: Text(
              'Setiap perasaan itu penting 💕',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Color(0xFFA6B2C9),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBranding() {
    return Expanded(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 35,
            vertical: 30,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 155,
                    height: 155,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFFFD95A),
                          Color(0xFFFFB84D),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFB84D)
                              .withValues(alpha: 0.28),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        '🦊',
                        style: TextStyle(
                          fontSize: 84,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: -25,
                    top: -20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.07),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: const Text(
                        '👋',
                        style: TextStyle(fontSize: 25),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              const Text(
                'Dunia Emosi',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF263B73),
                  letterSpacing: -0.8,
                ),
              ),

              const SizedBox(height: 9),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAE8FF),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  'Belajar • Bermain • Mengenal Perasaan',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF6C63FF),
                  ),
                ),
              ),

              const SizedBox(height: 13),

              const Text(
                'Yuk masuk dan mulai petualangan\n'
                'mengenal perasaan hari ini! 🌈',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF8B9ABB),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FF),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: _buildBackground(),
            ),

            LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 45,
                          vertical: 30,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // ==========================================
                            // KIRI — FORM LOGIN
                            // ==========================================

                            Expanded(
                              child: Center(
                                child: _buildLoginForm(),
                              ),
                            ),

                            const SizedBox(width: 70),

                            // ==========================================
                            // KANAN — BRANDING
                            // ==========================================

                            _buildBranding(),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}