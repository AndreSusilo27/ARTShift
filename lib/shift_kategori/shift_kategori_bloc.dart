import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'shift_kategori_event.dart';
import 'shift_kategori_state.dart';

class AkunDanShiftBloc extends Bloc<AkunDanShiftEvent, AkunDanShiftState> {
  final FirebaseFirestore firestore;

  AkunDanShiftBloc({required this.firestore}) : super(AkunDanShiftInitial()) {
    // Handler untuk event FetchShiftKategoriEvent
    on<FetchShiftKategoriEvent>((event, emit) async {
      emit(AkunDanShiftLoading());
      try {
        // Ambil data dari Firestore
        QuerySnapshot querySnapshot =
            await firestore.collection('shift_kategori').get();
        List<Map<String, dynamic>> shiftKategori =
            querySnapshot.docs.map((doc) {
          return {
            'uid': doc.id,
            'nama_shift': doc['nama_shift'],
            'jam_masuk': doc['jam_masuk'],
            'jam_keluar': doc['jam_keluar'],
            'tanggal_akhir': doc['tanggal_akhir'],
          };
        }).toList();

        emit(AkunDanShiftLoaded(shiftKategori: shiftKategori));
      } catch (e) {
        emit(AkunDanShiftError(
            message: "Gagal mengambil data shift: ${e.toString()}"));
      }
    });

    // Handler untuk event TambahShiftKategoriEvent
    on<TambahShiftKategoriEvent>((event, emit) async {
      try {
        await firestore.collection('shift_kategori').add({
          'nama_shift': event.kategoriShift,
          'jam_masuk': event.jamMasuk,
          'jam_keluar': event.jamKeluar,
          'tanggal_akhir': event.tanggalAkhir,
        });

        // Setelah menambahkan, refresh daftar shift
        add(FetchShiftKategoriEvent());
      } catch (e) {
        emit(AkunDanShiftError(
            message: "Gagal menambah shift: ${e.toString()}"));
      }
    });

    // Handler untuk event HapusShiftKategoriEvent
    on<HapusShiftKategoriEvent>((event, emit) async {
      try {
        await firestore.collection('shift_kategori').doc(event.id).delete();

        // Setelah menghapus, refresh daftar shift
        add(FetchShiftKategoriEvent());
      } catch (e) {
        emit(AkunDanShiftError(
            message: "Gagal menghapus shift: ${e.toString()}"));
      }
    });
  }
}
