import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ARTShift/widgets/apptheme.dart';
import 'package:ARTShift/widgets/cardmeeting.dart';
import 'package:ARTShift/widgets/custom_drawer_admin.dart';

class DashboardAdminScreen extends StatefulWidget {
  final String email;
  final String name;
  final String photoUrl;

  const DashboardAdminScreen(this.name, this.email, this.photoUrl, {super.key});

  @override
  State<DashboardAdminScreen> createState() => _DashboardAdminScreenState();
}

class _DashboardAdminScreenState extends State<DashboardAdminScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int jumlahKaryawan = 0;
  int jumlahAdmin = 0;
  int jumlahShiftKategori = 0;
  int jumlahJadwalMeeting = 0;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      // Mengambil jumlah Karyawan
      QuerySnapshot karyawanSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'Karyawan')
          .get();
      int karyawanCount = karyawanSnapshot.docs.length;

      // Mengambil jumlah Admin
      QuerySnapshot adminSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'Admin')
          .get();
      int adminCount = adminSnapshot.docs.length;

      // Mengambil jumlah Shift Kategori
      QuerySnapshot shiftSnapshot =
          await FirebaseFirestore.instance.collection('shift_kategori').get();
      int shiftKategoriCount = shiftSnapshot.docs.length;

      // Mengambil jumlah Jadwal Meeting
      QuerySnapshot jadwalMeetingSnapshot =
          await FirebaseFirestore.instance.collection('jadwal_meeting').get();
      int jadwalMeetingCount = jadwalMeetingSnapshot.docs.length;

      // Memperbarui state dengan data yang diambil
      setState(() {
        jumlahKaryawan = karyawanCount;
        jumlahAdmin = adminCount;
        jumlahShiftKategori = shiftKategoriCount;
        jumlahJadwalMeeting =
            jadwalMeetingCount; // Menyimpan jumlah jadwal meeting
      });
    } catch (e) {
      print('Error mengambil data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppTheme.customAppBar(scaffoldKey: _scaffoldKey),
      drawer: CustomDrawerAdmin(
        name: widget.name,
        email: widget.email,
        photoUrl: widget.photoUrl,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/bg2.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: RefreshIndicator(
          onRefresh: fetchData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Dashboard Admin",
                    style: TextStyle(
                      fontSize: 24, // Ukuran teks yang cukup besar untuk judul
                      fontWeight: FontWeight.bold, // Membuat teks tebal
                      color: Colors.white, // Warna putih
                    ),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Flex Row pertama
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildStatContainer(
                                  'assets/icons/icon_menu/kelolakaryawan.png',
                                  'Karyawan',
                                  jumlahKaryawan),
                              SizedBox(width: 15),
                              _buildStatContainer(
                                  'assets/icons/icon_menu/kelolaadmin.png',
                                  'Admin',
                                  jumlahAdmin),
                            ],
                          ),
                          SizedBox(height: 16), // Spacing between the rows
                          // Flex Row kedua
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildStatContainer(
                                  'assets/icons/icon_menu/shift.png',
                                  'Shift Kategori',
                                  jumlahShiftKategori),
                              SizedBox(width: 15),
                              _buildStatContainer(
                                  'assets/icons/icon_menu/meeting.png',
                                  'Jadwal Meeting',
                                  jumlahJadwalMeeting),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Divider(
                    color: Colors.white, // Warna putih untuk divider
                    thickness: 2, // Ketebalan divider
                    indent: 20, // Jarak awal dari divider
                    endIndent: 20, // Jarak akhir dari divider
                  ),
                  Text(
                    "List Meeting",
                    style: TextStyle(
                      fontSize: 24, // Ukuran teks yang cukup besar untuk judul
                      fontWeight: FontWeight.bold, // Membuat teks tebal
                      color: Colors.white, // Warna putih
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    margin: const EdgeInsets.all(10),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(203, 255, 255, 255),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const SizedBox(
                      height: 500,
                      child: MeetingList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Fungsi untuk membuat container stat dengan gambar dan data
Widget _buildStatContainer(String imagePath, String title, int data) {
  return Expanded(
    child: Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$data',
                style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              SizedBox(width: 10),
              // Menambahkan latar belakang biru dengan opacity pada gambar
              Container(
                decoration: BoxDecoration(
                  color: Color(0x1A2196F3), // Warna biru dengan opasitas 0.1
                  borderRadius: BorderRadius.circular(5), // Membulatkan sudut
                ),
                padding: EdgeInsets.all(
                    5), // Menambahkan padding untuk latar belakang
                child: Image.asset(
                  imagePath,
                  width: 25, // Ukuran gambar ikon
                  height: 25, // Ukuran gambar ikon
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
