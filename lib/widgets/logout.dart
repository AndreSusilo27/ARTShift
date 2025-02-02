import 'package:ARTShift/auth/auth_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ARTShift/auth/auth_bloc.dart';

void showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        titlePadding: const EdgeInsets.all(20),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        title: const Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.red,
              size: 28,
            ),
            SizedBox(width: 10),
            Text(
              "Konfirmasi Logout",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: const Text(
          "Apakah Anda yakin ingin keluar?",
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.grey),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                  ),
                  child: const Text(
                    "Batal",
                    style: TextStyle(
                        color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    BlocProvider.of<AuthBloc>(context).add(SignOut());

                    Navigator.of(dialogContext).pop();
                    Navigator.of(context).pushReplacementNamed('/splash');
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.grey),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                  ),
                  child: const Text(
                    "Ya, Keluar",
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    },
  );
}
