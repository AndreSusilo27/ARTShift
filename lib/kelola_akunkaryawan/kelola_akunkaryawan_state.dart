// kelola_akunkaryawan_state.dart
abstract class KelolaShiftKaryawanState {}

class KelolaShiftKaryawanInitial extends KelolaShiftKaryawanState {}

class KelolaShiftKaryawanLoading extends KelolaShiftKaryawanState {}

class KelolaShiftKaryawanError extends KelolaShiftKaryawanState {
  final String message;

  KelolaShiftKaryawanError({required this.message});
}

class KelolaShiftKaryawanLoaded extends KelolaShiftKaryawanState {
  final List<Map<String, dynamic>> karyawanList;

  KelolaShiftKaryawanLoaded({required this.karyawanList});
}
