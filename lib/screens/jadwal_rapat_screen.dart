import 'package:ARTShift/widgets/apptheme.dart';
import 'package:ARTShift/widgets/custom_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

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
      appBar: AppTheme.appBar(titleText: 'Kelola Jadwal Rapat'),
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
                        height: 420,
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
                              elevation: 10,
                              shadowColor: Colors.black,
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: ListTile(
                                title: Text(
                                  namaRapat,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
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
                                    Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(8),
                                        onTap: () {
                                          _showLinkDialog(context, linkMeeting);
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: const Color.fromARGB(
                                                50, 3, 168, 244),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: const Icon(
                                            Icons.description_outlined,
                                            color: Colors.blue,
                                            size: 22,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(8),
                                        onTap: () async {
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
                                                behavior:
                                                    SnackBarBehavior.floating,
                                              ),
                                            );
                                          }
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: const Color.fromARGB(
                                                50, 244, 67, 54),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                            size: 22,
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
                      behavior: SnackBarBehavior.floating,
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
                    behavior: SnackBarBehavior.floating,
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
