import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ShiftTeamPage extends StatelessWidget {
  final String email;

  const ShiftTeamPage({super.key, required this.email});

  Future<String?> _getShiftNameByEmail(String email) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('shift_karyawan')
        .where('email', isEqualTo: email)
        .get();

    if (snapshot.docs.isNotEmpty) {
      var data = snapshot.docs.first.data() as Map<String, dynamic>;
      return data['nama_shift'];
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> _getShiftTeam(String namaShift) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('shift_karyawan')
        .where('nama_shift', isEqualTo: namaShift)
        .get();

    return snapshot.docs.map((doc) {
      var data = doc.data() as Map<String, dynamic>;
      return {
        'name': data['name'],
        'photoUrl': data['photoUrl'],
        'email': data['email'], // Tambahkan email untuk mencari biodata
      };
    }).toList();
  }

  Future<Map<String, dynamic>?> _getUserBiodata(String email) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('biodata')
        .where('email', isEqualTo: email)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first.data() as Map<String, dynamic>;
    }
    return null;
  }

  void _showUserDialog(
      BuildContext context, Map<String, dynamic> userData) async {
    String? phoneNumber;

    var biodata = await _getUserBiodata(userData['email']);
    if (biodata != null) {
      phoneNumber = biodata['phone'];
    }

    // Tambahkan log untuk memverifikasi phone number
    print("Phone Number: $phoneNumber");
    _showUserDetailsDialog(context, userData, phoneNumber);
  }

  void _showUserDetailsDialog(BuildContext context,
      Map<String, dynamic> userData, String? phoneNumber) {
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
          title: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(userData['photoUrl']),
              ),
              const SizedBox(width: 10),
              Text(
                userData['name'],
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text("Email: ${userData['email']}",
                  style: TextStyle(fontSize: 16)),
              if (phoneNumber != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text("Phone: $phoneNumber",
                      style: TextStyle(fontSize: 16)),
                ),
            ],
          ),
          actions: [
            Row(
              children: [
                if (phoneNumber != null) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        _openWhatsApp(phoneNumber);
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.grey),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                      ),
                      child: const Text(
                        "WhatsApp",
                        style: TextStyle(
                            color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                ],
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 10),
                    ),
                    child: const Text(
                      "Tutup",
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

  void _openWhatsApp(String phoneNumber) async {
    // Pastikan nomor telepon dihapus dari karakter selain angka
    final formattedPhoneNumber = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');

    // Format URL WhatsApp dengan nomor yang telah diformat
    final Uri url = Uri.parse("https://wa.me/$formattedPhoneNumber");

    // Coba untuk membuka WhatsApp dengan URL tersebut
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch WhatsApp with phone number: $formattedPhoneNumber';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _getShiftNameByEmail(email),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text('Shift tidak ditemukan.'));
        }

        String namaShift = snapshot.data!;

        return FutureBuilder<List<Map<String, dynamic>>>(
          future: _getShiftTeam(namaShift),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError || snapshot.data!.isEmpty) {
              return const Center(
                  child: Text('Tidak ada tim dengan shift tersebut.'));
            }

            var teamData = snapshot.data!;

            return Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Team Shift: $namaShift',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      height: 100,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: teamData.map((teamMember) {
                            return GestureDetector(
                              onTap: () => _showUserDialog(context, teamMember),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0),
                                child: Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.blue,
                                          width: 3,
                                        ),
                                      ),
                                      child: CircleAvatar(
                                        radius: 35,
                                        backgroundImage: NetworkImage(
                                            teamMember['photoUrl']),
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      teamMember['name'],
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
