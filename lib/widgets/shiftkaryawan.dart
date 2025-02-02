import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ShiftKaryawanWidget extends StatefulWidget {
  final String email;
  final Function(Map<String, dynamic>) onDataFetched;

  const ShiftKaryawanWidget({
    super.key,
    required this.email,
    required this.onDataFetched,
  });

  @override
  State<ShiftKaryawanWidget> createState() => _ShiftKaryawanWidgetState();
}

class _ShiftKaryawanWidgetState extends State<ShiftKaryawanWidget> {
  Future<Map<String, dynamic>?> _fetchShiftData() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('shift_karyawan')
          .doc(widget.email)
          .get();

      if (doc.exists && doc.data() != null) {
        return doc.data() as Map<String, dynamic>;
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _fetchShiftData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || snapshot.data == null) {
          return Center(child: Text("Data tidak ditemukan."));
        }

        // Panggil callback hanya jika data tersedia
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.onDataFetched(snapshot.data!);
        });

        return SizedBox();
      },
    );
  }
}
