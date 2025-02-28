import 'package:ARTShift/screens/absensi_screen.dart';
import 'package:ARTShift/widgets/apptheme.dart';
import 'package:ARTShift/widgets/custom_drawer_karyawan.dart';
import 'package:ARTShift/widgets/riwayat_absensi.dart';
import 'package:ARTShift/widgets/shift_team.dart';
import 'package:ARTShift/widgets/tabbar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  bool showShiftDetails = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> _fetchShiftData() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('shift_karyawan')
          .doc(widget.email)
          .get();

      if (doc.exists && doc.data() != null) {
        setState(() {
          final data = doc.data() as Map<String, dynamic>;
          jamMasuk = data['jam_masuk'] ?? "00:00";
          jamKeluar = data['jam_keluar'] ?? "00:00";
          namaShift = data['nama_shift'] ?? "";
          namekaryawan = widget.name;
          photoUrlkaryawan = widget.photoUrl;
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
    _fetchShiftData();
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
      body: Container(
        height: 825,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/bg2.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: RefreshIndicator(
          onRefresh: _fetchShiftData,
          child: SingleChildScrollView(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 10),
                    Text(
                      "Dashboard Karyawan",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10),
                    Card(
                      margin: const EdgeInsets.all(10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 47,
                              backgroundImage: NetworkImage(widget.photoUrl),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.name,
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    widget.email,
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                  const SizedBox(height: 8),
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        showShiftDetails = !showShiftDetails;
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor: Colors.blue,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 5,
                                      padding: EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 24),
                                    ),
                                    child: Text(
                                      showShiftDetails
                                          ? "Sembunyikan Shift"
                                          : "Lihat Shift",
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  AnimatedCrossFade(
                                    firstChild: const SizedBox.shrink(),
                                    secondChild: Card(
                                      margin: const EdgeInsets.only(top: 10),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(7),
                                        side: BorderSide(
                                            color: Colors.blue, width: 2),
                                      ),
                                      elevation: 5,
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text("Shift: $namaShift",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                    color: Colors.black87)),
                                            SizedBox(height: 8),
                                            Text("Jam: $jamMasuk - $jamKeluar",
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black54)),
                                            SizedBox(height: 8),
                                            Text("Tanggal Akhir: $tanggalAkhir",
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black54)),
                                          ],
                                        ),
                                      ),
                                    ),
                                    crossFadeState: showShiftDetails
                                        ? CrossFadeState.showSecond
                                        : CrossFadeState.showFirst,
                                    duration: const Duration(milliseconds: 300),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AbsensiScreen(
                                      email: widget.email,
                                      name: widget.name,
                                    ),
                                  ),
                                );
                              },
                              icon: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(50, 3, 168, 244),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Image.asset(
                                  'assets/icons/icon_menu/kehadiran.png',
                                  width: 30,
                                  height: 30,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Divider(
                      color: Colors.white,
                      thickness: 2,
                      indent: 20,
                      endIndent: 20,
                    ),
                    SizedBox(height: 10),
                    ShiftTeamPage(email: widget.email),
                    RiwayatAbsensiWidget(email: widget.email),
                    Divider(
                      color: Colors.white,
                      thickness: 2,
                      indent: 20,
                      endIndent: 20,
                    ),
                    SizedBox(height: 10),
                    TabBarWidget(
                      email: widget.email,
                      name: widget.name,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
