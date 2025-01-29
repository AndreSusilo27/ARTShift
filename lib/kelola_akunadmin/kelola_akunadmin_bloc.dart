// kelola_akunkaryawan_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'kelola_akunadmin_event.dart';
import 'kelola_akunadmin_state.dart';

class KelolaAkunAdminBloc
    extends Bloc<KelolaAkunAdminEvent, KelolaAkunAdminState> {
  final FirebaseFirestore firestore;

  KelolaAkunAdminBloc({required this.firestore})
      : super(KelolaAkunAdminInitial()) {
    on<FetchAdminEvent>((event, emit) async {
      emit(KelolaAkunAdminLoading());

      try {
        final karyawanSnapshot = await firestore
            .collection('users')
            .where('role', isEqualTo: 'Admin')
            .get();

        List<Map<String, dynamic>> adminList = karyawanSnapshot.docs.map((doc) {
          final data = doc.data();

          return {
            'name': data.containsKey('name')
                ? data['name'] ?? 'Tanpa Nama'
                : 'Tanpa Nama',
            'email': data.containsKey('email')
                ? data['email'] ?? 'Tidak diketahui'
                : 'Tidak diketahui',
            'photoUrl':
                data.containsKey('photoUrl') ? data['photoUrl'] ?? '' : '',
          };
        }).toList();

        emit(KelolaAkunAdminLoaded(adminList: adminList));
      } catch (e) {
        emit(KelolaAkunAdminError(message: 'Gagal memuat data.'));
      }
    });

    on<DeleteAdminEvent>((event, emit) async {
      if (event.email.isEmpty) {
        emit(KelolaAkunAdminError(message: 'Email tidak valid.'));
        return;
      }

      emit(KelolaAkunAdminLoading());

      try {
        final querySnapshot = await firestore
            .collection('users')
            .where('email', isEqualTo: event.email)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          for (var doc in querySnapshot.docs) {
            await doc.reference.delete();
          }

          final karyawanSnapshot = await firestore.collection('users').get();
          List<Map<String, dynamic>> adminList =
              karyawanSnapshot.docs.map((doc) => doc.data()).toList();

          emit(KelolaAkunAdminLoaded(adminList: adminList));
        } else {
          emit(KelolaAkunAdminError(message: 'Karyawan tidak ditemukan.'));
        }
      } catch (e) {
        emit(KelolaAkunAdminError(message: 'Gagal menghapus karyawan.'));
      }
    });
  }
}
