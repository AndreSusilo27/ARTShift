import 'package:ARTShift/widgets/apptheme.dart';
import 'package:ARTShift/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:open_file/open_file.dart';

class DataAbsensiScreen extends StatelessWidget {
  final String userEmail;

  const DataAbsensiScreen({super.key, required this.userEmail});

  void _showExportConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          titlePadding: const EdgeInsets.all(20),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          actionsPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          title: const Row(
            children: [
              Icon(Icons.file_download, color: Colors.blue, size: 28),
              SizedBox(width: 10),
              Text("Konfirmasi Ekspor",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          content: const Text(
            "Apakah Anda yakin ingin mengekspor data absensi ke file Excel?",
            style: TextStyle(fontSize: 16),
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
                      "Batal",
                      style: TextStyle(
                          color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      _exportToExcel(context);
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.grey),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 10),
                    ),
                    child: const Text(
                      "Ya, Ekspor",
                      style: TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.bold),
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

  Future<void> _exportToExcel(BuildContext context) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('absensi')
        .doc(userEmail)
        .collection('absensi_harian')
        .get();

    if (snapshot.docs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tidak ada data absensi untuk diekspor'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    var excel = Excel.createExcel();
    Sheet sheet = excel['Sheet1'];

    sheet.cell(CellIndex.indexByString('A1')).value = TextCellValue('Tanggal');
    sheet.cell(CellIndex.indexByString('B1')).value = TextCellValue('Hadir');
    sheet.cell(CellIndex.indexByString('C1')).value = TextCellValue('Keluar');
    sheet.cell(CellIndex.indexByString('D1')).value = TextCellValue('Sakit');
    sheet.cell(CellIndex.indexByString('E1')).value = TextCellValue('Izin');

    int row = 2;
    for (var doc in snapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      var tanggal = data['tanggal'] ?? 'Tidak ada tanggal';
      var hadir = data['hadir']?['waktu'] ?? 'Belum hadir';
      var keluar = data['keluar']?['waktu'] ?? 'Belum keluar';
      var sakit = data['sakit'] ?? 'Tidak sakit';
      var izin = data['izin'] ?? 'Tidak izin';

      sheet.cell(CellIndex.indexByString('A$row')).value =
          TextCellValue(tanggal);
      sheet.cell(CellIndex.indexByString('B$row')).value = TextCellValue(hadir);
      sheet.cell(CellIndex.indexByString('C$row')).value =
          TextCellValue(keluar);
      sheet.cell(CellIndex.indexByString('D$row')).value = TextCellValue(sakit);
      sheet.cell(CellIndex.indexByString('E$row')).value = TextCellValue(izin);
      row++;
    }

    final directory = await getApplicationDocumentsDirectory();
    final username = userEmail.split('@').first;
    final filePath = '${directory.path}/absensi_$username.xlsx';
    final file = File(filePath);
    await file.writeAsBytes(excel.encode()!);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data berhasil diekspor ke Excel'),
        backgroundColor: Colors.green,
      ),
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("File Berhasil Disimpan"),
          content: Text("File telah disimpan di:\n$filePath"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                OpenFile.open(filePath);
              },
              child: const Text("Buka File"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Tutup"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTheme.appBar(titleText: 'Data Absensi'),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(50, 0, 0, 0),
                  blurRadius: 8,
                  spreadRadius: 2,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                'Data Absensi - $userEmail',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(5),
              margin: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: const Color.fromARGB(203, 255, 255, 255),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                  bottomLeft: Radius.circular(0),
                  bottomRight: Radius.circular(0),
                ),
              ),
              child: FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                    .collection('absensi')
                    .doc(userEmail)
                    .collection('absensi_harian')
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text('Terjadi kesalahan'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('Tidak ada data absensi'));
                  }

                  return Container(
                    height: 670,
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.blue[800]),
                    child: ListView.builder(
                      padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        var absensi = snapshot.data!.docs[index];
                        var tanggal = absensi['tanggal'] ?? 'Tidak ada tanggal';
                        var hadir = absensi['hadir']?['waktu'] ?? 'Belum hadir';
                        var keluar =
                            absensi['keluar']?['waktu'] ?? 'Belum keluar';
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
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Hadir: $hadir'),
                                Text('Keluar: $keluar'),
                                Text('Sakit: $sakit'),
                                Text('Izin: $izin'),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(
            width: 50,
            height: 50,
            child: FloatingActionButton(
              heroTag: "Export",
              onPressed: () => _showExportConfirmation(context),
              tooltip: 'Export ke Excel',
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              child: const Icon(Icons.print, size: 24),
            ),
          ),
          const SizedBox(height: 16),
          const CustomFloatingBackButton(),
        ],
      ),
    );
  }
}
