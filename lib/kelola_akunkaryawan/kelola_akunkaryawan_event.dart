// kelola_akunkaryawan_event.dart
abstract class KelolaAkunkaryawanEvent {}

class FetchKaryawanEvent extends KelolaAkunkaryawanEvent {}

class DeleteKaryawanEvent extends KelolaAkunkaryawanEvent {
  final String email; // Email yang akan digunakan untuk menghapus karyawan

  DeleteKaryawanEvent({required this.email});
}
