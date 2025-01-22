import 'package:ARTShift/screens/home_screen.dart';
import 'package:ARTShift/widgets/apptheme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ARTShift/auth/auth_bloc.dart';
import 'package:ARTShift/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthBloc(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,

        initialRoute: '/splash', // Menentukan halaman pertama (SplashScreen)
        routes: {
          '/splash': (context) => SplashScreen(
                nextScreen: HomeScreen(),
              ),
          '/home': (context) => const HomeScreen(),
        },
        theme: AppTheme.themeData, // Menambahkan tema di sini
      ),
    );
  }
}
