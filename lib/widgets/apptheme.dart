import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData themeData = ThemeData(
    scaffoldBackgroundColor: Colors.white,
    primaryColor: Colors.blue,
    appBarTheme: const AppBarTheme(
      backgroundColor: Color.fromARGB(255, 210, 210, 210),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      elevation: 0, // Hapus elevation default, kita pakai boxShadow manual
    ),
    iconTheme: const IconThemeData(
      color: Colors.blue, // Warna ikon biru
      size: 24,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(
        fontFamily: 'Poppins',
        color: Colors.black,
      ),
    ),
  );

  // Custom AppBar dengan efek 3D
  static PreferredSizeWidget customAppBar({
    required GlobalKey<ScaffoldState> scaffoldKey,
  }) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(60),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 5), // Bayangan ke bawah
            ),
          ],
        ),
        child: AppBar(
          leading: IconButton(
            onPressed: () => scaffoldKey.currentState!.openDrawer(),
            icon: Image.asset(
              'assets/icons/drawer_icon.png',
              height: 24,
              width: 24,
            ),
          ),
          title: Padding(
            padding: const EdgeInsets.only(top: 8.5),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/icons/ARTShift_icon.png',
                  height: 26,
                ),
                const SizedBox(width: 5),
                const Text(
                  "ARTShift",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Color(0xFF4A90E2), // Menggunakan format Hexa
                  ),
                ),
              ],
            ),
          ),
          backgroundColor: const Color.fromARGB(255, 210, 210, 210),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
        ),
      ),
    );
  }
}
