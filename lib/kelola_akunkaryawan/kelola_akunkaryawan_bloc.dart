// kelola_akunkaryawan_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'kelola_akunkaryawan_event.dart';
import 'kelola_akunkaryawan_state.dart';

class KelolaAkunKaryawanBloc
    extends Bloc<KelolaAkunKaryawanEvent, KelolaAkunkaryawanState> {
  final FirebaseFirestore firestore;

  KelolaAkunKaryawanBloc({required this.firestore})
      : super(KelolaAkunkaryawanInitial()) {
    // Handler untuk FetchKaryawanEvent
    on<FetchKaryawanEvent>((event, emit) async {
      emit(KelolaAkunkaryawanLoading());

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

        emit(KelolaAkunkaryawanLoaded(karyawanList: karyawanList));
      } catch (e) {
        emit(KelolaAkunkaryawanError(message: 'Gagal memuat data.'));
      }
    });

    on<SimpanShiftEvent>((event, emit) async {
      emit(KelolaAkunkaryawanLoading());
      try {
        // Simpan shift ke Firestore
        for (var entry in event.selectedKaryawan.entries) {
          if (entry.value) {
            await firestore.collection('shifts').add({
              'email': entry.key,
              'shift': event.selectedShift,
              'timestamp': FieldValue.serverTimestamp(),
            });
          }
        }

        emit(KelolaAkunkaryawanSuccess(message: 'Shift berhasil disimpan.'));
      } catch (e) {
        emit(KelolaAkunkaryawanError(message: 'Gagal menyimpan shift.'));
      }
    });

    on<DeleteKaryawanEvent>((event, emit) async {
      if (event.email.isEmpty) {
        emit(KelolaAkunkaryawanError(message: 'Email tidak valid.'));
        return;
      }

      emit(KelolaAkunkaryawanLoading());

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

          emit(KelolaAkunkaryawanLoaded(karyawanList: karyawanList));
        } else {
          emit(KelolaAkunkaryawanError(message: 'Karyawan tidak ditemukan.'));
        }
      } catch (e) {
        emit(KelolaAkunkaryawanError(message: 'Gagal menghapus karyawan.'));
      }
    });
  }
}
