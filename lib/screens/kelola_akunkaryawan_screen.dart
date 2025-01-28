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
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 2,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: AppBar(
            title: Text('Kelola Akun Karyawan'),
            automaticallyImplyLeading: false,
          ),
        ),
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

              return SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: const Text(
                          'Hapus akun karyawan yang tidak diperlukan.',
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
                      Container(
                        height: 670, // Ukuran tetap 420 piksel
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 15),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.blue[800]),
                        child: Expanded(
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
                                          backgroundImage:
                                              NetworkImage(photoUrl),
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
                                        right:
                                            8), // Padding agar lebih seimbang
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
                                          borderRadius:
                                              BorderRadius.circular(8),
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
          title: const Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.red,
                size: 28,
              ),
              SizedBox(width: 10),
              Text(
                "Konfirmasi Hapus Akun Karyawan",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          content: Text("Apakah Anda yakin ingin menghapus akun $email?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text("Batal", style: TextStyle(color: Colors.green)),
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
