import 'package:ARTShift/screens/lengkapidata_screen.dart';
import 'package:ARTShift/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:ARTShift/widgets/logout.dart'; // Import yang sudah ada untuk logout

class CustomDrawer extends StatelessWidget {
  final String name;
  final String email;
  final String photoUrl;
  final String selectedMenu;

  const CustomDrawer({
    super.key,
    required this.name,
    required this.email,
    required this.photoUrl,
    required this.selectedMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // HEADER USER
          UserAccountsDrawerHeader(
            accountName: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(email),
            currentAccountPicture: Stack(
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundImage: NetworkImage(photoUrl),
                ),
                Positioned(
                  bottom: 3,
                  right: 8,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.2),
                    ),
                  ),
                ),
              ],
            ),
            decoration: const BoxDecoration(
              color: Colors.blue,
            ),
          ),

          // MENU UTAMA
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              "MENU UTAMA",
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
            ),
          ),

          _buildDrawerItem(
            context,
            Icons.dashboard,
            "Dashboard",
            selectedMenu == "Dashboard",
            navigateTo: () {
              // Ganti ini dengan navigasi ke halaman Dashboard sesuai dengan role
            },
          ),
          _buildDrawerItem(
            context,
            Icons.settings,
            "Pengaturan",
            selectedMenu == "Pengaturan",
            navigateTo: () {
              // Navigasi ke halaman Pengaturan
            },
          ),

          const SizedBox(height: 20),

          // MENU LAINNYA
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "MENU LAINNYA",
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
            ),
          ),

          _buildDrawerItem(
            context,
            Icons.person,
            "Lengkapi Data",
            selectedMenu == "Lengkapi Data",
            navigateTo: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LengkapiDataScreen()),
              );
            },
          ),

          _buildDrawerItem(
            context,
            Icons.person,
            "Profil",
            selectedMenu == "Profil",
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
            Icons.logout,
            "Keluar",
            selectedMenu == "Keluar",
            navigateTo: () {
              showLogoutDialog(context); // Memanggil fungsi logout
            },
          ),
        ],
      ),
    );
  }

  /// Widget untuk membuat item di Drawer lebih rapi
  Widget _buildDrawerItem(
    BuildContext context,
    IconData icon,
    String title,
    bool isSelected, {
    required VoidCallback navigateTo,
  }) {
    return ListTile(
      leading: Icon(icon, size: 24),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      tileColor: isSelected ? Colors.blue.shade50 : null,
      onTap: navigateTo,
    );
  }
}
