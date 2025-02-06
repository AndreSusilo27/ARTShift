import 'package:flutter/material.dart';
import 'package:ARTShift/widgets/cardmeeting.dart';
import 'package:ARTShift/widgets/faqlist.dart'; // Ganti dengan widget yang sesuai

class TabBarWidget extends StatefulWidget {
  final String email; // Menyimpan email dari halaman pemanggil
  final String name; // Menyimpan nama dari halaman pemanggil

  const TabBarWidget({super.key, required this.email, required this.name});

  @override
  State<TabBarWidget> createState() => _TabBarWidgetState();
}

class _TabBarWidgetState extends State<TabBarWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController; // Controller untuk tab bar

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: 2, vsync: this); // Menentukan jumlah tab
  }

  @override
  void dispose() {
    _tabController
        .dispose(); // Pastikan controller dibuang ketika widget dihapus
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10.0),
      padding:
          const EdgeInsets.all(10.0), // Penambahan padding yang lebih konsisten
      decoration: BoxDecoration(
        color: const Color.fromARGB(135, 255, 255,
            255), // Warna latar belakang menjadi putih agar lebih jelas
        borderRadius: BorderRadius.circular(
            15), // Radius border lebih besar untuk tampilan lebih halus
        boxShadow: const [
          BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 3)), // Shadow lebih lembut
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize:
            MainAxisSize.min, // Menyesuaikan ukuran column dengan konten
        children: [
          // TabBar dengan margin kiri dan kanan
          Container(
            margin: const EdgeInsets.symmetric(
                horizontal: 25.0), // Menambahkan margin pada TabBar
            decoration: BoxDecoration(
              color: Colors.white, // Background putih
              borderRadius: BorderRadius.circular(
                  8), // Memberikan border radius agar lebih mirip tombol
            ),
            child: TabBar(
              controller: _tabController,
              indicatorColor:
                  Colors.blueAccent, // Warna indikator yang lebih lembut
              labelColor: Colors
                  .blue[900], // Warna label aktif putih agar lebih kontras
              unselectedLabelColor:
                  Colors.blueAccent, // Warna label yang tidak aktif biru
              labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold), // Menebalkan teks label
              unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight
                      .normal), // Menormalisasi teks label yang tidak aktif
              tabs: const [
                Tab(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        vertical:
                            10.0), // Menambahkan padding vertikal untuk efek tombol
                    child: Text('List Meeting'),
                  ),
                ),
                Tab(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        vertical:
                            10.0), // Menambahkan padding vertikal untuk efek tombol
                    child: Text('List FAQ'),
                  ),
                ),
              ],
            ),
          ),
          // TabBarView dengan konten terbatas tinggi 500
          Flexible(
            child: SizedBox(
              height: 450,
              width: 450,
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Konten Tab 1 (Meeting List)
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child:
                        MeetingList(), // Panggil MeetingList langsung tanpa pembungkus tambahan
                  ),
                  // Konten Tab 2 (FAQ)
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: FAQList(
                        showCount: false), // Memastikan tampilan tetap bersih
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
