import 'package:ARTShift/screens/kelola_faq.dart';
import 'package:ARTShift/screens/jadwal_rapat_screen.dart';
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
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF0D0A9B),
                const Color(0xFF0C07B3),
                const Color(0xFF030262),
                const Color(0xFF030153),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                margin: const EdgeInsets.only(top: 55, right: 15, left: 15),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 226, 243, 254),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: const Color.fromARGB(35, 0, 0, 0),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: const Offset(0, 5),
                    ),
                    BoxShadow(
                      color: const Color.fromARGB(200, 255, 255, 255),
                      blurRadius: 12,
                      spreadRadius: 1,
                      offset: const Offset(0, 0),
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
                                  color: const Color.fromARGB(80, 0, 0, 0),
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

              _buildDrawerItem(
                  context,
                  'assets/icons/icon_menu/kelolaadmin.png',
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
                  navigateTo: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => JadwalRapatScreen()));
              }),
              _buildDrawerItem(
                  context, 'assets/icons/icon_menu/laporan.png', "Laporan",
                  navigateTo: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => LaporanScreen()));
              }),
              const SizedBox(height: 10), // Jarak antar bagian

              // MENU LAINNYA
              _buildSectionTitle("MENU LAINNYA"),
              _buildDrawerItem(context, 'assets/icons/icon_menu/Kelola FAQ.png',
                  "Kelola FAQ", navigateTo: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => KelolaFAQScreen()));
              }),
              _buildDrawerItem(context, 'assets/icons/icon_menu/biodata.png',
                  "Lengkapi Data", navigateTo: () {
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
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    String imagePath,
    String title, {
    required VoidCallback navigateTo,
  }) {
    return ListTile(
      leading: Image.asset(imagePath, width: 26, height: 26),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      onTap: navigateTo,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 0),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
