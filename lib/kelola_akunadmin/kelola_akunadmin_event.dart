// kelola_akunAdmin_event.dart
abstract class KelolaAkunAdminEvent {}

class FetchAdminEvent extends KelolaAkunAdminEvent {}

class DeleteAdminEvent extends KelolaAkunAdminEvent {
  final String email;

  DeleteAdminEvent({required this.email});
}
