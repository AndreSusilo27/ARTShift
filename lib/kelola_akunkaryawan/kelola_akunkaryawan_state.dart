// kelola_akunkaryawan_state.dart
abstract class KelolaAkunkaryawanState {}

class KelolaAkunkaryawanInitial extends KelolaAkunkaryawanState {}

class KelolaAkunkaryawanLoading extends KelolaAkunkaryawanState {}

class KelolaAkunkaryawanError extends KelolaAkunkaryawanState {
  final String message;

  KelolaAkunkaryawanError({required this.message});
}

class KelolaAkunkaryawanLoaded extends KelolaAkunkaryawanState {
  final List<Map<String, dynamic>> karyawanList;

  KelolaAkunkaryawanLoaded({required this.karyawanList});
}

class KelolaAkunkaryawanSuccess extends KelolaAkunkaryawanState {
  final String message;
  KelolaAkunkaryawanSuccess({required this.message});
}
