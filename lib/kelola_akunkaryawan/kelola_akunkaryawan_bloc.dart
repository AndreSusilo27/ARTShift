// kelola_akunkaryawan_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'kelola_akunkaryawan_event.dart';
import 'kelola_akunkaryawan_state.dart';

class KelolaShiftKaryawanBloc
    extends Bloc<KelolaAkunkaryawanEvent, KelolaShiftKaryawanState> {
  final FirebaseFirestore firestore;

  KelolaShiftKaryawanBloc({required this.firestore})
      : super(KelolaShiftKaryawanInitial()) {
    // Handler untuk FetchKaryawanEvent
    on<FetchKaryawanEvent>((event, emit) async {
      emit(KelolaShiftKaryawanLoading());

      try {
        final karyawanSnapshot = await firestore
            .collection('users')
            .where('role', isEqualTo: 'Karyawan')
            .get();

        List<Map<String, dynamic>> karyawanList =
            karyawanSnapshot.docs.map((doc) {
          final data = doc.data();

          // Menambahkan photoUrl ke dalam map karyawan
          return {
            'name': data.containsKey('name')
                ? data['name'] ?? 'Tanpa Nama'
                : 'Tanpa Nama',
            'email': data.containsKey('email')
                ? data['email'] ?? 'Tidak diketahui'
                : 'Tidak diketahui',
            'photoUrl': data.containsKey('photoUrl')
                ? data['photoUrl'] ?? '' // Memastikan photoUrl tidak null
                : '', // Jika tidak ada photoUrl, beri nilai kosong
          };
        }).toList();

        emit(KelolaShiftKaryawanLoaded(karyawanList: karyawanList));
      } catch (e) {
        emit(KelolaShiftKaryawanError(message: 'Gagal memuat data.'));
      }
    });

    on<DeleteKaryawanEvent>((event, emit) async {
      if (event.email.isEmpty) {
        emit(KelolaShiftKaryawanError(message: 'Email tidak valid.'));
        return;
      }

      emit(KelolaShiftKaryawanLoading());

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
          List<Map<String, dynamic>> karyawanList =
              karyawanSnapshot.docs.map((doc) => doc.data()).toList();

          emit(KelolaShiftKaryawanLoaded(karyawanList: karyawanList));
        } else {
          emit(KelolaShiftKaryawanError(message: 'Karyawan tidak ditemukan.'));
        }
      } catch (e) {
        emit(KelolaShiftKaryawanError(message: 'Gagal menghapus karyawan.'));
      }
    });
  }
}
