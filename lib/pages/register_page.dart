import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;

  Future<void> register() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Semua data wajib diisi ya! ✨'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF5C6BC0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Password minimal 6 karakter ya! 🔒',
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
          await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
        },
      );

      if (!mounted) return;

      if (response.user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Registrasi berhasil! Silakan login ya. 🎉',
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF66BB6A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );

        Navigator.pushReplacementNamed(
          context,
          '/login',
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
    nameController.dispose();
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
        color: Color(0xFFFF8E42),
      ),
      prefixIcon: Icon(
        icon,
        color: const Color(0xFFFF8E42),
        size: 21,
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFFFFBF5),
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
          color: Color(0xFFDCE8F5),
          width: 1.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: Color(0xFFFF8E42),
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

  Widget _buildRegisterForm() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        maxWidth: 470,
      ),
      padding: const EdgeInsets.all(27),
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
          // Header
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0E4),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Center(
                  child: Text(
                    '🌱',
                    style: TextStyle(
                      fontSize: 25,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Buat akun baru!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF263B73),
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Yuk mulai petualanganmu',
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

          const SizedBox(height: 21),

          // Nama
          const Text(
            'Nama kamu',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Color(0xFF52668F),
            ),
          ),

          const SizedBox(height: 7),

          TextField(
            controller: nameController,
            textInputAction: TextInputAction.next,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF263B73),
            ),
            decoration: _inputDecoration(
              label: 'Masukkan nama',
              icon: Icons.person_rounded,
            ),
          ),

          const SizedBox(height: 14),

          // Email
          const Text(
            'Email kamu',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Color(0xFF52668F),
            ),
          ),

          const SizedBox(height: 7),

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

          const SizedBox(height: 14),

          // Password
          const Text(
            'Password',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Color(0xFF52668F),
            ),
          ),

          const SizedBox(height: 7),

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
                register();
              }
            },
            decoration: _inputDecoration(
              label: 'Minimal 6 karakter',
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
                  color: const Color(0xFFFF8E42),
                  size: 21,
                ),
              ),
            ),
          ),

          const SizedBox(height: 21),

          // Register button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: isLoading ? null : register,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFC928),
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
                          'Daftar Sekarang',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(width: 9),
                        Text(
                          '🚀',
                          style: TextStyle(
                            fontSize: 19,
                          ),
                        ),
                      ],
                    ),
            ),
          ),

          const SizedBox(height: 14),

          // Login
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Sudah punya akun?',
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
                        Navigator.pushReplacementNamed(
                          context,
                          '/login',
                        );
                      },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                ),
                child: const Text(
                  'Login yuk! ✨',
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
                          Color(0xFFA8E6CF),
                          Color(0xFF6FD8B3),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(50),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6FD8B3)
                              .withValues(alpha: 0.28),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        '🌱',
                        style: TextStyle(
                          fontSize: 82,
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
                        '🎉',
                        style: TextStyle(
                          fontSize: 25,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              const Text(
                'Tumbuhkan Emosimu',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF263B73),
                  letterSpacing: -0.7,
                ),
              ),

              const SizedBox(height: 9),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F8F0),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  'Kenali • Pahami • Kelola',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF38A878),
                  ),
                ),
              ),

              const SizedBox(height: 13),

              const Text(
                'Buat akun dan mulai perjalananmu\n'
                'untuk mengenal berbagai perasaan! 🌈',
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
      backgroundColor: const Color(0xFFFFFDF5),
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
                            // KIRI — FORM REGISTER
                            // ==========================================

                            Expanded(
                              child: Center(
                                child: _buildRegisterForm(),
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

            // Tombol kembali
            Positioned(
              top: 18,
              left: 20,
              child: Material(
                color: Colors.white,
                elevation: 2,
                borderRadius: BorderRadius.circular(15),
                child: InkWell(
                  borderRadius: BorderRadius.circular(15),
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const SizedBox(
                    width: 46,
                    height: 46,
                    child: Icon(
                      Icons.arrow_back_rounded,
                      color: Color(0xFF263B73),
                      size: 21,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}