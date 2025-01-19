import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

// State awal (belum login)
class AuthInitial extends AuthState {}

// State loading (proses login)
class AuthLoading extends AuthState {}

// State saat berhasil login
class Authenticated extends AuthState {
  final String uid;
  final String name;
  final String email;
  final String photoUrl;
  final String role;

  Authenticated({
    required this.uid,
    required this.name,
    required this.email,
    required this.photoUrl,
    required this.role,
  });

  @override
  List<Object?> get props => [uid, name, email, photoUrl, role];
}

// State saat logout
class Unauthenticated extends AuthState {}

// State jika terjadi error
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
