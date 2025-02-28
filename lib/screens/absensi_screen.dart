import 'package:ARTShift/widgets/apptheme.dart';
import 'package:ARTShift/widgets/custom_button.dart';
import 'package:ARTShift/widgets/keterlambatan.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ARTShift/absensi/absensi_bloc.dart';
import 'package:ARTShift/absensi/absensi_event.dart';
import 'package:ARTShift/absensi/absensi_state.dart';

class AbsensiScreen extends StatefulWidget {
  final String name;
  final String email;

  const AbsensiScreen({super.key, required this.name, required this.email});

  @override
  State<AbsensiScreen> createState() => _AbsensiScreenState();
}

class _AbsensiScreenState extends State<AbsensiScreen> {
  bool isLate = false;
  String status = "";

  // Data shift karyawan
  String jamMasuk = "00:00";
  String jamKeluar = "00:00";
  String namaShift = "";
  String namekaryawan = "";
  String photoUrlkaryawan = "";
  String tanggalAkhir = "";

  Future<void> _fetchShiftData() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('shift_karyawan')
          .doc(widget.email)
          .get();

      if (doc.exists && doc.data() != null) {
        setState(() {
          final data = doc.data() as Map<String, dynamic>;
          jamMasuk = data['jam_masuk'] ?? "00:00";
          jamKeluar = data['jam_keluar'] ?? "00:00";
          namaShift = data['nama_shift'] ?? "";
          namekaryawan = data['name'] ?? widget.name;
          photoUrlkaryawan = data['photoUrl'] ?? "";
          tanggalAkhir = data['tanggal_akhir'] ?? "";
        });
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  void _handleJamMasukSelected(String newStatus) {
    final absensiState = context.read<AbsensiBloc>().state;

    setState(() {
      if (absensiState.absensiStatus == "Belum terdaftar dalam shift") {
        isLate = false;
        status = "Tidak memiliki shift";
      } else if (absensiState.isSakitOrIzin) {
        isLate = false;
        status = "Tidak dapat absen (Sakit/Izin)";
      } else if (newStatus == "late") {
        isLate = true;
        status = "Terlambat";
      } else if (newStatus == "onTime") {
        isLate = false;
        status = "Tepat Waktu";
      } else if (newStatus == "belum_waktu_absen") {
        isLate = true;
        status = "Belum Waktu Absen";
      }
    });
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
    Future.delayed(const Duration(seconds: 1), () {
      Navigator.of(context).pop();
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchShiftData();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AbsensiBloc()..add(CheckAbsensiEvent(email: widget.email)),
      child: Scaffold(
        appBar: AppTheme.appBar(titleText: 'Absensi'),
        body: BlocBuilder<AbsensiBloc, AbsensiState>(
          builder: (context, state) {
            final bloc = BlocProvider.of<AbsensiBloc>(context);
            return Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/bg2.png"),
                  fit: BoxFit.cover,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text(
                              "Selamat Datang, ${widget.name}",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[800],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.email,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                            const Divider(thickness: 1, height: 20),
                            BlocBuilder<AbsensiBloc, AbsensiState>(
                              builder: (context, state) {
                                return Text(
                                  "Waktu Sekarang: ${state.currentTime}",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueAccent,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 8),
                            Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 5,
                              color: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.work,
                                            color: Colors.blue, size: 30),
                                        const SizedBox(width: 10),
                                        Text(
                                          "Jadwal Shift",
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue[800],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),

                                    Row(
                                      children: [
                                        Icon(Icons.person,
                                            color: Colors.grey[700]),
                                        const SizedBox(width: 10),
                                        Text(
                                          "Nama: $namekaryawan",
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                    const Divider(),

                                    Row(
                                      children: [
                                        Icon(Icons.schedule,
                                            color: Colors.grey[700]),
                                        const SizedBox(width: 10),
                                        Text(
                                          "Shift: $namaShift",
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                    const Divider(),

                                    Row(
                                      children: [
                                        Icon(Icons.login, color: Colors.green),
                                        const SizedBox(width: 10),
                                        Text(
                                          "Jam Masuk: $jamMasuk",
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                    const Divider(),

                                    Row(
                                      children: [
                                        Icon(Icons.logout, color: Colors.red),
                                        const SizedBox(width: 10),
                                        Text(
                                          "Jam Keluar: $jamKeluar",
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                    const Divider(),

                                    // Tanggal Akhir
                                    Row(
                                      children: [
                                        Icon(Icons.date_range,
                                            color: Colors.orange),
                                        const SizedBox(width: 10),
                                        Text(
                                          "Tanggal Akhir: $tanggalAkhir",
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    ShiftKaryawanWidget(
                      email: widget.email,
                      onJamMasukSelected: _handleJamMasukSelected,
                    ),
                    const SizedBox(height: 10),
                    Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            AbsensiButton(
                              text: "Absen Hadir",
                              icon: Icons.check_circle,
                              color: Colors.blue[600]!,
                              onPressed: isLate ||
                                      !state.canAbsenMasuk ||
                                      state.isSakitOrIzin
                                  ? null
                                  : () {
                                      bloc.add(OnSubmitAbsensi(
                                        email: widget.email,
                                        name: widget.name,
                                        status: "Hadir",
                                      ));
                                      _showSuccessDialog(
                                          "Absensi Hadir Berhasil");
                                    },
                            ),
                            const SizedBox(height: 10),
                            AbsensiButton(
                              text: "Absen Keluar",
                              icon: Icons.exit_to_app,
                              color: Colors.blue[700]!,
                              onPressed: isLate || !state.canAbsenKeluar
                                  ? null
                                  : () {
                                      bloc.add(OnSubmitAbsensi(
                                        email: widget.email,
                                        name: widget.name,
                                        status: "Keluar",
                                      ));
                                      _showSuccessDialog(
                                          "Absensi Keluar Berhasil");
                                    },
                            ),
                            const SizedBox(height: 10),
                            AbsensiButton(
                              text: "Sakit",
                              icon: Icons.local_hospital,
                              color: Colors.red[600]!,
                              onPressed: isLate ||
                                      !state.canAbsenMasuk ||
                                      state.canAbsenKeluar
                                  ? null
                                  : () {
                                      bloc.add(OnSubmitAbsensi(
                                        email: widget.email,
                                        name: widget.name,
                                        status: "Sakit",
                                      ));
                                      _showSuccessDialog(
                                          "Absensi Sakit Berhasil");
                                    },
                            ),
                            const SizedBox(height: 10),
                            AbsensiButton(
                              text: "Izin",
                              icon: Icons.warning,
                              color: Colors.orange[600]!,
                              onPressed: isLate ||
                                      !state.canAbsenMasuk ||
                                      state.canAbsenKeluar
                                  ? null
                                  : () {
                                      bloc.add(OnSubmitAbsensi(
                                        email: widget.email,
                                        name: widget.name,
                                        status: "Izin",
                                      ));
                                      _showSuccessDialog(
                                          "Absensi Izin Berhasil");
                                    },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        floatingActionButton: const CustomFloatingBackButton(),
      ),
    );
  }
}

class AbsensiButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;

  const AbsensiButton({
    required this.text,
    required this.icon,
    required this.color,
    this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 5,
        minimumSize: Size(double.infinity, 50),
      ),
      icon: Icon(icon, color: Colors.white),
      label: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      onPressed: onPressed,
    );
  }
}
