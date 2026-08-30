import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/home_page.dart';
import 'pages/emotion_page.dart';
import 'pages/home_main_page.dart';
import 'pages/loading_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ============================================
  // LOCK ORIENTATION TO LANDSCAPE
  // ============================================
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // ============================================
  // INITIALIZE SUPABASE
  // ============================================
  await Supabase.initialize(
    url: 'https://fcrmfxnobqocgdmozcqs.supabase.co',
    anonKey: 'sb_publishable_3n3w_Npsk7YTCCN5gB0niA_sN3u-lmv',
  );

  // ============================================
  // RUN APPLICATION
  // ============================================
  runApp(const EmotionalLearningApp());
}

class EmotionalLearningApp extends StatelessWidget {
  const EmotionalLearningApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // Application title
      title: 'Emotional Learning',

      // ==========================================
      // THEME
      // ==========================================
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange,
        ),
        scaffoldBackgroundColor: Colors.white,
      ),

      // ==========================================
      // INITIAL ROUTE
      // ==========================================
      initialRoute: '/login',

      // ==========================================
      // APPLICATION ROUTES
      // ==========================================
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/loading': (context) => const LoadingPage(),
        '/home': (context) => const HomePage(),
        '/emotion': (context) => const EmotionPage(),
        '/home-main': (context) => const HomeMainPage(),
      },
    );
  }
}