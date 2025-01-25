// kelola_akunkaryawan_event.dart
import 'package:flutter/material.dart';

abstract class KelolaAkunKaryawanEvent {}

class FetchKaryawanEvent extends KelolaAkunKaryawanEvent {}

class FetchKaryawanEvent2 extends KelolaAkunKaryawanEvent {
  final ScaffoldMessengerState scaffoldMessenger;

  FetchKaryawanEvent2({required this.scaffoldMessenger});
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
