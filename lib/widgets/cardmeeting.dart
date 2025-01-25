import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MeetingList extends StatelessWidget {
  const MeetingList({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      // Membungkus dengan Expanded untuk mengatasi ruang vertikal tak terbatas
      child: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection('jadwal_meeting').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Tidak ada data rapat."));
          }

          final meetings = snapshot.data!.docs;

          return ListView.builder(
            itemCount: meetings.length,
            itemBuilder: (context, index) {
              final meetingData = meetings[index];
              return CardMeeting(
                namaRapat:
                    meetingData['nama_rapat'] ?? "Nama rapat tidak tersedia",
                waktuMulai:
                    meetingData['waktu_mulai'] ?? "Waktu tidak tersedia",
                waktuSelesai:
                    meetingData['waktu_selesai'] ?? "Waktu tidak tersedia",
                tanggalRapat:
                    meetingData['tanggal_rapat'] ?? "Tanggal tidak tersedia",
                linkMeeting:
                    meetingData['link_meeting'] ?? "Link tidak tersedia",
              );
            },
          );
        },
      ),
    );
  }
}

class CardMeeting extends StatelessWidget {
  final String namaRapat;
  final String waktuMulai;
  final String waktuSelesai;
  final String tanggalRapat;
  final String linkMeeting;

  const CardMeeting({
    super.key,
    required this.namaRapat,
    required this.waktuMulai,
    required this.waktuSelesai,
    required this.tanggalRapat,
    required this.linkMeeting,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10, // Efek bayangan untuk tampilan 3D
      shadowColor: Colors.black, // Warna bayangan
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15), // Sudut melengkung
      ),
      child: ListTile(
        title: Text(namaRapat),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Waktu: $waktuMulai - $waktuSelesai'),
            Text('Tanggal: $tanggalRapat'),
          ],
        ),
        trailing: Padding(
          padding: const EdgeInsets.only(right: 8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8), // Efek klik membulat
            onTap: () {
              // Arahkan ke meeting menggunakan linkMeeting
              _showLinkDialog(context, linkMeeting);
            },
            child: Container(
              padding:
                  const EdgeInsets.all(6), // Spasi agar tidak terlalu rapat
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1), // Warna biru transparan
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.calendar_today, // Ikon kalender
                color: Colors.blue,
                size: 22, // Ukuran lebih proporsional
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Fungsi untuk menampilkan dialog atau aksi ketika ikon kalender diklik
  void _showLinkDialog(BuildContext context, String linkMeeting) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Link Meeting"),
          content: Text("Klik untuk bergabung dalam meeting:\n$linkMeeting"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text("Tutup"),
            ),
            TextButton(
              onPressed: () {
                // Logika untuk membuka link meeting
                Navigator.of(dialogContext).pop();
                _openMeetingLink(linkMeeting);
              },
              child: const Text("Masuk ke Meeting"),
            ),
          ],
        );
      },
    );
  }

  // Fungsi untuk membuka link meeting (bisa menggunakan url_launcher)
  void _openMeetingLink(String link) {
    // Misalnya menggunakan url_launcher
    // launch(link);
  }
}
