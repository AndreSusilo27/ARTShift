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

  void _refreshData(BuildContext context) {
    context.read<KelolaAkunKaryawanBloc>().add(FetchKaryawanEvent());
    setState(() {
      selectedAccounts = [];
    });
  }

  Future<void> saveSelectedAccountsToFirestore(
      BuildContext context, dynamic state) async {
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

          // Tampilkan dialog konfirmasi sebelum menyimpan
          bool? confirmSave = await showConfirmationDialog(
              context, karyawan['email'], selectedShiftData['nama_shift']);
          if (confirmSave != true) continue;

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

          _refreshData(context);
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

  Future<bool?> showConfirmationDialog(
      BuildContext context, String email, String shift) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(
                Icons.person_add,
                color: Colors.red,
                size: 28,
              ),
              SizedBox(width: 10),
              Text(
                "Konfirmasi Penyimpanan Shift Karyawan",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          content: Text(
              "Apakah Anda yakin ingin memberikan shift '$shift' kepada akun dengan email $email?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Batal", style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Ya", style: TextStyle(color: Colors.green)),
            ),
          ],
        );
      },
    );
  }

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
            title: Text('Kelola Shift Karyawan'),
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

              if (selectedAccounts.length != filteredKaryawanList.length) {
                selectedAccounts =
                    List.generate(filteredKaryawanList.length, (_) => false);
              }

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: const Text(
                          'Pilih karyawan yang ingin dikelola shift nya',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
                      const SizedBox(height: 20),
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
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onChanged: (newValue) {
                                  setState(() {
                                    selectedShift = newValue;
                                  });
                                },
                                dropdownColor: Colors.white,
                                icon:
                                    const Icon(Icons.arrow_drop_down, size: 24),
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.black),
                                isExpanded: false,
                                items: shiftData.map((shift) {
                                  return DropdownMenuItem<String>(
                                    value: shift['nama_shift'],
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
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
                                    context,
                                    context
                                        .read<KelolaAkunKaryawanBloc>()
                                        .state);
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
                      Container(
                        height: 425,
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
                                        radius: 28)
                                    : const CircleAvatar(
                                        radius: 28,
                                        child: Icon(Icons.person, size: 30)),
                                title: Text(karyawan['name'] ?? 'Tanpa Nama',
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600)),
                                subtitle: Text(
                                    "${karyawan['email'] ?? 'Tidak diketahui'}",
                                    style: const TextStyle(
                                        fontSize: 14,
                                        color: Color.fromARGB(
                                            255, 133, 133, 133))),
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
                      ),
                      const SizedBox(height: 25),
                      Divider(
                        color: Colors.black87,
                        thickness: 3,
                        indent: 20,
                        endIndent: 20,
                      ),
                      Center(
                        child: Column(
                          children: [
                            const Text(
                              'Menampilkan Akun Karyawan dengan Shift nya',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        height: 425,
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 15),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.blue[800]),
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: filteredKaryawanList.length,
                                itemBuilder: (context, index) {
                                  final karyawan = filteredKaryawanList[index];
                                  final photoUrl = karyawan['photoUrl'] ?? '';

                                  return FutureBuilder<Map<String, dynamic>>(
                                    future: getShiftByEmail(
                                        karyawan['email'] ?? ''),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Center(
                                            child: CircularProgressIndicator());
                                      } else if (snapshot.hasError) {
                                        return const Center(
                                            child: Text(
                                                'Error fetching shift data'));
                                      } else if (snapshot.hasData) {
                                        final shiftKaryawan =
                                            snapshot.data ?? {};

                                        return Card(
                                          elevation: 3,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          margin:
                                              EdgeInsets.fromLTRB(0, 10, 0, 0),
                                          child: ListTile(
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    vertical: 8,
                                                    horizontal: 12),
                                            leading: photoUrl.isNotEmpty
                                                ? CircleAvatar(
                                                    backgroundImage:
                                                        NetworkImage(photoUrl),
                                                    radius: 28,
                                                  )
                                                : const CircleAvatar(
                                                    radius: 28,
                                                    child: Icon(Icons.person,
                                                        size: 30),
                                                  ),
                                            title: Text(
                                              karyawan['name'] ?? 'Tanpa Nama',
                                              style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                            subtitle: Text(
                                              "${karyawan['email'] ?? 'Tidak diketahui'}",
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Color.fromARGB(
                                                      255, 133, 133, 133)),
                                            ),
                                            trailing: GestureDetector(
                                              onTap: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return Dialog(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                      ),
                                                      elevation: 16,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(20),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Text(
                                                                  'Shift Details',
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        20,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    color: Colors
                                                                        .blueGrey,
                                                                  ),
                                                                ),
                                                                IconButton(
                                                                  icon:
                                                                      const Icon(
                                                                    Icons.close,
                                                                    color: Colors
                                                                        .red,
                                                                    size: 30,
                                                                  ),
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                ),
                                                              ],
                                                            ),
                                                            const SizedBox(
                                                                height: 15),
                                                            Text(
                                                              'Nama Shift: ${shiftKaryawan['nama_shift'] ?? 'Tidak Tersedia'}',
                                                              style:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          16),
                                                            ),
                                                            const SizedBox(
                                                                height: 10),
                                                            Text(
                                                              'Jam Masuk: ${shiftKaryawan['jam_masuk'] ?? 'Tidak Tersedia'}',
                                                              style:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          16),
                                                            ),
                                                            const SizedBox(
                                                                height: 10),
                                                            Text(
                                                              'Jam Keluar: ${shiftKaryawan['jam_keluar'] ?? 'Tidak Tersedia'}',
                                                              style:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          16),
                                                            ),
                                                            const SizedBox(
                                                                height: 10),
                                                            Text(
                                                              'Tanggal Akhir: ${shiftKaryawan['tanggal_akhir'] ?? 'Tidak Tersedia'}',
                                                              style:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          16),
                                                            ),
                                                            const SizedBox(
                                                                height: 20),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                );
                                              },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8,
                                                        horizontal: 16),
                                                decoration: BoxDecoration(
                                                  color: Colors.blue,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  shiftKaryawan['nama_shift'] ??
                                                      'Tanpa Shift',
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      } else {
                                        return const Center(
                                            child: Text(
                                                'No shift data available'));
                                      }
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      )
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
}

Future<Map<String, dynamic>> getShiftByEmail(String email) async {
  try {
    // Mengambil data dari koleksi shift_karyawan berdasarkan email
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('shift_karyawan')
        .where('email', isEqualTo: email) // Filter berdasarkan email
        .get();

    if (snapshot.docs.isNotEmpty) {
      // Jika data ditemukan, ambil data pertama
      return snapshot.docs.first.data() as Map<String, dynamic>;
    } else {
      return {}; // Kembalikan kosong jika tidak ada data
    }
  } catch (e) {
    print('Error fetching shift data: $e');
    return {}; // Kembalikan kosong jika terjadi error
  }
}
