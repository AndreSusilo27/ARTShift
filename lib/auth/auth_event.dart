import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// Event untuk login menggunakan Google
class SignInWithGoogle extends AuthEvent {}

// Event untuk logout
class SignOut extends AuthEvent {}

// Event untuk memperbarui role pengguna setelah memilih role
class UpdateUserRole extends AuthEvent {
  final String role;
  UpdateUserRole(this.role);

  @override
  List<Object?> get props => [role];
}
