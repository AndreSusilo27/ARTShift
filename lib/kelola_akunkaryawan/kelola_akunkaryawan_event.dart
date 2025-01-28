import 'package:flutter/material.dart';

abstract class KelolaAkunKaryawanEvent {}

class FetchKaryawanEvent extends KelolaAkunKaryawanEvent {}

class FetchKaryawanEvent2 extends KelolaAkunKaryawanEvent {
  final ScaffoldMessengerState scaffoldMessenger;
  final BuildContext context; // Menambahkan BuildContext

  FetchKaryawanEvent2({required this.scaffoldMessenger, required this.context});
}

class DeleteKaryawanEvent extends KelolaAkunKaryawanEvent {
  final String email;
  DeleteKaryawanEvent({required this.email});
}

class SimpanShiftEvent extends KelolaAkunKaryawanEvent {
  final Map<String, bool> selectedKaryawan;
  final String selectedShift;

  SimpanShiftEvent(
      {required this.selectedKaryawan, required this.selectedShift});
}
