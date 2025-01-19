import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ARTShift/screens/dashboard_admin_screen.dart';
import 'package:ARTShift/screens/dashboard_karyawan_screen.dart';

class CustomBackToDashboard extends StatelessWidget {
  const CustomBackToDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        // Mendapatkan pengguna yang sedang login
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          // Navigasi sesuai dengan peran pengguna
          if (user.email != null) {
            String role = user.email!.contains("admin") ? "Admin" : "Karyawan";
            if (role == "Admin") {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => DashboardAdminScreen(
                    user.displayName ?? "Admin",
                    user.email ?? "",
                    user.photoURL ?? "",
                  ),
                ),
              );
            } else if (role == "Karyawan") {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => DashboardKaryawanScreen(
                    user.displayName ?? "Karyawan",
                    user.email ?? "",
                    user.photoURL ?? "",
                  ),
                ),
              );
            }
          }
        }
      },
    );
  }
}
