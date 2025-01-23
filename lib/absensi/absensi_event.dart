import 'package:equatable/equatable.dart';

abstract class AbsensiEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class CheckTimeEvent extends AbsensiEvent {}

class UpdateTimeEvent extends AbsensiEvent {}

class CheckAbsensiEvent extends AbsensiEvent {
  final String email;

  CheckAbsensiEvent({required this.email});

  @override
  List<Object> get props => [email];
}

class OnSubmitAbsensi extends AbsensiEvent {
  final String email;
  final String name;
  final String status;

  OnSubmitAbsensi(
      {required this.email, required this.name, required this.status});

  @override
  List<Object> get props => [email, name, status];
}
