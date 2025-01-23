import 'dart:async';
import 'package:ARTShift/absensi/absensi_event.dart';
import 'package:ARTShift/absensi/absensi_state.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AbsensiBloc extends Bloc<AbsensiEvent, AbsensiState> {
  Timer? _timer;

  AbsensiBloc()
      : super(AbsensiState(
          canAbsenMasuk: true,
          canAbsenKeluar: false,
          isSakitOrIzin: false,
          currentTime: DateFormat('HH:mm:ss').format(DateTime.now()),
          absensiStatus: "",
          successMessage: "",
          errorMessage: "",
        )) {
    // Event untuk memperbarui waktu setiap detik
    on<CheckTimeEvent>((event, emit) {
      _timer?.cancel(); // Cancel previous timer if any
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        add(UpdateTimeEvent());
      });
    });

    on<UpdateTimeEvent>((event, emit) {
      emit(state.copyWith(
          currentTime: DateFormat('HH:mm:ss').format(DateTime.now())));
    });

    // Event untuk mengecek status absensi saat halaman dibuka
    on<CheckAbsensiEvent>((event, emit) async {
      final DateTime now = DateTime.now();
      final String formattedDate = DateFormat('dd-MM-yyyy').format(now);
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final String docId = event.email;

      try {
        final docRef = firestore.collection('absensi').doc(docId);
        final docSnapshot = await docRef.get();

        if (docSnapshot.exists) {
          final data = docSnapshot.data();
          if (data != null &&
              data.containsKey('keluar') &&
              data['keluar'] != null &&
              data['keluar']['tanggal'] == formattedDate) {
            // Jika sudah absen keluar, matikan semua tombol
            emit(state.copyWith(
              canAbsenMasuk: false,
              canAbsenKeluar: false,
              isSakitOrIzin: false,
              absensiStatus: "Sudah absen keluar",
              errorMessage: "Anda sudah melakukan absensi keluar hari ini!",
            ));
            return;
          }
        }
      } catch (e) {
        emit(state.copyWith(
          errorMessage: "Gagal memeriksa absensi: $e",
        ));
      }
    });

    // Event untuk menangani absensi masuk, keluar, sakit, dan izin
    on<OnSubmitAbsensi>((event, emit) async {
      final DateTime now = DateTime.now();
      final String formattedDate = DateFormat('dd-MM-yyyy').format(now);
      final String formattedTime = DateFormat('HH:mm:ss').format(now);
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final String docId = event.email;

      try {
        final docRef = firestore.collection('absensi').doc(docId);
        final docSnapshot = await docRef.get();

        if (!docSnapshot.exists) {
          await docRef.set({
            'email': event.email,
            'name': event.name,
            'hadir': null,
            'keluar': null,
            'sakit': null,
            'izin': null,
          });
        } else {
          final data = docSnapshot.data();
          if (data != null &&
              data.containsKey('keluar') &&
              data['keluar'] != null &&
              data['keluar']['tanggal'] == formattedDate) {
            emit(state.copyWith(
              canAbsenMasuk: false,
              canAbsenKeluar: false,
              isSakitOrIzin: false,
              absensiStatus: "Sudah absen keluar",
              errorMessage: "Anda sudah melakukan absensi keluar hari ini!",
            ));
            return;
          }
        }

        if (event.status == "Hadir") {
          await docRef.update({
            'hadir': {'tanggal': formattedDate, 'waktu': formattedTime},
          });

          emit(state.copyWith(
            canAbsenMasuk: false,
            canAbsenKeluar: true,
            isSakitOrIzin: true,
            absensiStatus: event.status,
            successMessage: "Anda telah absen masuk!",
          ));
        } else if (event.status == "Keluar") {
          await docRef.update({
            'keluar': {'tanggal': formattedDate, 'waktu': formattedTime},
          });

          emit(state.copyWith(
            canAbsenMasuk: false,
            canAbsenKeluar: false,
            isSakitOrIzin: false,
            absensiStatus: event.status,
            successMessage:
                "Anda telah absen keluar! Semua tombol dinonaktifkan.",
          ));
        } else if (event.status == "Sakit") {
          await docRef.update({
            'sakit': {'tanggal': formattedDate, 'waktu': formattedTime},
          });

          emit(state.copyWith(
            canAbsenMasuk: false,
            canAbsenKeluar: false,
            isSakitOrIzin: true,
            absensiStatus: event.status,
            successMessage: "Absensi sakit berhasil!",
          ));
        } else if (event.status == "Izin") {
          await docRef.update({
            'izin': {'tanggal': formattedDate, 'waktu': formattedTime},
          });

          emit(state.copyWith(
            canAbsenMasuk: false,
            canAbsenKeluar: false,
            isSakitOrIzin: true,
            absensiStatus: event.status,
            successMessage: "Absensi izin berhasil!",
          ));
        }
      } catch (e) {
        emit(state.copyWith(
          errorMessage: "Gagal menyimpan absensi: $e",
        ));
      }
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
