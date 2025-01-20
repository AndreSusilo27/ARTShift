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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kelola Akun Admin"),
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
              return ListView.builder(
                itemCount: state.adminList.length,
                itemBuilder: (context, index) {
                  final admin = state.adminList[index];
                  final photoUrl = admin['photoUrl'] ??
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
                      title: Text(admin['name'] ?? 'Tanpa Nama'),
                      subtitle:
                          Text("Email: ${admin['email'] ?? 'Tidak diketahui'}"),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          // Trigger delete by email
                          context.read<KelolaAkunAdminBloc>().add(
                              DeleteAdminEvent(email: admin['email'] ?? ''));
                        },
                      ),
                    ),
                  );
                },
              );
            }

            return const Center(child: Text("Tidak ada data admin."));
          },
        ),
      ),
      floatingActionButton: CustomFloatingBackButton(),
    );
  }
}
