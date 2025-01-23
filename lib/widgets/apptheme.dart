import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData themeData = ThemeData(
    progressIndicatorTheme: ProgressIndicatorThemeData(color: Colors.blue),
    scaffoldBackgroundColor: Colors.white,
    primaryColor: Colors.blue,
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      backgroundColor: Color.fromARGB(255, 210, 210, 210),
      titleTextStyle: TextStyle(
          // color: Color(0xFF4A90E2),
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
          fontSize: 22),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      elevation: 6,
    ),
    iconTheme: const IconThemeData(
      color: Colors.blue,
      size: 24,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(
        fontFamily: 'Poppins',
        color: Colors.black,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.blue),
        borderRadius: BorderRadius.circular(10),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      floatingLabelStyle: TextStyle(color: Colors.blue),
      focusColor: Colors.blue,
      hintStyle: const TextStyle(color: Colors.grey),
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: Colors.blue,
    ),
    indicatorColor: Colors.blue,
  );

  // Custom AppBar Biasa
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
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: AppBar(
          toolbarHeight: 60, // Pastikan tinggi AppBar tetap 60px
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
                    color: Color(0xFF4A90E2),
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
