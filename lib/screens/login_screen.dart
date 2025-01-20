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
              mainAxisAlignment: MainAxisAlignment
                  .spaceBetween, // Membuat ruang antara logo dan tombol
              children: [
                Expanded(
                  child: Center(
                    child: Image.asset(
                      'assets/images/ARTShift_logo.png',
                      height: 350,
                      width: 350,
                    ),
                  ),
                ),
                CustomButton(
                  text: "Sign in with Google",
                  imageAsset: 'assets/icons/google.png',
                  onPressed: () {
                    context.read<AuthBloc>().add(SignInWithGoogle());
                  },
                  color: Colors.black, // Tombol dengan warna biru
                  width: double.infinity, // Tombol lebar penuh
                  height: 55, // Tinggi tombol
                ),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }
}
