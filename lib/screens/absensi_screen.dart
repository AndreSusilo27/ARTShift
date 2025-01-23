import 'package:ARTShift/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ARTShift/absensi/absensi_bloc.dart';
import 'package:ARTShift/absensi/absensi_event.dart';
import 'package:ARTShift/absensi/absensi_state.dart';

class AbsensiScreen extends StatelessWidget {
  final String name;
  final String email;

  const AbsensiScreen({super.key, required this.name, required this.email});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AbsensiBloc()..add(CheckAbsensiEvent(email: email)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Absensi"),
          automaticallyImplyLeading: false,
        ),
        body: BlocBuilder<AbsensiBloc, AbsensiState>(
          builder: (context, state) {
            final bloc = BlocProvider.of<AbsensiBloc>(context);

            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Card header dengan biru sebagai warna utama
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
                            "Selamat Datang, $name",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors
                                  .blue[800], // Biru profesional untuk teks
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            email,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                          const Divider(thickness: 1, height: 20),
                          BlocListener<AbsensiBloc, AbsensiState>(
                            listenWhen: (previous, current) =>
                                previous.currentTime != current.currentTime,
                            listener: (context, state) {},
                            child: Text(
                              "Waktu saat ini: ${state.currentTime}",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color:
                                    Colors.blueAccent, // Biru aksen untuk waktu
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Card untuk tombol absensi dengan desain yang lebih profesional
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
                            color: Colors.blue[600]!, // Biru untuk tombol
                            onPressed:
                                state.canAbsenMasuk && !state.isSakitOrIzin
                                    ? () => bloc.add(OnSubmitAbsensi(
                                        email: email,
                                        name: name,
                                        status: "Hadir"))
                                    : null,
                          ),
                          const SizedBox(height: 10),
                          AbsensiButton(
                            text: "Absen Keluar",
                            icon: Icons.exit_to_app,
                            color: Colors
                                .blue[700]!, // Biru lebih gelap untuk tombol
                            onPressed: state.canAbsenKeluar
                                ? () => bloc.add(OnSubmitAbsensi(
                                    email: email, name: name, status: "Keluar"))
                                : null,
                          ),
                          const SizedBox(height: 10),
                          AbsensiButton(
                            text: "Sakit",
                            icon: Icons.local_hospital,
                            color: Colors.red[600]!, // Warna merah untuk Sakit
                            onPressed: state.canAbsenMasuk &&
                                    state.canAbsenKeluar == false
                                ? () => bloc.add(OnSubmitAbsensi(
                                    email: email, name: name, status: "Sakit"))
                                : null,
                          ),
                          const SizedBox(height: 10),
                          AbsensiButton(
                            text: "Izin",
                            icon: Icons.warning,
                            color:
                                Colors.orange[600]!, // Warna oranye untuk Izin
                            onPressed: state.canAbsenMasuk &&
                                    state.canAbsenKeluar == false
                                ? () => bloc.add(OnSubmitAbsensi(
                                    email: email, name: name, status: "Izin"))
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
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
          borderRadius:
              BorderRadius.circular(12), // Rounded button dengan lebih halus
        ),
        elevation: 5, // Slight shadow for depth
        minimumSize: Size(double.infinity, 50), // Tombol memenuhi lebar layar
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
