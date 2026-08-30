import 'dart:async';

import 'package:flutter/material.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  @override
  void initState() {
    super.initState();

    Timer(
      const Duration(seconds: 2),
      () {
        if (!mounted) return;

        Navigator.pushReplacementNamed(
          context,
          '/emotion',
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF5), // Warna latar krem hangat khas TK
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Kotak Ikon Ceria
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD13B),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD13B).withValues(alpha: 0.4),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    '✨',
                    style: TextStyle(fontSize: 48),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              const Text(
                'Dunia Emosi 🌟',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1B3B6F),
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Menyiapkan petualangan seru\nbuat kamu ya! 🚀',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF8A9DBF),
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 36),

              const SizedBox(
                width: 44,
                height: 44,
                child: CircularProgressIndicator(
                  strokeWidth: 4,
                  color: Color(0xFFFF8E42),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}