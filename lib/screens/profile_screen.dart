import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ARTShift/screens/dashboard_admin_screen.dart';
import 'package:ARTShift/screens/dashboard_karyawan_screen.dart';

class ProfileScreen extends StatelessWidget {
  final String email;

  const ProfileScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: FutureBuilder<QuerySnapshot>(
          // Ambil data pengguna dari koleksi 'users' berdasarkan email
          future: FirebaseFirestore.instance
              .collection('users')
              .where('email', isEqualTo: email)
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                  child: Text('Terjadi kesalahan: ${snapshot.error}'));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                  child: Text('Data pengguna tidak ditemukan.'));
            }

            // Ambil data dari koleksi 'users'
            var userData =
                snapshot.data!.docs[0].data() as Map<String, dynamic>;
            String name = userData['name'] ?? 'Nama tidak tersedia';
            String photoUrl = userData['photoUrl'] ?? '';
            String emailFromFirestore =
                userData['email'] ?? 'Email tidak tersedia';
            String role =
                userData['role'] ?? 'Role tidak tersedia'; // Role pengguna

            // Ambil data tambahan dari koleksi 'biodata' berdasarkan email
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('biodata') // Koleksi 'biodata'
                  .doc(email) // Menggunakan email sebagai ID dokumen
                  .get(),
              builder: (context, biodataSnapshot) {
                if (biodataSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (biodataSnapshot.hasError) {
                  return Center(
                      child:
                          Text('Terjadi kesalahan: ${biodataSnapshot.error}'));
                }

                if (!biodataSnapshot.hasData || !biodataSnapshot.data!.exists) {
                  return const Center(
                      child: Text('Data biodata tidak ditemukan.'));
                }

                // Ambil data biodata pengguna dari koleksi 'biodata'
                var biodata =
                    biodataSnapshot.data!.data() as Map<String, dynamic>;
                String job = biodata['job'] ?? 'Pekerjaan tidak tersedia';
                String gender =
                    biodata['gender'] ?? 'Jenis kelamin tidak tersedia';
                String phone = biodata['phone'] ?? 'Nomor tidak tersedia';
                String address = biodata['address'] ?? 'Alamat tidak tersedia';

                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Card untuk Menampilkan Profil Pengguna
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              // Foto Profil
                              CircleAvatar(
                                radius: 50,
                                backgroundImage: photoUrl.isNotEmpty
                                    ? NetworkImage(photoUrl)
                                    : const AssetImage(
                                            'assets/default_avatar.png')
                                        as ImageProvider,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                "Selamat datang, $name",
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                emailFromFirestore,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Menampilkan biodata tambahan dalam bentuk daftar
                      Text(
                        "Pekerjaan: $job",
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Jenis Kelamin: $gender",
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Nomor Telepon: $phone",
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Alamat: $address",
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 30),
                      // Tombol untuk navigasi ke dashboard berdasarkan role
                      ElevatedButton(
                        onPressed: () {
                          if (role == 'Admin') {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DashboardAdminScreen(
                                    name, emailFromFirestore, photoUrl),
                              ),
                            );
                          } else if (role == 'Karyawan') {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DashboardKaryawanScreen(
                                    name, emailFromFirestore, photoUrl),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Role pengguna tidak valid.'),
                              ),
                            );
                          }
                        },
                        child: const Text('Go to Dashboard'),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
