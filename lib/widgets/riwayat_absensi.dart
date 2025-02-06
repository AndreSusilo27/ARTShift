import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Widget untuk menampilkan riwayat absensi
class RiwayatAbsensiWidget extends StatefulWidget {
  final String email;

  const RiwayatAbsensiWidget({super.key, required this.email});

  @override
  State<RiwayatAbsensiWidget> createState() => _RiwayatAbsensiWidgetState();
}

class _RiwayatAbsensiWidgetState extends State<RiwayatAbsensiWidget> {
  DateTime? startDate;
  DateTime? endDate;
  bool isDataVisible = false;
  bool isAscending = false; // Menyimpan status pengurutan

  // Fungsi untuk memilih tanggal
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          isStartDate ? startDate ?? DateTime.now() : endDate ?? DateTime.now(),
      firstDate: DateTime(2025, 1, 1),
      lastDate: DateTime(2025, 12, 31),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

  // Fungsi untuk mengonversi string tanggal menjadi DateTime
  DateTime parseDate(String dateString) {
    return DateFormat('dd-MM-yyyy').parse(dateString);
  }

  Future<List<Map<String, dynamic>>> tampilkanRiwayatAbsensi() async {
    CollectionReference absensiRef = FirebaseFirestore.instance
        .collection('absensi')
        .doc(widget.email)
        .collection('absensi_harian');

    QuerySnapshot snapshot;

    // Mengurangi 1 hari untuk startDate dan menambah 1 hari untuk endDate
    DateTime modifiedStartDate = startDate != null
        ? startDate!.subtract(Duration(days: 1))
        : DateTime.now();
    DateTime modifiedEndDate =
        endDate != null ? endDate!.add(Duration(days: 1)) : DateTime.now();

    if (startDate != null && endDate != null) {
      DateFormat('dd-MM-yyyy').format(modifiedStartDate);
      DateFormat('dd-MM-yyyy').format(modifiedEndDate);

      // Membuat query berdasarkan tanggal yang sudah dimodifikasi
      snapshot = await absensiRef.get();
    } else {
      snapshot = await absensiRef.get();
    }

    List<Map<String, dynamic>> riwayatAbsensi = [];

    for (var doc in snapshot.docs) {
      String tanggal = doc.id; // Mengambil tanggal dari documentId (tanggal)

      // Mengonversi tanggal ke DateTime untuk perbandingan
      DateTime tanggalDoc = parseDate(tanggal);

      // Memeriksa apakah tanggal berada dalam rentang yang dipilih
      if (startDate != null &&
          endDate != null &&
          tanggalDoc.isAfter(modifiedStartDate) &&
          tanggalDoc.isBefore(modifiedEndDate)) {
        bool hadir = doc['hadir'] != null && doc['hadir'] != '';
        bool izin = doc['izin'] != null && doc['izin'] != '';
        bool keluar = doc['keluar'] != null && doc['keluar'] != '';
        bool sakit = doc['sakit'] != null && doc['sakit']['waktu'] != null;

        String status = 'A';
        Color warna = Colors.red;

        if (hadir) {
          status = 'H';
          warna = Colors.green;
        } else if (sakit) {
          status = 'S';
          warna = Colors.yellow;
        } else if (izin) {
          status = 'I';
          warna = Colors.yellow;
        } else if (keluar) {
          status = 'K';
          warna = Colors.blue;
        }

        riwayatAbsensi.add({
          'tanggal': tanggal,
          'status': status,
          'warna': warna,
          'dateTime': tanggalDoc, // Menyimpan objek DateTime
        });
      }
    }

    // Mengurutkan data berdasarkan tanggal
    riwayatAbsensi.sort((a, b) {
      if (isAscending) {
        return a['dateTime'].compareTo(b['dateTime']);
      } else {
        return b['dateTime'].compareTo(a['dateTime']);
      }
    });

    return riwayatAbsensi;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Judul Riwayat Kehadiran
            Center(
              child: Text(
                'Riwayat Kehadiran',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
            Divider(color: Colors.blue, thickness: 1),
            SizedBox(width: 10),

            // Row untuk memilih tanggal mulai dan tanggal akhir
            Row(
              children: [
                // TextField untuk memilih tanggal mulai
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectDate(context, true),
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.blue, width: 1),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today, color: Colors.blue),
                          SizedBox(width: 10),
                          Text(
                            startDate == null
                                ? 'Tanggal Mulai'
                                : '${DateFormat('dd-MM-yyyy').format(startDate!)}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                // TextField untuk memilih tanggal akhir
                Expanded(
                  child: GestureDetector(
                    onTap: () => _selectDate(context, false),
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.blue, width: 1),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today, color: Colors.blue),
                          SizedBox(width: 10),
                          Text(
                            endDate == null
                                ? 'Tanggal Akhir'
                                : '${DateFormat('dd-MM-yyyy').format(endDate!)}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            // Mengganti tombol urutkan data dengan dropdown, ditempatkan sejajar dengan tombol
            Row(
              mainAxisAlignment: MainAxisAlignment
                  .center, // Untuk memastikan sejajar di tengah
              children: [
                // Tombol untuk menampilkan atau menyembunyikan data
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    shadowColor: Colors.blueAccent,
                    elevation: 4,
                  ),
                  onPressed: () {
                    setState(() {
                      isDataVisible = !isDataVisible;
                    });
                  },
                  child: Text(
                    isDataVisible ? 'Sembunyikan Data' : 'Tampilkan Data',
                    style: TextStyle(
                      fontSize: 16, // Ukuran font yang lebih besar
                      fontWeight:
                          FontWeight.w600, // Menggunakan font yang lebih tebal
                    ),
                  ),
                ),

                SizedBox(
                  width: 10,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: DropdownButton<bool>(
                    value: isAscending,
                    onChanged: (bool? newValue) {
                      setState(() {
                        isAscending = newValue!;
                      });
                    },
                    items: [
                      DropdownMenuItem<bool>(
                        value: true,
                        child: Text('Terbaru'),
                      ),
                      DropdownMenuItem<bool>(
                        value: false,
                        child: Text('Terlama'),
                      ),
                    ],
                    hint: Text('Pilih Urutan'),
                    iconEnabledColor: Colors.blue,
                    iconSize: 40,
                  ),
                ),
              ],
            ),

            SizedBox(height: 16),
            // Menampilkan riwayat absensi jika tombol ditekan
            isDataVisible
                ? Center(
                    // Center the data table
                    child: FutureBuilder<List<Map<String, dynamic>>>(
                      future: tampilkanRiwayatAbsensi(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        }

                        if (snapshot.hasError) {
                          return Text('Terjadi kesalahan');
                        }

                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Text('Tidak ada riwayat absensi.');
                        }

                        // Menampilkan tabel riwayat absensi
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('Tanggal')),
                              DataColumn(label: Text('Status')),
                            ],
                            rows: snapshot.data!.map((absensi) {
                              return DataRow(
                                cells: [
                                  DataCell(
                                    Text(
                                      absensi['tanggal'],
                                      textAlign:
                                          TextAlign.center, // Center the text
                                    ),
                                  ),
                                  DataCell(
                                    Container(
                                      color: absensi['warna'],
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      child: Text(
                                        absensi['status'],
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold),
                                        textAlign:
                                            TextAlign.center, // Center the text
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        );
                      },
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
