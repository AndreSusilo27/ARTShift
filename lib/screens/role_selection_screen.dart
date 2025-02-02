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
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'role': role,
      'createdAt': DateTime.now(),
    });

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

    context.read<AuthBloc>().add(UpdateUserRole(role));
  }

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
            child: Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.symmetric(horizontal: 30),
              decoration: BoxDecoration(
                color: const Color.fromARGB(200, 255, 255, 255),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(photoUrl),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Selamat Datang, $name",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Silakan pilih peran Anda",
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  const SizedBox(height: 30),
                  _buildRoleButton(context, "Admin", Icons.admin_panel_settings,
                      Colors.blueAccent),
                  const SizedBox(height: 15),
                  _buildRoleButton(
                      context, "Karyawan", Icons.work, Colors.lightBlueAccent),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleButton(
      BuildContext context, String role, IconData icon, Color color) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      onPressed: () => _selectRole(context, role),
      icon: Icon(icon, color: Colors.white),
      label: Text(
        role,
        style: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }
}
