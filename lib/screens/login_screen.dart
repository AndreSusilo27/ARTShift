import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ARTShift/auth/auth_bloc.dart';
import 'package:ARTShift/auth/auth_event.dart';
import 'package:ARTShift/auth/auth_state.dart';
import 'package:ARTShift/screens/role_selection_screen.dart';
import 'package:ARTShift/screens/dashboard_admin_screen.dart';
import 'package:ARTShift/screens/dashboard_karyawan_screen.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: BlocConsumer<AuthBloc, AuthState>(
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
              return const CircularProgressIndicator();
            }
            return ElevatedButton(
              onPressed: () {
                context.read<AuthBloc>().add(SignInWithGoogle());
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FaIcon(FontAwesomeIcons.google,
                      size: 24), // Ikon Google dari FontAwesome
                  SizedBox(width: 10),
                  Text("Sign in with Google"),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
