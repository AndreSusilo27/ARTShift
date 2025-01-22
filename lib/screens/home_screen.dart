import 'package:flutter/material.dart';
import 'login_screen.dart';
import '../../widgets/custom_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image Full Screen
          Image.asset(
            'assets/images/beranda.jpg', // Ganti dengan gambar background
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
                      width: 150, // Ukuran logo
                    ),
                    const SizedBox(height: 20),

                    // Teks "Selamat Datang"
                    const Text(
                      "Selamat Datang di ARTShift",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87, // Warna teks
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Tombol Masuk di Paling Bawah dengan jarak lebih dari bawah
          Positioned(
            bottom: 28, // Jarak 50px dari bawah, Anda bisa sesuaikan ini
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: CustomButton(
                width: double.infinity,
                height: 50,
                text: "Masuk",
                textStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
