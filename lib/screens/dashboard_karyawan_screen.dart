import 'package:ARTShift/widgets/apptheme.dart';
import 'package:ARTShift/widgets/cardmeeting.dart';
import 'package:ARTShift/widgets/custom_drawer_karyawan.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Pastikan sudah mengimpor cloud_firestore

class DashboardKaryawanScreen extends StatefulWidget {
  final String email;
  final String name;
  final String photoUrl;

  const DashboardKaryawanScreen(this.name, this.email, this.photoUrl,
      {super.key});

  @override
  State<DashboardKaryawanScreen> createState() =>
      _DashboardKaryawanScreenState();
}

class _DashboardKaryawanScreenState extends State<DashboardKaryawanScreen> {
  // Data shift karyawan
  String jamMasuk = "00:00";
  String jamKeluar = "00:00";
  String namaShift = "";
  String namekaryawan = "";
  String photoUrlkaryawan = "";
  String tanggalAkhir = "";

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Fungsi untuk mengambil data shift karyawan dari Firestore
  Future<void> _fetchShiftData() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('shift_karyawan')
          .doc(widget.email) // Mengambil data berdasarkan email
          .get();

      if (doc.exists && doc.data() != null) {
        setState(() {
          final data = doc.data() as Map<String, dynamic>;
          jamMasuk = data['jam_masuk'] ?? "00:00";
          jamKeluar = data['jam_keluar'] ?? "00:00";
          namaShift = data['nama_shift'] ?? "";
          namekaryawan =
              data['name'] ?? widget.name; // Gunakan nama yang sudah ada
          photoUrlkaryawan = data['photoUrl'] ??
              widget.photoUrl; // Gunakan photoUrl yang sudah ada
          tanggalAkhir = data['tanggal_akhir'] ?? "";
        });
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchShiftData(); // Memanggil fungsi untuk mengambil data saat halaman pertama kali dimuat
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppTheme.customAppBar(scaffoldKey: _scaffoldKey),
      drawer: CustomDrawerKaryawan(
        name: widget.name,
        email: widget.email,
        photoUrl: widget.photoUrl,
      ),
      body: SingleChildScrollView(
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundImage: NetworkImage(photoUrlkaryawan),
                            ),
                            Positioned(
                              bottom: 4,
                              right: 8,
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(color: Colors.white, width: 2),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "Selamat datang, ${widget.name}",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          widget.email,
                          style:
                              const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Card menampilkan data shift
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 8,
                  shadowColor: Colors.black.withOpacity(0.1),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "SHIFT",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueGrey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "$namaShift",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "$jamMasuk - $jamKeluar",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Tanggal Akhir:",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "$tanggalAkhir",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Menggunakan Expanded dengan ukuran tetap 500px
                Container(
                  margin: const EdgeInsets.all(
                      10), // Menambahkan margin luar sebesar 10
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors
                        .blueGrey, // Menambahkan warna latar belakang blue-grey
                    borderRadius:
                        BorderRadius.circular(15), // Sudut Card melengkung
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: SizedBox(
                    height: 500, // Menentukan tinggi tetap 500px
                    child:
                        MeetingList(), // MeetingList tetap berada dalam SizedBox
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
