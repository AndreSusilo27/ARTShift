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
          Image.asset(
            'assets/images/beranda.jpg',
            fit: BoxFit.cover,
          ),
          Center(
            child: Card(
              elevation: 5,
              color: const Color.fromARGB(200, 255, 255, 255),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo
                    Image.asset(
                      'assets/images/ARTShift_logo.png',
                      width: 170,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 28,
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
