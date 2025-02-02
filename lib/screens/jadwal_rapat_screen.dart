import 'package:ARTShift/widgets/custom_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart'; // Untuk copyToClipboard

class JadwalRapatScreen extends StatefulWidget {
  const JadwalRapatScreen({super.key});

  @override
  State<JadwalRapatScreen> createState() => _JadwalRapatScreenState();
}

class _JadwalRapatScreenState extends State<JadwalRapatScreen> {
  final TextEditingController namaRapatController = TextEditingController();
  final TextEditingController waktuMulaiController = TextEditingController();
  final TextEditingController waktuSelesaiController = TextEditingController();
  final TextEditingController tanggalRapatController = TextEditingController();
  final TextEditingController linkMeetingController = TextEditingController();
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
            title: const Text('Kelola Jadwal Rapat'),
            automaticallyImplyLeading: false,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                'Buat atau Hapus jadwal rapat yang diperlukan.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: namaRapatController,
                      decoration: const InputDecoration(
                          labelText: 'Nama Rapat',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white),
                      validator: (value) => value!.isEmpty
                          ? 'Nama rapat tidak boleh kosong'
                          : null,
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: waktuMulaiController,
                      decoration: InputDecoration(
                        labelText: 'Waktu Mulai',
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.access_time),
                          onPressed: () =>
                              _selectTime(context, waktuMulaiController),
                        ),
                      ),
                      readOnly: true,
                      validator: (value) => value!.isEmpty
                          ? 'Waktu mulai tidak boleh kosong'
                          : null,
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: waktuSelesaiController,
                      decoration: InputDecoration(
                        labelText: 'Waktu Selesai',
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.access_time),
                          onPressed: () =>
                              _selectTime(context, waktuSelesaiController),
                        ),
                      ),
                      readOnly: true,
                      validator: (value) => value!.isEmpty
                          ? 'Waktu selesai tidak boleh kosong'
                          : null,
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: tanggalRapatController,
                      decoration: InputDecoration(
                        labelText: 'Tanggal Rapat (dd-MM-yyyy)',
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
                          ? 'Tanggal rapat tidak boleh kosong'
                          : null,
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: linkMeetingController,
                      decoration: const InputDecoration(
                        labelText: 'Link Meeting (Zoom/GMeet)',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) => value!.isEmpty
                          ? 'Link meeting tidak boleh kosong'
                          : null,
                    ),
                    const SizedBox(height: 25),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => _submitData(context),
                      child: const Text(
                        'Tambah Jadwal Rapat',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                    const Divider(thickness: 2, height: 30),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Menampilkan Daftar Jadwal Rapat
              SizedBox(
                height: 420,
                child: Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('jadwal_meeting')
                        .snapshots(),
                    builder: (ctx, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return const Center(child: Text('Error loading data'));
                      }
                      final jadwalList = snapshot.data!.docs;

                      return Container(
                        height: 420, // Ukuran tetap 420 piksel
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 15),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.blue[800]),
                        child: ListView.builder(
                          itemCount: jadwalList.length,
                          itemBuilder: (ctx, index) {
                            final jadwal = jadwalList[index].data()
                                as Map<String, dynamic>;
                            // Mengambil data dari Firestore dan menangani field tidak ada
                            String namaRapat = jadwal['nama_rapat'] ??
                                'Nama Rapat Tidak Tersedia';
                            String waktuMulai = jadwal['waktu_mulai'] ??
                                'Waktu Mulai Tidak Tersedia';
                            String waktuSelesai = jadwal['waktu_selesai'] ??
                                'Waktu Selesai Tidak Tersedia';
                            String tanggalRapat = jadwal['tanggal_rapat'] ??
                                'Tanggal Tidak Tersedia';
                            String linkMeeting = jadwal['link_meeting'] ??
                                'Link Meeting Tidak Tersedia';

                            return Card(
                              elevation: 10, // Efek bayangan untuk tampilan 3D
                              shadowColor: Colors.black, // Warna bayangan
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    15), // Sudut melengkung
                              ),
                              child: ListTile(
                                title: Text(namaRapat),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Waktu: $waktuMulai - $waktuSelesai'),
                                    Text('Tanggal: $tanggalRapat'),
                                    Text('Link Meeting: $linkMeeting'),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Ikon kalender dengan desain InkWell
                                    Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(
                                            8), // Efek klik membulat
                                        onTap: () {
                                          _showLinkDialog(context, linkMeeting);
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(
                                              6), // Spasi agar tidak terlalu rapat
                                          decoration: BoxDecoration(
                                            color: Colors.blue.withOpacity(
                                                0.1), // Warna biru transparan untuk kalender
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: const Icon(
                                            Icons.description_outlined,
                                            color: Colors.blue,
                                            size:
                                                22, // Ukuran lebih proporsional
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Ikon hapus dengan desain InkWell
                                    Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(
                                            8), // Efek klik membulat
                                        onTap: () async {
                                          // Konfirmasi sebelum menghapus jadwal
                                          bool? confirmDelete =
                                              await showDialog<bool>(
                                            context: context,
                                            builder:
                                                (BuildContext dialogContext) {
                                              return AlertDialog(
                                                title: const Row(
                                                  children: [
                                                    Icon(
                                                      Icons
                                                          .warning_amber_rounded,
                                                      color: Colors.red,
                                                      size: 28,
                                                    ),
                                                    SizedBox(width: 10),
                                                    Text(
                                                      "Konfirmasi Hapus Rapat",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 18),
                                                    ),
                                                  ],
                                                ),
                                                content: const Text(
                                                    "Apakah Anda yakin ingin menghapus jadwal rapat ini?"),
                                                actions: <Widget>[
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(
                                                              dialogContext)
                                                          .pop(false);
                                                    },
                                                    child: const Text("Batal",
                                                        style: TextStyle(
                                                            color:
                                                                Colors.green)),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(
                                                              dialogContext)
                                                          .pop(true);
                                                    },
                                                    child: const Text("Hapus",
                                                        style: TextStyle(
                                                            color: Colors.red)),
                                                  ),
                                                ],
                                              );
                                            },
                                          );

                                          if (confirmDelete == true) {
                                            // Menghapus jadwal dari Firestore berdasarkan ID
                                            FirebaseFirestore.instance
                                                .collection('jadwal_meeting')
                                                .doc(jadwalList[index].id)
                                                .delete();

                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'Jadwal rapat berhasil dihapus'),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(
                                              6), // Spasi agar tidak terlalu rapat
                                          decoration: BoxDecoration(
                                            color: Colors.red.withOpacity(
                                                0.1), // Warna merah transparan untuk hapus
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                            size:
                                                22, // Ukuran lebih proporsional
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
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
      String formattedDate = DateFormat('dd-MM-yyyy').format(pickedDate);
      setState(() {
        tanggalRapatController.text = formattedDate;
      });
    }
  }

  void _submitData(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Row(
              children: [
                Icon(
                  Icons.camera_indoor_outlined,
                  color: Colors.blue,
                  size: 28,
                ),
                SizedBox(width: 10),
                Text(
                  "Konfirmasi Tambah Rapat",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            content: const Text(
                "Apakah Anda yakin ingin menambahkan jadwal rapat ini?"),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                child: const Text("Batal", style: TextStyle(color: Colors.red)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();

                  // Tambahkan data ke Firestore
                  FirebaseFirestore.instance.collection('jadwal_meeting').add({
                    'nama_rapat': namaRapatController.text,
                    'waktu_mulai': waktuMulaiController.text,
                    'waktu_selesai': waktuSelesaiController.text,
                    'tanggal_rapat': tanggalRapatController.text,
                    'link_meeting': linkMeetingController.text,
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Jadwal rapat berhasil ditambahkan'),
                      backgroundColor: Colors.green,
                    ),
                  );

                  // Bersihkan input
                  namaRapatController.clear();
                  waktuMulaiController.clear();
                  waktuSelesaiController.clear();
                  tanggalRapatController.clear();
                  linkMeetingController.clear();
                },
                child:
                    const Text("Tambah", style: TextStyle(color: Colors.green)),
              ),
            ],
          );
        },
      );
    }
  }

  // Fungsi untuk menampilkan dialog dengan link meeting
  void _showLinkDialog(BuildContext context, String link) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(
              Icons.video_camera_front_outlined,
              color: Colors.blue,
              size: 28,
            ),
            SizedBox(width: 10),
            Text(
              "Salin Link Meeting ",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SelectableText(link),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: link));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Link berhasil disalin!',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.of(ctx).pop();
              },
              child: const Text('Salin Link',
                  style: TextStyle(color: Colors.blue)),
            ),
          ],
        ),
      ),
    );
  }
}
