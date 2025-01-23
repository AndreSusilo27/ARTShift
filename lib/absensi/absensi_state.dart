import 'package:equatable/equatable.dart';

class AbsensiState extends Equatable {
  final String currentTime;
  final bool canAbsenMasuk;
  final bool canAbsenKeluar;
  final bool isSakitOrIzin;
  final String absensiStatus;
  final String successMessage;
  final String errorMessage;

  const AbsensiState({
    required this.currentTime,
    required this.canAbsenMasuk,
    required this.canAbsenKeluar,
    required this.isSakitOrIzin,
    required this.absensiStatus,
    required this.successMessage,
    required this.errorMessage,
  });

  factory AbsensiState.initial() {
    return AbsensiState(
      currentTime: "",
      canAbsenMasuk: true,
      canAbsenKeluar: false,
      isSakitOrIzin: false,
      absensiStatus: "",
      successMessage: "",
      errorMessage: "",
    );
  }

  AbsensiState copyWith({
    String? currentTime,
    bool? canAbsenMasuk,
    bool? canAbsenKeluar,
    bool? isSakitOrIzin,
    String? absensiStatus,
    String? successMessage,
    String? errorMessage,
  }) {
    return AbsensiState(
      currentTime: currentTime ?? this.currentTime,
      canAbsenMasuk: canAbsenMasuk ?? this.canAbsenMasuk,
      canAbsenKeluar: canAbsenKeluar ?? this.canAbsenKeluar,
      isSakitOrIzin: isSakitOrIzin ?? this.isSakitOrIzin,
      absensiStatus: absensiStatus ?? this.absensiStatus,
      successMessage: successMessage ?? this.successMessage,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object> get props => [
        currentTime,
        canAbsenMasuk,
        canAbsenKeluar,
        isSakitOrIzin,
        absensiStatus,
        successMessage,
        errorMessage,
      ];
}
