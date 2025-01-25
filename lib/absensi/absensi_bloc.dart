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
    // Memulai timer hanya sekali saat pertama kali
    _startTimer();

    // Event untuk memperbarui waktu setiap detik
    on<CheckTimeEvent>((event, emit) {
      // Tidak perlu cancel jika timer sudah ada
      if (_timer == null || !_timer!.isActive) {
        _startTimer();
      }
    });

    on<UpdateTimeEvent>((event, emit) {
      emit(state.copyWith(
          currentTime: DateFormat('HH:mm:ss').format(DateTime.now())));
    });

    on<CheckAbsensiEvent>((event, emit) async {
      final DateTime now = DateTime.now();
      final String formattedDate = DateFormat('dd-MM-yyyy').format(now);
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      final String docId = event.email;

      try {
        final docRef = firestore
            .collection('absensi')
            .doc(docId)
            .collection('absensi_harian')
            .doc(formattedDate);
        final docSnapshot = await docRef.get();

        if (docSnapshot.exists) {
          final data = docSnapshot.data();
          if (data != null && data['keluar'] != null) {
            emit(state.copyWith(
              canAbsenMasuk: false,
              canAbsenKeluar: false,
              isSakitOrIzin: false,
              absensiStatus: "Sudah absen keluar",
              errorMessage: "Anda sudah melakukan absensi keluar hari ini!",
            ));
          } else if (data!['hadir'] != null) {
            emit(state.copyWith(
              canAbsenMasuk: false,
              canAbsenKeluar: true,
              isSakitOrIzin: false,
              absensiStatus: "Sudah absen masuk",
              successMessage: "Anda sudah absen masuk!",
            ));
          }
        } else {
          emit(state.copyWith(
            canAbsenMasuk: true,
            canAbsenKeluar: false,
            isSakitOrIzin: false,
            absensiStatus: "Belum ada absensi hari ini",
            successMessage: "Silakan absen masuk!",
          ));
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
        final docRef = firestore
            .collection('absensi')
            .doc(docId)
            .collection('absensi_harian')
            .doc(formattedDate);

        final docSnapshot = await docRef.get();

        if (!docSnapshot.exists) {
          await docRef.set({
            'tanggal': formattedDate,
            'hadir': null,
            'keluar': null,
            'sakit': null,
            'izin': null,
          });
        }

        if (event.status == "Hadir") {
          await docRef.update({
            'hadir': {'waktu': formattedTime},
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
            'keluar': {'waktu': formattedTime},
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
            'sakit': {'waktu': formattedTime},
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
            'izin': {'waktu': formattedTime},
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

  // Memulai timer hanya sekali
  void _startTimer() {
    if (_timer == null || !_timer!.isActive) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        add(UpdateTimeEvent());
      });
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
