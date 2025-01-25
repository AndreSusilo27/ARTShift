import 'package:equatable/equatable.dart';

abstract class LaporanEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class FetchLaporanEvent extends LaporanEvent {
  final String emailFilter;

  FetchLaporanEvent(this.emailFilter);

  @override
  List<Object> get props => [emailFilter];
}
