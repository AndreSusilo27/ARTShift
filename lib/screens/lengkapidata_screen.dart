import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LengkapiDataScreen extends StatefulWidget {
  const LengkapiDataScreen({super.key});

  @override
  State<LengkapiDataScreen> createState() => _LengkapiDataScreenState();
}

class _LengkapiDataScreenState extends State<LengkapiDataScreen> {
  final _formKey = GlobalKey<FormState>();
  final _jobController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  String _selectedGender = 'Laki - Laki';

  // Fungsi untuk menyimpan data ke Firestore
  void _saveData() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection('users').add({
          'job': _jobController.text,
          'phone': _phoneController.text,
          'gender': _selectedGender,
          'address': _addressController.text,
          'created_at': FieldValue.serverTimestamp(),
        });

        // Menampilkan snackbar jika berhasil
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data berhasil disimpan')),
        );

        // Kosongkan input setelah submit
        _jobController.clear();
        _phoneController.clear();
        _addressController.clear();
        setState(() {
          _selectedGender = 'Laki - Laki';
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lengkapi Data',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurpleAccent,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Text(
                      'Harap lengkapi data informasi yang dibutuhkan.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
              Text("Bidang Pekerjaan"),
              TextFormField(
                controller: _jobController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Masukkan bidang pekerjaan',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Bidang pekerjaan tidak boleh kosong';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              Text("No. Telepon"),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '+62 - 021 - 1234 - 5678',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nomor telepon tidak boleh kosong';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              Text("Jenis Kelamin"),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedGender = newValue!;
                  });
                },
                items: ['Laki - Laki', 'Perempuan']
                    .map((gender) => DropdownMenuItem(
                          value: gender,
                          child: Text(gender),
                        ))
                    .toList(),
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              Text("Alamat"),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Masukkan alamat',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Alamat tidak boleh kosong';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    padding: EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: Text(
                    'Simpan Data',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
