import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'laporan_event.dart';
import 'laporan_state.dart';

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

        final laporanData = snapshot.docs.map((doc) => doc.data()).toList();
        emit(LaporanLoaded(laporanData));
      } catch (e) {
        emit(LaporanError("Error fetching data: ${e.toString()}"));
      }
    });
  }
}
