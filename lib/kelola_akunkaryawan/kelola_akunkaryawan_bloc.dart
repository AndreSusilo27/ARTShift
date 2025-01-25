import 'dart:io';
import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'kelola_akunkaryawan_event.dart';
import 'kelola_akunkaryawan_state.dart';

class KelolaAkunKaryawanBloc
    extends Bloc<KelolaAkunKaryawanEvent, KelolaAkunkaryawanState> {
  final FirebaseFirestore firestore;

  KelolaAkunKaryawanBloc({required this.firestore})
      : super(KelolaAkunkaryawanInitial()) {
    on<FetchKaryawanEvent>(_fetchKaryawan);
    on<FetchKaryawanEvent2>(_exportDataToExcel);
    on<SimpanShiftEvent>(_simpanShift);
    on<DeleteKaryawanEvent>(_deleteKaryawan);
  }

  Future<void> _fetchKaryawan(
      FetchKaryawanEvent event, Emitter<KelolaAkunkaryawanState> emit) async {
    emit(KelolaAkunkaryawanLoading());
    try {
      final karyawanSnapshot = await firestore
          .collection('users')
          .where('role', isEqualTo: 'Karyawan')
          .get();

      List<Map<String, dynamic>> karyawanList =
          karyawanSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'name': data['name'] ?? 'Tanpa Nama',
          'email': data['email'] ?? 'Tidak diketahui',
          'photoUrl': data['photoUrl'] ?? '',
        };
      }).toList();

      emit(KelolaAkunkaryawanLoaded(karyawanList: karyawanList));
    } catch (e) {
      emit(KelolaAkunkaryawanError(
          message: 'Gagal memuat data: ${e.toString()}'));
    }
  }

  Future<void> _exportDataToExcel(
      FetchKaryawanEvent2 event, Emitter<KelolaAkunkaryawanState> emit) async {
    emit(KelolaAkunkaryawanLoading());
    try {
      final karyawanSnapshot = await firestore
          .collection('users')
          .where('role', isEqualTo: 'Karyawan')
          .get();
      if (karyawanSnapshot.docs.isEmpty) {
        emit(KelolaAkunkaryawanError(message: "Tidak ada data karyawan."));
        return;
      }

      List<Map<String, dynamic>> karyawanList =
          karyawanSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'name': data['name'] ?? 'Tanpa Nama',
          'email': data['email'] ?? '',
        };
      }).toList();

      var excel = Excel.createExcel();
      Sheet sheet = excel['Absensi'];
      sheet.appendRow([
        TextCellValue('Nama Karyawan'),
        TextCellValue('Tanggal'),
        TextCellValue('Jam Masuk'),
        TextCellValue('Jam Keluar'),
        TextCellValue('Keterangan'),
      ]);

      bool adaData = false;
      for (var karyawan in karyawanList) {
        String email = karyawan['email'];
        if (email.isEmpty) continue;

        final absensiSnapshot = await firestore
            .collection('absensi')
            .doc(email)
            .collection('absensi_harian')
            .get();
        if (absensiSnapshot.docs.isNotEmpty) {
          adaData = true;
          for (var doc in absensiSnapshot.docs) {
            var data = doc.data();
            sheet.appendRow([
              TextCellValue(karyawan['name']),
              TextCellValue(data['tanggal'] ?? ''),
              TextCellValue(data['jamMasuk'] ?? ''),
              TextCellValue(data['jamKeluar'] ?? ''),
              TextCellValue(data['keterangan'] ?? ''),
            ]);
          }
        }
      }

      if (!adaData) {
        emit(KelolaAkunkaryawanError(
            message: "Tidak ada data absensi yang diekspor."));
        return;
      }
      var bytes = excel.save();
      if (bytes != null) {
        Uint8List uint8ListBytes =
            Uint8List.fromList(bytes); // Konversi List<int> ke Uint8List

        String filePath = await saveExcelToStorage(uint8ListBytes,
            "Absensi_Karyawan_${DateTime.now().millisecondsSinceEpoch}");

        event.scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text("Data berhasil diekspor: $filePath"),
            backgroundColor: Colors.green,
          ),
        );
      }

      emit(KelolaAkunkaryawanLoaded(karyawanList: karyawanList));
    } catch (e) {
      emit(KelolaAkunkaryawanError(
          message: 'Gagal mengekspor data: ${e.toString()}'));
    }
  }

  Future<String> saveExcelToStorage(Uint8List bytes, String fileName) async {
    try {
      Directory? directory = Directory('/storage/emulated/0/Download');
      if (!directory.existsSync()) {
        directory = await getApplicationDocumentsDirectory();
      }
      final file = File('${directory.path}/$fileName.xlsx');
      await file.writeAsBytes(bytes);
      return file.path;
    } catch (e) {
      return "Gagal menyimpan file: ${e.toString()}";
    }
  }

  Future<void> _simpanShift(
      SimpanShiftEvent event, Emitter<KelolaAkunkaryawanState> emit) async {
    emit(KelolaAkunkaryawanLoading());
    try {
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
      emit(KelolaAkunkaryawanError(
          message: 'Gagal menyimpan shift: ${e.toString()}'));
    }
  }

  Future<void> _deleteKaryawan(
      DeleteKaryawanEvent event, Emitter<KelolaAkunkaryawanState> emit) async {
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
      emit(KelolaAkunkaryawanError(
          message: 'Gagal menghapus karyawan: ${e.toString()}'));
    }
  }
}
