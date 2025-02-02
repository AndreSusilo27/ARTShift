import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ShiftKaryawanWidget extends StatefulWidget {
  final String email;
  final Function(String) onJamMasukSelected;

  const ShiftKaryawanWidget({
    super.key,
    required this.email,
    required this.onJamMasukSelected,
  });

  @override
  State<ShiftKaryawanWidget> createState() => _ShiftKaryawanWidgetState();
}

class _ShiftKaryawanWidgetState extends State<ShiftKaryawanWidget> {
  bool isChecked = false;
  String jamMasuk = "00:00";
  String jamKeluar = "00:00";

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

  // Fungsi untuk memeriksa status kehadiran karyawan
  void _checkAttendanceStatus() {
    if (jamMasuk == "00:00" || jamKeluar == "00:00") return;

    DateTime now = DateTime.now();

    DateTime waktuMasuk = DateFormat("HH:mm").parse(jamMasuk);
    waktuMasuk = DateTime(
        now.year, now.month, now.day, waktuMasuk.hour, waktuMasuk.minute);

    DateTime waktuKeluar = DateFormat("HH:mm").parse(jamKeluar);
    waktuKeluar = DateTime(
        now.year, now.month, now.day, waktuKeluar.hour, waktuKeluar.minute);

    Duration selisihWaktuMasuk = now.difference(waktuMasuk);
    Duration selisihWaktuKeluar = now.difference(waktuKeluar);

    if (!isChecked) {
      setState(() {
        isChecked = true;
      });

      if (selisihWaktuMasuk.inMinutes < -15) {
        widget.onJamMasukSelected("belum_waktu_absen");
      } else if (selisihWaktuMasuk.inMinutes >= -15 &&
          selisihWaktuMasuk.inMinutes <= 15) {
        widget.onJamMasukSelected("onTime");
      } else if (selisihWaktuMasuk.inMinutes > 15) {
        widget.onJamMasukSelected("late");
      }

      if (selisihWaktuKeluar.inMinutes > 0) {
        widget.onJamMasukSelected("late");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _fetchShiftData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox();
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return SizedBox();
        }

        final data = snapshot.data!;
        jamMasuk = data['jam_masuk'] ?? "00:00";
        jamKeluar = data['jam_keluar'] ?? "00:00";

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _checkAttendanceStatus();
        });

        return SizedBox();
      },
    );
  }
}
