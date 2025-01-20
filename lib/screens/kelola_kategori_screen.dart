import 'package:ARTShift/shift_kategori/shift_kategori_bloc.dart';
import 'package:ARTShift/shift_kategori/shift_kategori_event.dart';
import 'package:ARTShift/shift_kategori/shift_kategori_state.dart';
import 'package:ARTShift/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class KelolaKategoriScreen extends StatefulWidget {
  const KelolaKategoriScreen({super.key});

  @override
  State<KelolaKategoriScreen> createState() => _KelolaKategoriScreenState();
}

class _KelolaKategoriScreenState extends State<KelolaKategoriScreen> {
  final TextEditingController kategoriShiftController = TextEditingController();
  final TextEditingController jamMasukController = TextEditingController();
  final TextEditingController jamKeluarController = TextEditingController();
  final TextEditingController tanggalAkhirController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Kategori Shift'),
        automaticallyImplyLeading: false,
      ),
      body: BlocProvider(
        create: (context) =>
            AkunDanShiftBloc(firestore: FirebaseFirestore.instance)
              ..add(FetchShiftKategoriEvent()),
        child: BlocBuilder<AkunDanShiftBloc, AkunDanShiftState>(
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Form Input Shift
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: kategoriShiftController,
                          decoration: const InputDecoration(
                              labelText: 'Kategori Shift'),
                          validator: (value) => value!.isEmpty
                              ? 'Kategori tidak boleh kosong'
                              : null,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: jamMasukController,
                          decoration: InputDecoration(
                            labelText: 'Jam Masuk',
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.access_time),
                              onPressed: () =>
                                  _selectTime(context, jamMasukController),
                            ),
                          ),
                          readOnly: true,
                          validator: (value) => value!.isEmpty
                              ? 'Jam masuk tidak boleh kosong'
                              : null,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: jamKeluarController,
                          decoration: InputDecoration(
                            labelText: 'Jam Keluar',
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.access_time),
                              onPressed: () =>
                                  _selectTime(context, jamKeluarController),
                            ),
                          ),
                          readOnly: true,
                          validator: (value) => value!.isEmpty
                              ? 'Jam keluar tidak boleh kosong'
                              : null,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: tanggalAkhirController,
                          decoration: InputDecoration(
                            labelText: 'Tanggal Akhir (dd-MM-yyyy)',
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.calendar_today),
                              onPressed: () => _selectDate(context),
                            ),
                          ),
                          readOnly: true,
                          validator: (value) => value!.isEmpty
                              ? 'Tanggal akhir tidak boleh kosong'
                              : null,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () => _submitData(context),
                          child: const Text('Tambah Shift'),
                        ),
                        const Divider(
                            thickness: 2,
                            height: 30), // Pembatas antara form & daftar shift
                      ],
                    ),
                  ),

                  // Menampilkan Data Shift
                  if (state is AkunDanShiftLoading)
                    const Center(child: CircularProgressIndicator()),

                  if (state is AkunDanShiftError)
                    Center(
                        child: Text(state.message,
                            style: const TextStyle(color: Colors.red))),

                  if (state is AkunDanShiftLoaded)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: state.shiftKategori.length,
                      itemBuilder: (context, index) {
                        final shift = state.shiftKategori[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          child: ListTile(
                            title: Text(shift['nama_shift']),
                            subtitle: Text(
                              "Jam Masuk: ${shift['jam_masuk']} - Jam Keluar: ${shift['jam_keluar']}\nTanggal Akhir: ${shift['tanggal_akhir']}",
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                context.read<AkunDanShiftBloc>().add(
                                    HapusShiftKategoriEvent(id: shift['id']));
                              },
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: CustomFloatingBackButton(),
    );
  }

  // Fungsi untuk memilih waktu
  Future<void> _selectTime(
      BuildContext context, TextEditingController controller) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        controller.text = pickedTime.format(context);
      });
    }
  }

  // Fungsi untuk memilih tanggal dengan format dd-MM-yyyy
  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (pickedDate != null) {
      String formattedDate =
          DateFormat('dd-MM-yyyy').format(pickedDate); // Format dd-MM-yyyy
      setState(() {
        tanggalAkhirController.text = formattedDate;
      });
    }
  }

  // Fungsi untuk menambah shift ke Firestore
  void _submitData(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      context.read<AkunDanShiftBloc>().add(TambahShiftKategoriEvent(
            kategoriShift: kategoriShiftController.text,
            jamMasuk: jamMasukController.text,
            jamKeluar: jamKeluarController.text,
            tanggalAkhir: tanggalAkhirController.text,
          ));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Shift berhasil ditambahkan')),
      );

      kategoriShiftController.clear();
      jamMasukController.clear();
      jamKeluarController.clear();
      tanggalAkhirController.clear();
    }
  }
}
