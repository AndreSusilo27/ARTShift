import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:url_launcher/url_launcher.dart';

class MeetingList extends StatelessWidget {
  const MeetingList({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
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
      elevation: 10,
      shadowColor: Colors.black,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
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
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              _showLinkDialog(context, linkMeeting);
            },
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.arrow_forward_ios,
                color: Colors.blue,
                size: 22,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showLinkDialog(BuildContext context, String linkMeeting) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(20),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          actionsPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 8, // Efek elevasi agar lebih elegan
          title: const Row(
            children: [
              Icon(
                Icons.video_call_rounded,
                color: Colors.blue,
                size: 28,
              ),
              SizedBox(width: 10),
              Text(
                "Link Meeting",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Klik tombol di bawah untuk bergabung dalam meeting:",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 10),
              SelectableText(
                linkMeeting,
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.grey),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 10),
                    ),
                    child: const Text(
                      "Tutup",
                      style: TextStyle(
                          color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      _openMeetingLink(linkMeeting);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 10),
                    ),
                    child: const Text(
                      "Masuk ke Meeting",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // Fungsi untuk membuka link meeting dengan fleksibel (Google Meet, Zoom, dll.)
  void _openMeetingLink(String link) async {
    final Uri url = Uri.parse(link);

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $link';
    }
  }
}
