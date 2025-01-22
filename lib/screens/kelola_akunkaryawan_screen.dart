import 'package:ARTShift/kelola_akunkaryawan/kelola_akunkaryawan_bloc.dart';
import 'package:ARTShift/kelola_akunkaryawan/kelola_akunkaryawan_event.dart';
import 'package:ARTShift/kelola_akunkaryawan/kelola_akunkaryawan_state.dart';
import 'package:ARTShift/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class KelolaAkunKaryawanScreen extends StatefulWidget {
  const KelolaAkunKaryawanScreen({super.key});

  @override
  State<KelolaAkunKaryawanScreen> createState() =>
      _KelolaAkunKaryawanScreenState();
}

class _KelolaAkunKaryawanScreenState extends State<KelolaAkunKaryawanScreen> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kelola Akun Karyawan"),
        automaticallyImplyLeading: false,
      ),
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
                    // Judul
                    const Text(
                      'Kelola Akun Karyawan',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Hapus akun karyawan yang tidak diperlukan.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
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

                    // List Akun Karyawan
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredKaryawanList.length,
                          itemBuilder: (context, index) {
                            final karyawan = filteredKaryawanList[index];
                            final photoUrl = karyawan['photoUrl'] ?? '';

                            return Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              margin: const EdgeInsets.symmetric(
                                  vertical: 6, horizontal: 10),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 12),
                                leading: photoUrl.isNotEmpty
                                    ? CircleAvatar(
                                        backgroundImage: NetworkImage(photoUrl),
                                        radius: 28, // Lebih proporsional
                                      )
                                    : const CircleAvatar(
                                        radius: 28,
                                        child: Icon(Icons.person, size: 30),
                                      ),
                                title: Text(
                                  karyawan['name'] ?? 'Tanpa Nama',
                                  style: const TextStyle(
                                    fontSize:
                                        18, // Ukuran font judul lebih jelas
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  "${karyawan['email'] ?? 'Tidak diketahui'}",
                                  style: const TextStyle(
                                    fontSize:
                                        14, // Ukuran font email diperbaiki
                                    color: Color.fromARGB(255, 133, 133, 133),
                                  ),
                                ),
                                trailing: Padding(
                                  padding: const EdgeInsets.only(
                                      right: 8), // Padding agar lebih seimbang
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(
                                        8), // Efek klik membulat
                                    onTap: () {
                                      _showDeleteConfirmationDialog(
                                          context, karyawan['email']);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(
                                          6), // Spasi agar tidak terlalu rapat
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(
                                            0.1), // Warna merah transparan agar tidak terlalu tajam
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                        size: 22, // Ukuran lebih proporsional
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
      floatingActionButton: CustomFloatingBackButton(),
    );
  }

  // Fungsi untuk menampilkan dialog konfirmasi sebelum menghapus akun
  void _showDeleteConfirmationDialog(BuildContext context, String email) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Konfirmasi Hapus"),
          content: Text("Apakah Anda yakin ingin menghapus akun $email?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text("Batal"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Tutup dialog
                context
                    .read<KelolaAkunKaryawanBloc>()
                    .add(DeleteKaryawanEvent(email: email));
              },
              child: const Text("Hapus", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
