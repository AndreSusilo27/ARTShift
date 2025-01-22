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
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image Full Screen
          Image.asset(
            'assets/images/beranda.jpg',
            fit: BoxFit.cover,
          ),

          // Layer Transparan di Tengah
          Center(
            child: Card(
              elevation: 5,
              color: Colors.white.withOpacity(0.8), // Transparan
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20), // Sudut membulat
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo
                    Image.asset(
                      'assets/images/ARTShift_logo.png',
                      width: 250, // Ukuran logo
                    ),
                    const SizedBox(height: 20),

                    // Teks "Harap Tunggu Sebentar"
                    const Text(
                      "Harap Tunggu Sebentar...",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87, // Warna teks
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Animasi Loading
                    const CircularProgressIndicator(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
