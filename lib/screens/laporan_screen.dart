import 'package:ARTShift/laporan/laporan_bloc.dart';
import 'package:ARTShift/laporan/laporan_event.dart';
import 'package:ARTShift/laporan/laporan_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LaporanScreen extends StatefulWidget {
  const LaporanScreen({super.key});

  @override
  State<LaporanScreen> createState() => _LaporanScreenState();
}

class _LaporanScreenState extends State<LaporanScreen> {
  final TextEditingController filterController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Saat pertama kali masuk ke halaman, ambil semua data absensi
    context.read<LaporanBloc>().add(FetchLaporanEvent(''));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Absensi'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Input Email
            TextField(
              controller: filterController,
              decoration: const InputDecoration(
                labelText: 'Masukkan Email untuk Filter',
              ),
            ),
            const SizedBox(height: 10),

            // Tombol Cari Data
            ElevatedButton(
              onPressed: () {
                final filterEmail = filterController.text.trim();
                context.read<LaporanBloc>().add(FetchLaporanEvent(filterEmail));
              },
              child: const Text('Cari Data'),
            ),
            const SizedBox(height: 20),

            // List Data
            Expanded(
              child: BlocBuilder<LaporanBloc, LaporanState>(
                builder: (context, state) {
                  if (state is LaporanLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is LaporanError) {
                    return Center(child: Text(state.message));
                  } else if (state is LaporanLoaded) {
                    return state.laporanData.isNotEmpty
                        ? ListView.builder(
                            itemCount: state.laporanData.length,
                            itemBuilder: (context, index) {
                              final data = state.laporanData[index];
                              return Card(
                                elevation: 3,
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: ListTile(
                                  title: Text(data['email'] ?? 'No Email'),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          'Hadir: ${data['hadir']?['tanggal'] ?? '-'} - ${data['hadir']?['waktu'] ?? '-'}'),
                                      Text(
                                          'Izin: ${data['izin'] ?? 'Tidak Ada'}'),
                                      Text(
                                          'Keluar: ${data['keluar']?['tanggal'] ?? '-'} - ${data['keluar']?['waktu'] ?? '-'}'),
                                      Text(
                                          'Sakit: ${data['sakit'] ?? 'Tidak Ada'}'),
                                    ],
                                  ),
                                ),
                              );
                            },
                          )
                        : const Center(
                            child: Text('Tidak ada data yang ditemukan'));
                  } else {
                    return const Center(child: Text('Terjadi kesalahan.'));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
