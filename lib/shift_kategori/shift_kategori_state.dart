import 'package:equatable/equatable.dart';

abstract class ShiftKategoriState extends Equatable {
  const ShiftKategoriState();

  @override
  List<Object> get props => [];
}

// State awal ketika aplikasi dibuka
class ShiftKategoriInitial extends ShiftKategoriState {}

// State loading saat sedang mengambil data
class ShiftKategoriLoading extends ShiftKategoriState {}

// State ketika data shift berhasil diambil
class ShiftKategoriLoaded extends ShiftKategoriState {
  final List<Map<String, dynamic>> shiftKategori;

  const ShiftKategoriLoaded({required this.shiftKategori});

  @override
  List<Object> get props => [shiftKategori];

  get shiftList => shiftKategori;
}

// State ketika data shift berhasil diambil (ShiftListLoaded)
class ShiftListLoaded extends ShiftKategoriState {
  final List<Map<String, dynamic>> shiftList;

  const ShiftListLoaded({required this.shiftList});

  @override
  List<Object> get props => [shiftList];
}

// State error jika terjadi kesalahan
class ShiftKategoriError extends ShiftKategoriState {
  final String message;

  const ShiftKategoriError({required this.message});

  @override
  List<Object> get props => [message];
}
