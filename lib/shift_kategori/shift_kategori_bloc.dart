import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'shift_kategori_event.dart';
import 'shift_kategori_state.dart';

class ShiftKategoriBloc extends Bloc<ShiftKategoriEvent, ShiftKategoriState> {
  final FirebaseFirestore firestore;

  ShiftKategoriBloc({required this.firestore}) : super(ShiftKategoriInitial()) {
    on<FetchShiftKategoriEvent>((event, emit) async {
      emit(ShiftKategoriLoading());
      try {
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

        emit(ShiftKategoriLoaded(shiftKategori: shiftKategori));
      } catch (e) {
        emit(ShiftKategoriError(
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
        emit(ShiftKategoriError(
            message: "Gagal menambah shift: ${e.toString()}"));
      }
    });

    on<HapusShiftKategoriEvent>((event, emit) async {
      try {
        // Mencari dokumen berdasarkan nama_shift pada koleksi shift_kategori
        final querySnapshot = await firestore
            .collection('shift_kategori')
            .where('nama_shift', isEqualTo: event.namaShift)
            .get();

        if (querySnapshot.docs.isEmpty) {
          emit(ShiftKategoriError(
              message:
                  "Shift dengan nama ${event.namaShift} tidak ditemukan."));
          return;
        }

        // Menghapus atau mengupdate nama_shift di koleksi shift_karyawan untuk semua dokumen email
        final shiftKaryawanSnapshot =
            await firestore.collection('shift_karyawan').get();

        for (var doc in shiftKaryawanSnapshot.docs) {
          var data = doc.data();

          // Cek apakah field nama_shift ada dan sesuai dengan nama_shift yang ingin dihapus
          if (data.containsKey('nama_shift') &&
              data['nama_shift'] == event.namaShift) {
            // Menghapus field nama_shift dari dokumen
            await doc.reference.update({'nama_shift': FieldValue.delete()});
          }
        }

        // Menghapus semua dokumen yang ditemukan berdasarkan nama_shift di shift_kategori
        for (var doc in querySnapshot.docs) {
          await doc.reference.delete();
        }

        // Setelah menghapus, memuat ulang daftar shift
        add(FetchShiftKategoriEvent());
      } catch (e) {
        emit(ShiftKategoriError(
            message: "Gagal menghapus shift: ${e.toString()}"));
      }
    });
  }
}
