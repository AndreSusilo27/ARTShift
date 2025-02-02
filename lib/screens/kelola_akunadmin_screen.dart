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
                        height: 670,
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
                                    : Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // Icon Tong Sampah
                                          InkWell(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            onTap: () {
                                              _showDeleteConfirmationDialog(
                                                  context, adminEmail);
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color: const Color.fromARGB(
                                                    50, 244, 67, 54),
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
                                          const SizedBox(width: 10),

                                          InkWell(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            onTap: () {
                                              String adminName = admin['name'];
                                              _showBiodataDialog(context,
                                                  adminEmail, adminName);
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color: const Color.fromARGB(
                                                    60, 3, 168, 244),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: const Icon(
                                                Icons.person_search_sharp,
                                                color: Colors.blue,
                                                size: 22,
                                              ),
                                            ),
                                          ),
                                        ],
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

// Fungsi untuk menampilkan data biodata berdasarkan email
void _showBiodataDialog(
    BuildContext context, String email, String adminName) async {
  try {
    // Mengambil biodata berdasarkan email (sebagai ID dokumen)
    Map<String, String> biodata =
        await _fetchBiodataFromEmail(email, adminName);

    // Menampilkan dialog dengan data biodata
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            'Biodata - $adminName',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: biodata.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Text(
                        '${entry.key}: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        entry.value,
                        style: TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Tutup',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );
  } catch (e) {
    // Jika terjadi error, tampilkan pesan error
    _showErrorDialog(context, 'Terjadi kesalahan, coba lagi');
  }
}

// Fungsi untuk mengambil data biodata berdasarkan email
Future<Map<String, String>> _fetchBiodataFromEmail(
    String email, String adminName) async {
  // Ambil dokumen berdasarkan email yang digunakan sebagai ID dokumen
  DocumentSnapshot snapshot =
      await FirebaseFirestore.instance.collection('biodata').doc(email).get();

  if (snapshot.exists) {
    // Ambil data dari dokumen dan kembalikan dalam bentuk map
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return {
      'Name': adminName,
      'Email': email,
      'No.Tlp': data['phone'] ?? 'Tidak Tersedia',
      'Alamat': data['address'] ?? 'Tidak Tersedia',
      'Jenis Kelamin': data['gender'] ?? 'Tidak Tersedia',
      'Pekerjaan': data['job'] ?? 'Tidak Tersedia',
      'Dibuat Pada': (data['created_at'] != null)
          ? (data['created_at'] as Timestamp).toDate().toString()
          : 'Tidak Tersedia',
    };
  } else {
    throw Exception('Data tidak ditemukan');
  }
}

// Menampilkan dialog error jika terjadi kesalahan
void _showErrorDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: const Text('Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              'Tutup',
              style: TextStyle(
                color: Colors.red,
              ),
            ),
          ),
        ],
      );
    },
  );
}
