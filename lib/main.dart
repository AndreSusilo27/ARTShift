import 'package:ARTShift/absensi/absensi_bloc.dart';
import 'package:ARTShift/kelola_akunkaryawan/kelola_akunkaryawan_bloc.dart';
import 'package:ARTShift/laporan_harian/laporan_harian_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ARTShift/auth/auth_bloc.dart';
import 'package:ARTShift/screens/splash_screen.dart';
import 'package:ARTShift/screens/home_screen.dart';
import 'package:ARTShift/widgets/apptheme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Kelompok 7
// Nama Aplikasi : ARTShift
// Deskripsi :
//Aplikasi ARTShift ini dikembangkan oleh Kelompok 7 sebagai solusi inovatif
//dalam manajemen penjadwalan kerja dan absensi. Dengan teknologi Flutter dan Firebase,
//kami menghadirkan sistem yang efisien, transparan, dan mudah digunakan untuk
//meningkatkan produktivitas perusahaan. Desain UI/UX yang intuitif
//memastikan pengalaman pengguna yang optimal. Seluruh hak cipta dan pengelolaan data
//dalam aplikasi ini berada di bawah kendali penuh kelompok 7.

// Anggota Kelompok :
// - Andre Susilo - 21552011246
// - Robi Rohimin Najibah - 21552011084
// - Tia Puspita Sari - 21552011014

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
        BlocProvider<KelolaAkunKaryawanBloc>(
          create: (context) =>
              KelolaAkunKaryawanBloc(firestore: FirebaseFirestore.instance),
        ),
        BlocProvider<AbsensiBloc>(
          create: (context) => AbsensiBloc(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/splash',
        routes: {
          '/splash': (context) => SplashScreen(nextScreen: const HomeScreen()),
          '/home': (context) => const HomeScreen(),
        },
        theme: AppTheme.themeData,
      ),
    );
  }
}
