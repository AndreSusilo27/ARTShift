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
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 2,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: AppBar(
            title: Text('Kelola Kategori Shift'),
            automaticallyImplyLeading: false,
          ),
        ),
      ),
      body: BlocProvider(
        create: (context) =>
            ShiftKategoriBloc(firestore: FirebaseFirestore.instance)
              ..add(FetchShiftKategoriEvent()),
        child: BlocBuilder<ShiftKategoriBloc, ShiftKategoriState>(
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    'Buat atau Hapus shift yang tidak diperlukan.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  // Form Input Shift
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: kategoriShiftController,
                          decoration: const InputDecoration(
                              labelText: 'Kategori Shift',
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.white),
                          validator: (value) => value!.isEmpty
                              ? 'Kategori tidak boleh kosong'
                              : null,
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: jamMasukController,
                          decoration: InputDecoration(
                            labelText: 'Jam Masuk',
                            border: const OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
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
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: jamKeluarController,
                          decoration: InputDecoration(
                            labelText: 'Jam Keluar',
                            border: const OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
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
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: tanggalAkhirController,
                          decoration: InputDecoration(
                            labelText: 'Tanggal Akhir (dd-MM-yyyy)',
                            border: const OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
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
                        const SizedBox(height: 25),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            backgroundColor: Colors.blueAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => _submitData(context),
                          child: const Text(
                            'Tambah Shift',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                        const Divider(
                            thickness: 2,
                            height: 30), // Pembatas antara form & daftar shift
                      ],
                    ),
                  ),

                  // Menampilkan Data Shift
                  if (state is ShiftKategoriLoading)
                    const Center(child: CircularProgressIndicator()),

                  if (state is ShiftKategoriError)
                    Center(
                        child: Text(state.message,
                            style: const TextStyle(color: Colors.red))),

                  if (state is ShiftKategoriLoaded)
                    // Menampilkan daftar shift dalam ListView
                    Expanded(
                      child: Container(
                        height: 420, // Menetapkan tinggi Container menjadi 420
                        padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 8), // Padding untuk estetika
                        decoration: BoxDecoration(
                          color: Colors
                              .blueGrey, // Menetapkan warna latar belakang menjadi blueGrey
                          borderRadius: BorderRadius.circular(
                              12), // Sudut melengkung untuk estetika
                        ),
                        child: ListView.builder(
                          itemCount: state.shiftKategori.length,
                          itemBuilder: (context, index) {
                            final shift = state.shiftKategori[index];
                            return Card(
                              elevation: 5,
                              margin: const EdgeInsets.symmetric(
                                  vertical: 4,
                                  horizontal:
                                      4), // Mengurangi margin antar card
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 12), // Mengurangi padding
                                title: Text(
                                  shift['nama_shift'],
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                subtitle: Text(
                                  "${shift['jam_masuk']} - ${shift['jam_keluar']}\nTanggal Akhir: ${shift['tanggal_akhir']}",
                                  style: const TextStyle(fontSize: 14),
                                ),
                                trailing: Padding(
                                  padding: const EdgeInsets.only(
                                      right: 8), // Padding agar lebih seimbang
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(8),
                                    onTap: () {
                                      // Menampilkan dialog konfirmasi
                                      showDialog(
                                        context:
                                            context, // Gunakan context dari parent
                                        builder: (BuildContext dialogContext) {
                                          // Ubah nama context agar tidak bingung
                                          return AlertDialog(
                                            title: const Text(
                                                'Konfirmasi Hapus Shift'),
                                            content: Text(
                                                'Apakah Anda yakin ingin menghapus shift "${shift['nama_shift']}"?'),
                                            actions: <Widget>[
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(dialogContext,
                                                          rootNavigator: true)
                                                      .pop();
                                                },
                                                child: const Text('Batal'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  final bloc = BlocProvider.of<
                                                          ShiftKategoriBloc>(
                                                      context); // Gunakan context dari widget induk
                                                  bloc.add(
                                                      HapusShiftKategoriEvent(
                                                          namaShift: shift[
                                                              'nama_shift']));
                                                  Navigator.of(dialogContext,
                                                          rootNavigator: true)
                                                      .pop();
                                                },
                                                child: const Text('Hapus'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                        size: 22,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
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
      context.read<ShiftKategoriBloc>().add(TambahShiftKategoriEvent(
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
