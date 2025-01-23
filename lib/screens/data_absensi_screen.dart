import 'package:ARTShift/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DataAbsensiScreen extends StatelessWidget {
  final String userEmail;

  const DataAbsensiScreen({super.key, required this.userEmail});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Absensi'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Menampilkan email pengguna dengan desain lebih profesional
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    spreadRadius: 2,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'Data Absensi - $userEmail',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(
                height: 16), // Menambahkan jarak antara email dan konten

            // Membungkus ListView dengan Expanded
            Expanded(
              child: FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                    .collection('absensi')
                    .doc(
                        userEmail) // Mengambil dokumen berdasarkan email pengguna
                    .collection('absensi_harian')
                    .get(),
                builder: (context, snapshot) {
                  // Menunggu data atau sedang dalam proses pengambilan
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Menangani jika terjadi error dalam pengambilan data
                  if (snapshot.hasError) {
                    return Center(
                        child: Text('Terjadi kesalahan saat mengambil data'));
                  }

                  // Cek apakah data tidak ada atau kosong
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                        child: Text('Tidak ada data absensi untuk $userEmail'));
                  }

                  // Mengambil data absensi dari dokumen Firestore
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var absensi = snapshot.data!.docs[index];
                      var tanggal = absensi['tanggal'] ?? 'Tidak ada tanggal';
                      var hadir = absensi['hadir'] ?? {'waktu': 'Belum hadir'};
                      var keluar =
                          absensi['keluar'] ?? {'waktu': 'Belum keluar'};
                      var sakit = absensi['sakit'] ?? 'Tidak sakit';
                      var izin = absensi['izin'] ?? 'Tidak izin';

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          title: Text(
                            'Tanggal: $tanggal',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Hadir: ${hadir['waktu']}'),
                                Text('Keluar: ${keluar['waktu']}'),
                                Text('Sakit: $sakit'),
                                Text('Izin: $izin'),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: CustomFloatingBackButton(),
    );
  }
}
