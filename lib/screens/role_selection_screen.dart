import 'package:ARTShift/screens/dashboard_admin_screen.dart';
import 'package:ARTShift/screens/dashboard_karyawan_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ARTShift/auth/auth_bloc.dart';
import 'package:ARTShift/auth/auth_event.dart';

class RoleSelectionScreen extends StatelessWidget {
  final String uid;
  final String name;
  final String email;
  final String photoUrl;

  const RoleSelectionScreen({
    super.key,
    required this.uid,
    required this.name,
    required this.email,
    required this.photoUrl,
  });

  void _selectRole(BuildContext context, String role) async {
    // Simpan role di Firestore
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'role': role,
      'createdAt': DateTime.now(),
    });

    // Navigasi ke dashboard sesuai role
    if (role == "Admin") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DashboardAdminScreen(name, email, photoUrl),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DashboardKaryawanScreen(name, email, photoUrl),
        ),
      );
    }

    // Update state di BLoC
    context.read<AuthBloc>().add(UpdateUserRole(role));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pilih Role")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Pilih peran Anda",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _selectRole(context, "Admin"),
              child: const Text("Admin"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _selectRole(context, "Karyawan"),
              child: const Text("Karyawan"),
            ),
          ],
        ),
      ),
    );
  }
}
