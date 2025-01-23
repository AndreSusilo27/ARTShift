import 'package:ARTShift/screens/absensi_screen.dart';
import 'package:ARTShift/screens/lengkapidata_screen.dart';
import 'package:ARTShift/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:ARTShift/widgets/logout.dart';

class CustomDrawerKaryawan extends StatelessWidget {
  final String name;
  final String email;
  final String photoUrl;

  const CustomDrawerKaryawan({
    super.key,
    required this.name,
    required this.email,
    required this.photoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.58,
      child: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
              margin: const EdgeInsets.only(top: 55, right: 15, left: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(photoUrl),
                      ),
                      Positioned(
                        bottom: 4,
                        right: 6,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    email,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildDrawerHeader("MENU UTAMA"),
            _buildDrawerItem(
                context, "assets/icons/icon_menu/kehadiran.png", "Kehadiran",
                navigateTo: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AbsensiScreen(
                    email: email,
                    name: name,
                  ),
                ),
              );
            }),
            const SizedBox(height: 20),
            _buildDrawerHeader("MENU LAINNYA"),
            _buildDrawerItem(
              context,
              'assets/icons/icon_menu/biodata.png',
              "Lengkapi Data",
              navigateTo: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LengkapiDataScreen(),
                  ),
                );
              },
            ),
            _buildDrawerItem(
              context,
              'assets/icons/icon_menu/profil.png',
              "Profil",
              navigateTo: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(email: email),
                  ),
                );
              },
            ),

            // Logout button is placed at the bottom
            _buildDrawerItem(
              context,
              'assets/icons/icon_menu/logout.png',
              "Keluar",
              navigateTo: () {
                showLogoutDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Text(
        title,
        style:
            const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, String iconPath, String title,
      {required VoidCallback navigateTo}) {
    return ListTile(
      leading: Image.asset(
        iconPath,
        width: 26, // Ukuran ikon diperbesar agar lebih sesuai
        height: 26, // Ukuran ikon diperbesar agar lebih sesuai
      ),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      onTap: navigateTo,
    );
  }
}
