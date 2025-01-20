import 'package:equatable/equatable.dart';

abstract class AkunDanShiftState extends Equatable {
  const AkunDanShiftState();

  @override
  List<Object> get props => [];
}

// State awal ketika aplikasi dibuka
class AkunDanShiftInitial extends AkunDanShiftState {}

// State loading saat sedang mengambil data
class AkunDanShiftLoading extends AkunDanShiftState {}

// State ketika data shift berhasil diambil
class AkunDanShiftLoaded extends AkunDanShiftState {
  final List<Map<String, dynamic>> shiftKategori;

  const AkunDanShiftLoaded({required this.shiftKategori});

  @override
  List<Object> get props => [shiftKategori];
}

// State error jika terjadi kesalahan
class AkunDanShiftError extends AkunDanShiftState {
  final String message;

  const AkunDanShiftError({required this.message});

  @override
  List<Object> get props => [message];
}
