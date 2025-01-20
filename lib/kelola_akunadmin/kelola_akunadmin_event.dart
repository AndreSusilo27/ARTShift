// kelola_akunAdmin_event.dart
abstract class KelolaAkunAdminEvent {}

class FetchAdminEvent extends KelolaAkunAdminEvent {}

class DeleteAdminEvent extends KelolaAkunAdminEvent {
  final String email; // Email yang akan digunakan untuk menghapus Admin

  DeleteAdminEvent({required this.email});
}
