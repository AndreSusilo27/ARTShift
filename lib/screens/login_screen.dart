import 'package:ARTShift/widgets/custom_carousel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ARTShift/auth/auth_bloc.dart';
import 'package:ARTShift/auth/auth_event.dart';
import 'package:ARTShift/auth/auth_state.dart';
import 'package:ARTShift/screens/role_selection_screen.dart';
import 'package:ARTShift/screens/dashboard_admin_screen.dart';
import 'package:ARTShift/screens/dashboard_karyawan_screen.dart';
import 'package:ARTShift/widgets/custom_button.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            if (state.role == "Admin") {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => DashboardAdminScreen(
                      state.name, state.email, state.photoUrl),
                ),
              );
            } else if (state.role == "Karyawan") {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => DashboardKaryawanScreen(
                      state.name, state.email, state.photoUrl),
                ),
              );
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => RoleSelectionScreen(
                    uid: state.uid,
                    name: state.name,
                    email: state.email,
                    photoUrl: state.photoUrl,
                  ),
                ),
              );
            }
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(height: 5),
                const CustomCarousel(),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Mengatur gambar dengan tinggi sesuai yang diinginkan
                    Image.asset(
                      'assets/icons/ARTShift_icon2.png',
                      height:
                          35, // Sesuaikan tinggi gambar sesuai yang diinginkan
                      fit: BoxFit.contain, // Menjaga rasio aspek gambar
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[600],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Text(
                      "LOGIN",
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[600],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ],
                ),

                // Teks penjelasan di atas tombol
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    "ArtShift mempermudah setiap langkah Anda menciptakan karya seni \ndari ide sederhana hingga mahakarya digital.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ),

                const SizedBox(height: 10), // Jarak antara teks dan tombol

                // Tombol Sign in with Google
                CustomButton(
                  text: "Sign in with Google",
                  imageAsset: 'assets/icons/google.png',
                  onPressed: () {
                    context.read<AuthBloc>().add(SignInWithGoogle());
                  },
                  color: Colors.black,
                  width: double.infinity,
                ),
                const SizedBox(height: 5), // Menambah jarak kecil

                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 100),
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 1),
              ],
            ),
          );
        },
      ),
    );
  }
}
