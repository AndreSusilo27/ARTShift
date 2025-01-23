import 'package:ARTShift/kelola_akunadmin/kelola_akunadmin_bloc.dart';
import 'package:ARTShift/kelola_akunadmin/kelola_akunadmin_event.dart';
import 'package:ARTShift/kelola_akunadmin/kelola_akunadmin_state.dart';
import 'package:ARTShift/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class KelolaAkunAdminScreen extends StatefulWidget {
  const KelolaAkunAdminScreen({super.key});

  @override
  State<KelolaAkunAdminScreen> createState() => _KelolaAkunAdminScreenState();
}

class _KelolaAkunAdminScreenState extends State<KelolaAkunAdminScreen> {
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
            title: Text('Kelola Akun Admin'),
            automaticallyImplyLeading: false,
          ),
        ),
      ),
      body: BlocProvider(
        create: (context) =>
            KelolaAkunAdminBloc(firestore: FirebaseFirestore.instance)
              ..add(FetchAdminEvent()),
        child: BlocBuilder<KelolaAkunAdminBloc, KelolaAkunAdminState>(
          builder: (context, state) {
            if (state is KelolaAkunAdminLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is KelolaAkunAdminError) {
              return Center(
                  child: Text(state.message,
                      style: const TextStyle(color: Colors.red)));
            }

            if (state is KelolaAkunAdminLoaded) {
              List<dynamic> filteredAdminList = state.adminList
                  .where((admin) =>
                      admin['name']
                          .toLowerCase()
                          .contains(searchQuery.toLowerCase()) ||
                      admin['email']
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
                        'Hapus akun admin yang tidak diperlukan.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Cari Admin',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: Container(
                        height: 420, // Ukuran tetap 420 piksel
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey,
                          borderRadius: BorderRadius.circular(12),
                        ),

                        child: ListView.builder(
                          itemCount: filteredAdminList.length,
                          itemBuilder: (context, index) {
                            final admin = filteredAdminList[index];
                            final photoUrl = admin['photoUrl'] ?? '';

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
                                  admin['name'] ?? 'Tanpa Nama',
                                  style: const TextStyle(
                                    fontSize:
                                        18, // Ukuran font judul lebih jelas
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  "${admin['email'] ?? 'Tidak diketahui'}",
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
                                          context, admin['email']);
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

            return const Center(child: Text("Tidak ada data admin."));
          },
        ),
      ),
      floatingActionButton: CustomFloatingBackButton(),
    );
  }

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
                Navigator.of(dialogContext).pop();
                context
                    .read<KelolaAkunAdminBloc>()
                    .add(DeleteAdminEvent(email: email));
              },
              child: const Text("Hapus", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
