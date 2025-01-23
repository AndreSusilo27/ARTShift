import 'package:ARTShift/laporan/laporan_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ARTShift/auth/auth_bloc.dart';
import 'package:ARTShift/screens/splash_screen.dart';
import 'package:ARTShift/screens/home_screen.dart';
import 'package:ARTShift/widgets/apptheme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("🔥 Firebase initialization failed: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(),
        ),
        BlocProvider<LaporanBloc>(
          create: (context) =>
              LaporanBloc(firestore: FirebaseFirestore.instance),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/splash', // Halaman pertama adalah SplashScreen
        routes: {
          '/splash': (context) => SplashScreen(nextScreen: const HomeScreen()),
          '/home': (context) => const HomeScreen(),
        },
        theme: AppTheme.themeData,
      ),
    );
  }
}
