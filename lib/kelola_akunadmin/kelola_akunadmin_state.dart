// kelola_akunAdmin_state.dart
abstract class KelolaAkunAdminState {}

class KelolaAkunAdminInitial extends KelolaAkunAdminState {}

class KelolaAkunAdminLoading extends KelolaAkunAdminState {}

class KelolaAkunAdminError extends KelolaAkunAdminState {
  final String message;

  KelolaAkunAdminError({required this.message});
}

class KelolaAkunAdminLoaded extends KelolaAkunAdminState {
  final List<Map<String, dynamic>> adminList;

  KelolaAkunAdminLoaded({required this.adminList});
}
