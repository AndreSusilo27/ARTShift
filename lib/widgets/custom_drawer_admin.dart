import 'package:ARTShift/screens/lengkapidata_screen.dart';
import 'package:ARTShift/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:ARTShift/widgets/logout.dart';

class CustomDrawerAdmin extends StatelessWidget {
  final String name;
  final String email;
  final String photoUrl;

  const CustomDrawerAdmin({
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
              margin: EdgeInsets.only(
                top: 55,
                right: 15,
                left: 15,
              ),
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

            // MENU UTAMA
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                "MENU UTAMA",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.black54),
              ),
            ),

            _buildDrawerItem(
              context,
              Icons.assignment_sharp,
              "Laporan",
              navigateTo: () {},
            ),
            _buildDrawerItem(
              context,
              Icons.account_circle_rounded,
              "Kelola Akun Admin",
              navigateTo: () {},
            ),
            _buildDrawerItem(
              context,
              Icons.group_rounded,
              "Kelola Akun dan Shift Karyawan",
              navigateTo: () {},
            ),
            _buildDrawerItem(
              context,
              Icons.meeting_room_rounded,
              "Adakan Rapat",
              navigateTo: () {},
            ),

            const SizedBox(height: 20),

            // MENU LAINNYA
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "MENU LAINNYA",
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.black54),
              ),
            ),

            _buildDrawerItem(
              context,
              Icons.assignment_rounded,
              "Lengkapi Data",
              navigateTo: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LengkapiDataScreen()),
                );
              },
            ),

            _buildDrawerItem(
              context,
              Icons.person_outline_rounded,
              "Profil",
              navigateTo: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProfileScreen(email: email)),
                );
              },
            ),

            // Item logout dengan menggunakan showLogoutDialog
            _buildDrawerItem(
              context,
              Icons.exit_to_app_rounded,
              "Keluar",
              navigateTo: () {
                showLogoutDialog(context); // Memanggil fungsi logout
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Widget untuk membuat item di Drawer lebih rapi
  Widget _buildDrawerItem(
    BuildContext context,
    IconData icon,
    String title, {
    required VoidCallback navigateTo,
  }) {
    return ListTile(
      leading: Icon(icon, size: 24),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      onTap: navigateTo,
    );
  }
}
