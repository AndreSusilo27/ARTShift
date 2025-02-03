import 'package:ARTShift/kelola_akunkaryawan/kelola_akunkaryawan_bloc.dart';
import 'package:ARTShift/kelola_akunkaryawan/kelola_akunkaryawan_event.dart';
import 'package:ARTShift/kelola_akunkaryawan/kelola_akunkaryawan_state.dart';
import 'package:ARTShift/screens/data_absensi_screen.dart';
import 'package:ARTShift/widgets/apptheme.dart';
import 'package:ARTShift/widgets/custom_button.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class LaporanScreen extends StatefulWidget {
  const LaporanScreen({super.key});

  @override
  State<LaporanScreen> createState() => _LaporanScreenState();
}

class _LaporanScreenState extends State<LaporanScreen> {
  String searchQuery = '';

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

  void _exportToExcel(BuildContext context) {
    // Memastikan Bloc sudah di-provide
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    // Menggunakan read untuk mendapatkan Bloc dan mengirimkan event
    context.read<KelolaAkunKaryawanBloc>().add(
          FetchKaryawanEvent2(
              scaffoldMessenger: scaffoldMessenger, context: context),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTheme.appBar(titleText: 'Laporan'),
      body: BlocProvider(
        create: (context) =>
            KelolaAkunKaryawanBloc(firestore: FirebaseFirestore.instance)
              ..add(FetchKaryawanEvent()),
        child: BlocBuilder<KelolaAkunKaryawanBloc, KelolaAkunkaryawanState>(
          builder: (context, state) {
            if (state is KelolaAkunkaryawanLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is KelolaAkunkaryawanError) {
              return Center(
                  child: Text(state.message,
                      style: const TextStyle(color: Colors.red)));
            }

            if (state is KelolaAkunkaryawanLoaded) {
              List<dynamic> filteredKaryawanList = state.karyawanList
                  .where((karyawan) =>
                      karyawan['name']
                          .toLowerCase()
                          .contains(searchQuery.toLowerCase()) ||
                      karyawan['email']
                          .toLowerCase()
                          .contains(searchQuery.toLowerCase()))
                  .toList();

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: const Text(
                        'Pilih karyawan yang ingin anda lihat Absensi nya.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Search field
                    TextField(
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Cari Karyawan',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: Container(
                        height: 670,
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 15),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.blue[800]),
                        child: ListView.builder(
                          itemCount: filteredKaryawanList.length,
                          itemBuilder: (context, index) {
                            final karyawan = filteredKaryawanList[index];
                            final photoUrl = karyawan['photoUrl'] ?? '';

                            return Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 12),
                                leading: photoUrl.isNotEmpty
                                    ? CircleAvatar(
                                        backgroundImage: NetworkImage(photoUrl),
                                        radius: 28,
                                      )
                                    : const CircleAvatar(
                                        radius: 28,
                                        child: Icon(Icons.person, size: 30),
                                      ),
                                title: Text(
                                  karyawan['name'] ?? 'Tanpa Nama',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  "${karyawan['email'] ?? 'Tidak diketahui'}",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color.fromARGB(255, 133, 133, 133),
                                  ),
                                ),
                                trailing: Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              DataAbsensiScreen(
                                                  userEmail: karyawan['email']),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(
                                            50, 3, 168, 244),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.calendar_today,
                                        color: Colors.blue,
                                        size: 22,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return const Center(child: Text("Tidak ada data karyawan."));
          },
        ),
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
