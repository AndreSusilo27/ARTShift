import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Mengubah menjadi widget fungsi biasa
Widget shiftKaryawanWidget({
  required String email,
  required Function(Map<String, dynamic>) onDataFetched,
}) {
  // Fungsi untuk mengambil data shift berdasarkan email
  Future<Map<String, dynamic>?> _fetchShiftData() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('shift_karyawan')
          .doc(email)
          .get();

      if (doc.exists && doc.data() != null) {
        return doc.data() as Map<String, dynamic>;
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
    return null;
  }

  return FutureBuilder<Map<String, dynamic>?>(
    // Gunakan FutureBuilder untuk mengambil data
    future: _fetchShiftData(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator()); // Menunggu data
      }

      if (snapshot.hasError || !snapshot.hasData) {
        return Center(child: Text("Data tidak ditemukan.")); // Error handling
      }

      final data = snapshot.data!;

      // Panggil callback untuk mengirimkan data yang sudah diambil
      onDataFetched(data);

      return SizedBox(); // Tidak menampilkan apapun setelah data diambil
    },
  );
}
