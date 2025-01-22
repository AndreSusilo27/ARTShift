import 'package:equatable/equatable.dart';

abstract class ShiftKategoriEvent extends Equatable {
  const ShiftKategoriEvent();

  @override
  List<Object> get props => [];
}

// Event untuk mengambil daftar shift
class FetchShiftKategoriEvent extends ShiftKategoriEvent {}

// Event untuk menambahkan kategori shift baru
class TambahShiftKategoriEvent extends ShiftKategoriEvent {
  final String kategoriShift;
  final String jamMasuk;
  final String jamKeluar;
  final String tanggalAkhir;

  const TambahShiftKategoriEvent({
    required this.kategoriShift,
    required this.jamMasuk,
    required this.jamKeluar,
    required this.tanggalAkhir,
  });

  @override
  List<Object> get props => [kategoriShift, jamMasuk, jamKeluar, tanggalAkhir];
}

// Event untuk menghapus kategori shift berdasarkan ID
class HapusShiftKategoriEvent extends ShiftKategoriEvent {
  final String namaShift;

  const HapusShiftKategoriEvent({required this.namaShift});
}
