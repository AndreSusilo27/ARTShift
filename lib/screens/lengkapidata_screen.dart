import 'package:ARTShift/widgets/apptheme.dart';
import 'package:ARTShift/widgets/custom_button.dart';
import 'package:ARTShift/widgets/custom_textformfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    String userEmail = user?.email ?? '';

    if (userEmail.isNotEmpty) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('biodata')
            .doc(userEmail)
            .get();

        if (userDoc.exists) {
          setState(() {
            _jobController.text = userDoc['job'] ?? '';
            _phoneController.text = userDoc['phone'] ?? '';
            _selectedGender = userDoc['gender'] ?? 'Laki - Laki';
            _addressController.text = userDoc['address'] ?? '';
          });
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data: $e')),
        );
      }
    }
  }

  void _saveData() async {
    if (_formKey.currentState!.validate()) {
      try {
        User? user = FirebaseAuth.instance.currentUser;
        String userEmail = user?.email ?? '';

        if (userEmail.isNotEmpty) {
          await FirebaseFirestore.instance
              .collection('biodata')
              .doc(userEmail)
              .set({
            'email': userEmail,
            'job': _jobController.text,
            'phone': _phoneController.text,
            'gender': _selectedGender,
            'address': _addressController.text,
            'created_at': FieldValue.serverTimestamp(),
            'updated_at': FieldValue.serverTimestamp(),
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Data berhasil disimpan',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );

          // Melakukan pop untuk kembali ke halaman sebelumnya
          Future.delayed(Duration(seconds: 1), () {
            Navigator.pop(context);
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Data gagal disimpan',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal menyimpan data: $e',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTheme.appBar(titleText: 'Lengkapi Data'),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Center(
                child: Text(
                  'Harap lengkapi data informasi yang dibutuhkan.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
              SizedBox(height: 20),
              CustomTextFormField(
                labelText: "Bidang Pekerjaan",
                controller: _jobController,
                hintText: 'Masukkan bidang pekerjaan',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Bidang pekerjaan tidak boleh kosong';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              CustomTextFormField(
                labelText: "No.Telepon",
                controller: _phoneController,
                hintText: '08xxxxxxxxxx',
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nomor telepon tidak boleh kosong';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              Text("Jenis Kelamin", style: TextStyle(fontSize: 16)),
              SizedBox(height: 5),
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
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
              ),
              SizedBox(height: 10),
              CustomTextFormField(
                labelText: "Alamat",
                controller: _addressController,
                hintText: 'Masukkan alamat',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Alamat tidak boleh kosong';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              CustomButton(
                text: 'Simpan Data',
                onPressed: _saveData,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: CustomFloatingBackButton(),
    );
  }
}
