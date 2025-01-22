// kelola_akunkaryawan_event.dart
abstract class KelolaAkunKaryawanEvent {}

class FetchKaryawanEvent extends KelolaAkunKaryawanEvent {}

class DeleteKaryawanEvent extends KelolaAkunKaryawanEvent {
  final String email;
  DeleteKaryawanEvent({required this.email});
}

class SimpanShiftEvent extends KelolaAkunKaryawanEvent {
  final Map<String, bool> selectedKaryawan;
  final String selectedShift;

  SimpanShiftEvent(
      {required this.selectedKaryawan, required this.selectedShift});
}
