import 'package:equatable/equatable.dart';

abstract class LaporanState extends Equatable {
  @override
  List<Object> get props => [];
}

class LaporanInitial extends LaporanState {}

class LaporanLoading extends LaporanState {}

class LaporanLoaded extends LaporanState {
  final List<Map<String, dynamic>> laporanData;

  LaporanLoaded(this.laporanData);

  @override
  List<Object> get props => [laporanData];
}

class LaporanError extends LaporanState {
  final String message;

  LaporanError(this.message);

  @override
  List<Object> get props => [message];
}
