import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  final Widget nextScreen; // Parameter untuk halaman tujuan
  const SplashScreen({super.key, required this.nextScreen});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => widget.nextScreen),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Bisa disesuaikan
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/ARTShift_Logo.png',
              width: 300,
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(), // Animasi Loading
          ],
        ),
      ),
    );
  }
}
