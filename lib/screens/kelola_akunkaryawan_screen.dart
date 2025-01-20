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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kelola Akun Karyawan"),
        automaticallyImplyLeading: false,
      ),
      body: BlocProvider(
        create: (context) =>
            KelolaShiftKaryawanBloc(firestore: FirebaseFirestore.instance)
              ..add(FetchKaryawanEvent()),
        child: BlocBuilder<KelolaShiftKaryawanBloc, KelolaShiftKaryawanState>(
          builder: (context, state) {
            if (state is KelolaShiftKaryawanLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is KelolaShiftKaryawanError) {
              return Center(
                  child: Text(state.message,
                      style: const TextStyle(color: Colors.red)));
            }

            if (state is KelolaShiftKaryawanLoaded) {
              return ListView.builder(
                itemCount: state.karyawanList.length,
                itemBuilder: (context, index) {
                  final karyawan = state.karyawanList[index];
                  final photoUrl = karyawan['photoUrl'] ??
                      ''; // memastikan jika null akan menjadi string kosong
                  return Card(
                    margin: const EdgeInsets.all(10),
                    child: ListTile(
                      // Displaying photoUrl using CircleAvatar or Image.network
                      leading: photoUrl.isNotEmpty
                          ? CircleAvatar(
                              backgroundImage: NetworkImage(photoUrl),
                              radius: 25,
                            )
                          : const CircleAvatar(
                              radius: 25,
                              child: Icon(Icons.person),
                            ),
                      title: Text(karyawan['name'] ?? 'Tanpa Nama'),
                      subtitle: Text(
                          "Email: ${karyawan['email'] ?? 'Tidak diketahui'}"),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          // Trigger delete by email
                          context.read<KelolaShiftKaryawanBloc>().add(
                              DeleteKaryawanEvent(
                                  email: karyawan['email'] ?? ''));
                        },
                      ),
                    ),
                  );
                },
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
