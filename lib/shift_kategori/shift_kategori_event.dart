import 'package:equatable/equatable.dart';

abstract class AkunDanShiftEvent extends Equatable {
  const AkunDanShiftEvent();

  @override
  List<Object> get props => [];
}

// Event untuk mengambil daftar shift
class FetchShiftKategoriEvent extends AkunDanShiftEvent {}

// Event untuk menambahkan kategori shift baru
class TambahShiftKategoriEvent extends AkunDanShiftEvent {
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
class HapusShiftKategoriEvent extends AkunDanShiftEvent {
  final String id;

  const HapusShiftKategoriEvent({required this.id});

  @override
  List<Object> get props => [id];
}
