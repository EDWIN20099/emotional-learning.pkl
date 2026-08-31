import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> with SingleTickerProviderStateMixin {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;
  bool _isRegisterPressed = false;

  late AnimationController _entranceController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Curves.easeOutBack,
      ),
    );
    _entranceController.forward();
  }

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
    _entranceController.dispose();
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
        color: Color(0xFF7183A0),
      ),
      floatingLabelStyle: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        color: Color(0xFFFF9364),
      ),
      prefixIcon: Icon(
        icon,
        color: const Color(0xFFFF9364),
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
          color: Color(0xFFFF9364),
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
              color: const Color(0xFFFFD54F).withValues(alpha: 0.30),
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
              color: const Color(0xFF66D39A).withValues(alpha: 0.35),
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
              color: const Color(0xFFFF8FB1).withValues(alpha: 0.25),
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
              color: const Color(0xFF62C7FF).withValues(alpha: 0.30),
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
              color: Color(0xFFFFD54F),
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
            color: const Color(0xFF203864).withValues(alpha: 0.08),
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
                      color: Color(0xFF203864),
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Yuk mulai petualanganmu',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF7183A0),
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
              color: Color(0xFF7183A0),
            ),
          ),

          const SizedBox(height: 7),

          TextField(
            controller: nameController,
            textInputAction: TextInputAction.next,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF203864),
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
              color: Color(0xFF7183A0),
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
              color: Color(0xFF203864),
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
              color: Color(0xFF7183A0),
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
              color: Color(0xFF203864),
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
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                onPressed: () {
                  setState(() {
                    obscurePassword = !obscurePassword;
                  });
                },
                icon: Icon(
                  obscurePassword
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  color: const Color(0xFFFF9364),
                  size: 21,
                ),
              ),
            ),
          ),

          const SizedBox(height: 21),

          // Tactile squishy Register button
          GestureDetector(
            onTapDown: (_) {
              if (!isLoading) setState(() => _isRegisterPressed = true);
            },
            onTapUp: (_) => setState(() => _isRegisterPressed = false),
            onTapCancel: () => setState(() => _isRegisterPressed = false),
            onTap: isLoading ? null : register,
            child: AnimatedScale(
              scale: _isRegisterPressed ? 0.90 : 1.0,
              duration: const Duration(milliseconds: 100),
              child: Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  color: isLoading ? const Color(0xFFFFE99A) : const Color(0xFFFFC928),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: isLoading
                      ? null
                      : [
                          BoxShadow(
                            color: const Color(0xFFFFC928).withValues(alpha: 0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: Center(
                  child: isLoading
                      ? const SizedBox(
                          width: 23,
                          height: 23,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: Color(0xFF203864),
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
                                color: Color(0xFF203864),
                              ),
                            ),
                            SizedBox(width: 9),
                            Text(
                              '🚀',
                              style: TextStyle(
                                fontSize: 19,
                                color: Color(0xFF203864),
                              ),
                            ),
                          ],
                        ),
                ),
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
                  color: Color(0xFF7183A0),
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
                    color: Color(0xFFFF9364),
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
                color: Color(0xFF7183A0),
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
              Transform.rotate(
                angle: 0.05,
                child: Stack(
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
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(
                          color: Colors.white,
                          width: 4,
                        ),
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
              ),

              const SizedBox(height: 22),

              const Text(
                'Tumbuhkan Emosimu',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF203864),
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
                  color: Color(0xFF7183A0),
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
      backgroundColor: const Color(0xFFFFF9F0),
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
                        child: ScaleTransition(
                          scale: _scaleAnimation,
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
                    width: 48, // Improved min touch target >= 48
                    height: 48,
                    child: Icon(
                      Icons.arrow_back_rounded,
                      color: Color(0xFF203864),
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