import 'package:ARTShift/kelola_akunkaryawan/kelola_akunkaryawan_bloc.dart';
import 'package:ARTShift/kelola_akunkaryawan/kelola_akunkaryawan_event.dart';
import 'package:ARTShift/kelola_akunkaryawan/kelola_akunkaryawan_state.dart';
import 'package:ARTShift/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class KelolaShiftKaryawanScreen extends StatefulWidget {
  const KelolaShiftKaryawanScreen({super.key});

  @override
  State<KelolaShiftKaryawanScreen> createState() =>
      _KelolaShiftKaryawanScreenState();
}

class _KelolaShiftKaryawanScreenState extends State<KelolaShiftKaryawanScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> shiftData = [];
  String? selectedShift;
  String searchQuery = '';
  List<bool> selectedAccounts = [];

  @override
  void initState() {
    super.initState();
    fetchShiftData();
  }

  // Ambil data shift dari Firestore
  Future<void> fetchShiftData() async {
    try {
      QuerySnapshot snapshot =
          await _firestore.collection('shift_kategori').get();
      setState(() {
        shiftData = snapshot.docs.map((doc) {
          return {
            'nama_shift': doc['nama_shift'],
            'jam_masuk': doc['jam_masuk'],
            'jam_keluar': doc['jam_keluar'],
            'tanggal_akhir': doc['tanggal_akhir'],
          };
        }).toList();
      });
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<void> saveSelectedAccountsToFirestore(dynamic state) async {
    try {
      for (int i = 0; i < selectedAccounts.length; i++) {
        if (selectedAccounts[i]) {
          final karyawan = state.karyawanList[i];

          // Ambil detail shift yang dipilih
          final selectedShiftData = shiftData.firstWhere(
            (shift) => shift['nama_shift'] == selectedShift,
            orElse: () => {},
          );

          // Jika shift tidak ditemukan, lewati penyimpanan
          if (selectedShiftData.isEmpty) continue;

          // Data yang akan disimpan ke Firestore
          final shiftKaryawanData = {
            'name': karyawan['name'],
            'email': karyawan['email'],
            'nama_shift': selectedShiftData['nama_shift'],
            'jam_masuk': selectedShiftData['jam_masuk'],
            'jam_keluar': selectedShiftData['jam_keluar'],
            'tanggal_akhir': selectedShiftData['tanggal_akhir'],
            'update_at': DateTime.now().toIso8601String(),
            'photoUrl': karyawan['photoUrl'] ?? '',
          };

          // Simpan ke Firestore dengan ID dokumen menggunakan email
          await _firestore
              .collection('shift_karyawan')
              .doc(karyawan['email'])
              .set(shiftKaryawanData);

          print("Data shift untuk ${karyawan['email']} berhasil disimpan.");
        }
      }

      // Menampilkan notifikasi atau feedback
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Data shift karyawan berhasil disimpan."),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print("Error saat menyimpan data shift karyawan: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Terjadi kesalahan: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kelola Shift Karyawan"),
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
              // Filter karyawan list berdasarkan search query
              List<dynamic> filteredKaryawanList = state.karyawanList
                  .where((karyawan) =>
                      karyawan['name']
                          .toLowerCase()
                          .contains(searchQuery.toLowerCase()) ||
                      karyawan['email']
                          .toLowerCase()
                          .contains(searchQuery.toLowerCase()))
                  .toList();

              // Inisialisasi checkbox untuk tiap karyawan
              if (selectedAccounts.length != filteredKaryawanList.length) {
                selectedAccounts =
                    List.generate(filteredKaryawanList.length, (_) => false);
              }

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Judul dan kata-kata
                    const Text(
                      'Kelola Shift Karyawan',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Pilih akun yang ingin dikelola atau dihapus.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),

                    // Search, Dropdown, and Save button
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: TextField(
                              onChanged: (value) {
                                setState(() {
                                  searchQuery = value;
                                });
                              },
                              decoration: InputDecoration(
                                labelText: 'Cari Karyawan',
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 16),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Dropdown Button untuk memilih shift
                        Container(
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey, width: 1),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedShift,
                              hint: const Text(
                                'Pilih Shift',
                                style: TextStyle(fontSize: 14),
                              ),
                              onChanged: (newValue) {
                                setState(() {
                                  selectedShift = newValue;
                                });
                              },
                              dropdownColor: Colors.white,
                              icon: const Icon(Icons.arrow_drop_down, size: 24),
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.black),
                              isExpanded: false,
                              items: shiftData.map((shift) {
                                return DropdownMenuItem<String>(
                                  value: shift['nama_shift'],
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    child: Text(
                                      "${shift['nama_shift']} (${shift['jam_masuk']} - ${shift['jam_keluar']})",
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                offset: Offset(0, 4),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: IconButton(
                            onPressed: () {
                              if (selectedShift == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text("Pilih shift terlebih dahulu!"),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              if (!selectedAccounts.contains(true)) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text("Pilih minimal satu karyawan!"),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              saveSelectedAccountsToFirestore(
                                  context.read<KelolaAkunKaryawanBloc>().state);
                            },
                            icon: const Icon(
                              Icons.save,
                              color: Colors.white,
                            ),
                            tooltip: "Simpan Shift Karyawan",
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Container untuk menampilkan data akun karyawan
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
                              trailing: Checkbox(
                                value: selectedAccounts[index],
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5)),
                                checkColor: Colors.white,
                                activeColor: Colors.blue,
                                onChanged: (bool? value) {
                                  setState(() {
                                    selectedAccounts[index] = value!;
                                  });
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    )),
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
}
