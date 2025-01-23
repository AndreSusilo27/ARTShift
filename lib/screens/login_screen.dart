import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ARTShift/auth/auth_bloc.dart';
import 'package:ARTShift/auth/auth_event.dart';
import 'package:ARTShift/auth/auth_state.dart';
import 'package:ARTShift/screens/role_selection_screen.dart';
import 'package:ARTShift/screens/dashboard_admin_screen.dart';
import 'package:ARTShift/screens/dashboard_karyawan_screen.dart';
import 'package:ARTShift/widgets/custom_button.dart';
import 'package:ARTShift/widgets/custom_carousel.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            Widget targetScreen;
            if (state.role == "Admin") {
              targetScreen =
                  DashboardAdminScreen(state.name, state.email, state.photoUrl);
            } else if (state.role == "Karyawan") {
              targetScreen = DashboardKaryawanScreen(
                  state.name, state.email, state.photoUrl);
            } else {
              targetScreen = RoleSelectionScreen(
                uid: state.uid,
                name: state.name,
                email: state.email,
                photoUrl: state.photoUrl,
              );
            }
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => targetScreen),
            );
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color.fromARGB(255, 49, 181, 229),
                  const Color.fromARGB(255, 44, 163, 207),
                  const Color.fromARGB(255, 20, 78, 99),
                  Colors.black
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              // image: DecorationImage(
              //   image: AssetImage('assets/images/background.png'),
              //   fit: BoxFit.cover,
              // ),
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),
                    const CustomCarousel(),
                    const SizedBox(height: 10),
                    // Logo
                    Image.asset(
                      'assets/icons/ARTShift_icon2.png',
                      height: 50,
                      fit: BoxFit.contain,
                    ),

                    // Divider dengan teks "LOGIN"
                    Row(
                      children: [
                        Expanded(
                            child:
                                Divider(color: Colors.white70, thickness: 2)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            "LOGIN",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                            child:
                                Divider(color: Colors.white70, thickness: 2)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Deskripsi Aplikasi
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        "ARTShift membantu Anda menciptakan mahakarya digital dengan mudah dan efisien.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.white70),
                      ),
                    ),
                    const SizedBox(height: 25),
                    // Tombol Sign-in Google
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: CustomButton(
                        text: "Sign in with Google",
                        imageAsset: 'assets/icons/google.png',
                        onPressed: () {
                          context.read<AuthBloc>().add(SignInWithGoogle());
                        },
                        color: Colors.white,
                        textStyle: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        width: double.infinity,
                        elevation: 5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Footer
                    Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 100, vertical: 10),
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
