import 'package:ARTShift/kelola_akunadmin/kelola_akunadmin_bloc.dart';
import 'package:ARTShift/kelola_akunadmin/kelola_akunadmin_event.dart';
import 'package:ARTShift/kelola_akunadmin/kelola_akunadmin_state.dart';
import 'package:ARTShift/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class KelolaAkunAdminScreen extends StatefulWidget {
  const KelolaAkunAdminScreen({super.key});

  @override
  State<KelolaAkunAdminScreen> createState() => _KelolaAkunAdminScreenState();
}

class _KelolaAkunAdminScreenState extends State<KelolaAkunAdminScreen> {
  String searchQuery = '';
  String? currentUserEmail;

  @override
  void initState() {
    super.initState();
    _getCurrentUserEmail();
  }

  void _getCurrentUserEmail() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        currentUserEmail = user.email;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kelola Akun Admin'),
        automaticallyImplyLeading: false,
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
                      Container(
                        height: 670, // Ukuran tetap 420 piksel
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 15),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.blue[800]),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: filteredAdminList.length,
                          itemBuilder: (context, index) {
                            final admin = filteredAdminList[index];
                            final photoUrl = admin['photoUrl'] ?? '';
                            final adminEmail = admin['email'] ?? '';

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
                                  admin['name'] ?? 'Tanpa Nama',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  adminEmail,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color.fromARGB(255, 133, 133, 133),
                                  ),
                                ),
                                trailing: currentUserEmail == adminEmail
                                    ? null
                                    : InkWell(
                                        borderRadius: BorderRadius.circular(8),
                                        onTap: () {
                                          _showDeleteConfirmationDialog(
                                              context, adminEmail);
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: Colors.red.withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                            size: 22,
                                          ),
                                        ),
                                      ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
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
          title: const Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.red,
                size: 28,
              ),
              SizedBox(width: 10),
              Text(
                "Konfirmasi Hapus Akun Admin",
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
