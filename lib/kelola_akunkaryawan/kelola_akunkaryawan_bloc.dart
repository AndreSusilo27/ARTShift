import 'dart:io';
import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'kelola_akunkaryawan_event.dart';
import 'kelola_akunkaryawan_state.dart';
import 'package:open_file/open_file.dart';

class KelolaAkunKaryawanBloc
    extends Bloc<KelolaAkunKaryawanEvent, KelolaAkunkaryawanState> {
  final FirebaseFirestore firestore;

  KelolaAkunKaryawanBloc({required this.firestore})
      : super(KelolaAkunkaryawanInitial()) {
    on<FetchKaryawanEvent>(_fetchKaryawan);
    on<FetchKaryawanEvent2>(_exportDataToExcel);
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
    emit(
        KelolaAkunkaryawanLoading()); // Menandakan proses loading sedang berlangsung

    // Menampilkan Snackbar untuk menunjukkan proses sedang berjalan
    final snackBar = SnackBar(
      content: Text("Sedang mengambil data..."),
      backgroundColor: Colors.orange,
    );
    event.scaffoldMessenger.showSnackBar(snackBar);

    // Menunggu 1.5 detik sebelum menutup Snackbar
    await Future.delayed(Duration(seconds: 1, milliseconds: 950));

    // Menutup Snackbar setelah 1.5 detik
    ScaffoldMessenger.of(event.context).hideCurrentSnackBar();

    try {
      // Ambil data karyawan dengan role 'Karyawan'
      final karyawanSnapshot = await firestore
          .collection('users')
          .where('role', isEqualTo: 'Karyawan')
          .get();

      if (karyawanSnapshot.docs.isEmpty) {
        emit(KelolaAkunkaryawanError(message: "Tidak ada data karyawan."));
        event.scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text("Tidak ada data karyawan."),
            backgroundColor: Colors.red,
          ),
        );
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

      // Membuat Excel baru
      var excel = Excel.createExcel();
      bool adaData = false;

      // Loop untuk setiap karyawan
      for (var karyawan in karyawanList) {
        String email = karyawan['email'];
        if (email.isEmpty) continue;

        // Ambil data absensi karyawan berdasarkan email
        final absensiSnapshot = await firestore
            .collection('absensi')
            .doc(email)
            .collection('absensi_harian')
            .get();

        if (absensiSnapshot.docs.isNotEmpty) {
          adaData = true;

          // Buat sheet baru dengan nama sesuai nama karyawan atau email
          Sheet sheet = excel[email];

          // Menambahkan header untuk sheet
          sheet.appendRow([
            TextCellValue('Nama Karyawan'),
            TextCellValue('Tanggal'),
          ]);

          // Loop untuk data absensi karyawan dan masukkan ke dalam sheet
          for (var doc in absensiSnapshot.docs) {
            var data = doc.data();

            // Menambahkan data absensi ke dalam sheet
            sheet.appendRow([
              TextCellValue(karyawan['name'] ?? 'Tanpa Nama'),
              TextCellValue(data['tanggal'] ?? ''),
            ]);
          }
        }
      }

      // Jika tidak ada data absensi, tampilkan error
      if (!adaData) {
        emit(KelolaAkunkaryawanError(
            message: "Tidak ada data absensi yang diekspor."));
        event.scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text("Tidak ada data absensi yang diekspor."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Simpan file Excel
      var bytes = excel.save();
      if (bytes != null) {
        Uint8List uint8ListBytes =
            Uint8List.fromList(bytes); // Konversi List<int> ke Uint8List

        // Menyimpan file Excel ke penyimpanan perangkat
        String filePath = await saveExcelToStorage(uint8ListBytes,
            "Absensi_Karyawan_${DateTime.now().millisecondsSinceEpoch}");

        // Menampilkan snackbar untuk memberi tahu bahwa ekspor berhasil
        event.scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text("Data berhasil diekspor: $filePath"),
            backgroundColor: Colors.green,
          ),
        );

        // Delay untuk menunggu Snackbar selesai, baru tampilkan dialog
        await Future.delayed(Duration(milliseconds: 500));

        // Menampilkan dialog untuk membuka file setelah ekspor berhasil
        showExportSuccessDialog(event.context, filePath);
      } else {
        emit(KelolaAkunkaryawanError(message: "Gagal menyimpan data."));
        event.scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text("Gagal menyimpan data."),
            backgroundColor: Colors.red,
          ),
        );
      }

      emit(KelolaAkunkaryawanLoaded(karyawanList: karyawanList));
    } catch (e) {
      emit(KelolaAkunkaryawanError(
          message: 'Gagal mengekspor data: ${e.toString()}'));
      event.scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text("Gagal mengekspor data: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> showExportSuccessDialog(
      BuildContext context, String filePath) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("File Berhasil Disimpan"),
          content: Text("File telah disimpan di:\n$filePath"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                OpenFile.open(
                    filePath); // Membuka file setelah menekan tombol "Buka File"
              },
              child: const Text("Buka File"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Tutup"),
            ),
          ],
        );
      },
    );
  }

// Fungsi untuk menyimpan file ke penyimpanan perangkat
  Future<String> saveExcelToStorage(Uint8List bytes, String fileName) async {
    try {
      // Menyimpan file ke direktori Download atau direktori dokumen aplikasi
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
