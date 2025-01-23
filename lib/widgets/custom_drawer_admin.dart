import 'package:ARTShift/screens/laporan_screen.dart';
import 'package:ARTShift/screens/shift_karyawan_screen.dart';
import 'package:flutter/material.dart';
import 'package:ARTShift/screens/kelola_akunadmin_screen.dart';
import 'package:ARTShift/screens/kelola_akunkaryawan_screen.dart';
import 'package:ARTShift/screens/kelola_kategori_screen.dart';
import 'package:ARTShift/screens/lengkapidata_screen.dart';
import 'package:ARTShift/screens/profile_screen.dart';
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
            // MENU UTAMA
            _buildSectionTitle("MENU UTAMA"),

            _buildDrawerItem(context, 'assets/icons/icon_menu/kelolaadmin.png',
                "Kelola Akun Admin", navigateTo: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => KelolaAkunAdminScreen()));
            }),
            _buildDrawerItem(
                context,
                'assets/icons/icon_menu/kelolakaryawan.png',
                "Kelola Akun Karyawan", navigateTo: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => KelolaAkunKaryawanScreen()));
            }),
            _buildDrawerItem(context, 'assets/icons/icon_menu/shift.png',
                "Kelola Shift Karyawan", navigateTo: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => KelolaShiftKaryawanScreen()));
            }),
            _buildDrawerItem(
                context,
                'assets/icons/icon_menu/kategorishift.png',
                "Kelola Kategori Shift", navigateTo: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => KelolaKategoriScreen()));
            }),
            _buildDrawerItem(
                context, 'assets/icons/icon_menu/meeting.png', "Adakan Rapat",
                navigateTo: () {}),
            _buildDrawerItem(
                context, 'assets/icons/icon_menu/laporan.png', "Laporan",
                navigateTo: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => LaporanScreen()));
            }),
            const SizedBox(height: 10), // Jarak antar bagian

            // MENU LAINNYA
            _buildSectionTitle("MENU LAINNYA"),
            _buildDrawerItem(
                context, 'assets/icons/icon_menu/biodata.png', "Lengkapi Data",
                navigateTo: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => LengkapiDataScreen()));
            }),
            _buildDrawerItem(
                context, 'assets/icons/icon_menu/profil.png', "Profil",
                navigateTo: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProfileScreen(email: email)));
            }),
            _buildDrawerItem(
                context, 'assets/icons/icon_menu/logout.png', "Keluar",
                navigateTo: () {
              showLogoutDialog(context);
            }),
          ],
        ),
      ),
    );
  }

  /// Widget untuk membuat item di Drawer lebih rapi
  Widget _buildDrawerItem(
    BuildContext context,
    String imagePath,
    String title, {
    required VoidCallback navigateTo,
  }) {
    return ListTile(
      leading: Image.asset(imagePath,
          width: 26, height: 26), // Ukuran icon lebih besar
      title: Text(title, style: const TextStyle(fontSize: 16)),
      dense: true,
      contentPadding: const EdgeInsets.symmetric(
          horizontal: 20, vertical: 5), // Jarak antar menu lebih rapat
      onTap: navigateTo,
    );
  }

  /// Widget untuk membuat judul section lebih rapi
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: 15, vertical: 0), // Jarak lebih dekat
      child: Text(
        title,
        style:
            const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
      ),
    );
  }
}
