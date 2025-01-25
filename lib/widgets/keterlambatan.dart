import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Untuk format waktu

class ShiftKaryawanWidget extends StatefulWidget {
  final String email;
  final Function(String) onJamMasukSelected;

  const ShiftKaryawanWidget({
    super.key,
    required this.email,
    required this.onJamMasukSelected,
  });

  @override
  _ShiftKaryawanWidgetState createState() => _ShiftKaryawanWidgetState();
}

class _ShiftKaryawanWidgetState extends State<ShiftKaryawanWidget> {
  bool isChecked = false; // Flag untuk memastikan hanya sekali pengecekan
  String jamMasuk =
      "00:00"; // Menyimpan nilai jam_masuk agar hanya diambil sekali
  String jamKeluar = "00:00"; // Menyimpan nilai jam_keluar

  // Fungsi untuk mengambil data shift berdasarkan email
  Future<Map<String, dynamic>?> _fetchShiftData() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('shift_karyawan')
          .doc(widget.email)
          .get();

      if (doc.exists && doc.data() != null) {
        return doc.data() as Map<String, dynamic>;
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
    return null;
  }

  // Fungsi untuk memeriksa keterlambatan berdasarkan jam masuk dan jam keluar
  void _checkIfLate() {
    if (jamMasuk == "00:00" || jamKeluar == "00:00")
      return; // Jangan cek jika jam_masuk atau jam_keluar belum ada nilai

    DateTime now = DateTime.now();

    // Cek jam masuk
    DateTime waktuMasuk = DateFormat("HH:mm").parse(jamMasuk);
    waktuMasuk = DateTime(
        now.year, now.month, now.day, waktuMasuk.hour, waktuMasuk.minute);
    Duration selisihWaktuMasuk = now.difference(waktuMasuk);

    // Cek jam keluar
    DateTime waktuKeluar = DateFormat("HH:mm").parse(jamKeluar);
    waktuKeluar = DateTime(
        now.year, now.month, now.day, waktuKeluar.hour, waktuKeluar.minute);
    Duration selisihWaktuKeluar = now.difference(waktuKeluar);

    // Cek hanya sekali setelah data diambil
    if (!isChecked) {
      setState(() {
        isChecked = true; // Menandakan sudah dicek
      });

      // Kirimkan hasil pengecekan keterlambatan ke callback
      if (selisihWaktuMasuk.inMinutes > 15) {
        widget.onJamMasukSelected("late");
      } else {
        widget.onJamMasukSelected("onTime");
      }

      // Pengecekan jika sudah lewat waktu jam_keluar tetapi belum absen hadir
      if (selisihWaktuKeluar.inMinutes > 0) {
        // Terpaksa set isLate menjadi true jika jam_keluar sudah lewat
        widget.onJamMasukSelected("late");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      // Mengambil data shift
      future: _fetchShiftData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(); // Tidak menampilkan apapun saat menunggu data
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return SizedBox(); // Tidak menampilkan apapun jika ada error atau data tidak ditemukan
        }

        final data = snapshot.data!;

        jamMasuk = data['jam_masuk'] ?? "00:00"; // Ambil jam_masuk hanya sekali
        jamKeluar =
            data['jam_keluar'] ?? "00:00"; // Ambil jam_keluar hanya sekali

        // Panggil pengecekan keterlambatan hanya sekali setelah jam_masuk dan jam_keluar diambil
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _checkIfLate();
        });

        return SizedBox(); // Tidak menampilkan apapun setelah pengecekan keterlambatan
      },
    );
  }
}
