import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'laporan_harian_event.dart';
import 'laporan_harian_state.dart';

class LaporanBloc extends Bloc<LaporanEvent, LaporanState> {
  final FirebaseFirestore firestore;

  LaporanBloc({required this.firestore}) : super(LaporanInitial()) {
    // Menangani event FetchLaporanEvent
    on<FetchLaporanEvent>((event, emit) async {
      emit(LaporanLoading()); // Menampilkan loading saat fetch data
      try {
        QuerySnapshot<Map<String, dynamic>> snapshot;

        // Jika email filter kosong, ambil semua data dari koleksi absensi
        if (event.emailFilter.isEmpty) {
          snapshot = await firestore.collection('absensi').get();
        } else {
          // Jika ada filter email, ambil data berdasarkan email
          snapshot = await firestore
              .collection('absensi')
              .where('email', isEqualTo: event.emailFilter)
              .get();
        }

        List<Map<String, dynamic>> laporanData = [];

        // Mengambil data dari subkoleksi 'absensi_harian' untuk setiap dokumen email
        for (var doc in snapshot.docs) {
          final email =
              doc.id; // Menggunakan ID dokumen (email) sebagai identifikasi
          final absensiHarianSnapshot = await firestore
              .collection('absensi')
              .doc(email)
              .collection('absensi_harian')
              .get();

          // Mengambil data absensi untuk setiap tanggal dalam subkoleksi
          for (var absensiDoc in absensiHarianSnapshot.docs) {
            final data = absensiDoc.data();
            laporanData.add({
              'email': email,
              'tanggal': data['tanggal'],
              'hadir': data['hadir'],
              'keluar': data['keluar'],
              'sakit': data['sakit'],
              'izin': data['izin'],
            });
          }
        }

        emit(LaporanLoaded(laporanData)); // Kirimkan data laporan ke state
      } catch (e) {
        emit(LaporanError("Error fetching data: ${e.toString()}"));
      }
    });
  }
}
