import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData themeData = ThemeData(
    progressIndicatorTheme: ProgressIndicatorThemeData(color: Colors.blue),
    scaffoldBackgroundColor: Colors.white,
    primaryColor: Colors.blue,
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      backgroundColor: Color.fromARGB(255, 3, 1, 83),
      titleTextStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontFamily: 'Poppins',
          fontSize: 22),
      elevation: 6,
    ),
    iconTheme: const IconThemeData(
      color: Colors.white,
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

  // Custom AppBar
  static PreferredSizeWidget customAppBar({
    required GlobalKey<ScaffoldState> scaffoldKey,
  }) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(60),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: const Color.fromARGB(214, 2, 1, 83),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: AppBar(
          toolbarHeight: 60,
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
          backgroundColor: const Color.fromARGB(255, 3, 1, 83),
        ),
      ),
    );
  }

  static PreferredSizeWidget appBar({
    String? titleText,
    TabBar? bottom,
  }) {
    double tabBarHeight = bottom != null ? 35.0 : 0.0;
    double totalHeight = 60.0 + tabBarHeight;

    return PreferredSize(
      preferredSize: Size.fromHeight(totalHeight),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Color.fromARGB(95, 0, 0, 0),
              blurRadius: 10,
              spreadRadius: 2,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: AppBar(
          title: titleText != null
              ? Text(
                  titleText,
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
          automaticallyImplyLeading: false,
          backgroundColor: Color.fromARGB(255, 3, 1, 83),
          elevation: 0,
          bottom: bottom != null
              ? PreferredSize(
                  preferredSize: Size.fromHeight(tabBarHeight),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      bottom,
                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
