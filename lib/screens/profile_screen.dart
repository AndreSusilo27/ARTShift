import 'dart:ui';

import 'package:ARTShift/widgets/custom_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  final String email;

  const ProfileScreen({super.key, required this.email});

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
            title: Text('Profil'),
            automaticallyImplyLeading: false,
          ),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .where('email', isEqualTo: email)
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('User data not found.'));
            }

            var userData =
                snapshot.data!.docs[0].data() as Map<String, dynamic>;
            String name = userData['name'] ?? 'Name not available';
            String photoUrl = userData['photoUrl'] ?? '';
            String emailFromFirestore =
                userData['email'] ?? 'Email not available';
            String role = userData['role'] ?? 'Role not available';

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('biodata')
                  .doc(email)
                  .get(),
              builder: (context, biodataSnapshot) {
                if (biodataSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (biodataSnapshot.hasError) {
                  return Center(child: Text('Error: ${biodataSnapshot.error}'));
                }

                if (!biodataSnapshot.hasData || !biodataSnapshot.data!.exists) {
                  return const Center(child: Text('Biodata not found.'));
                }

                var biodata =
                    biodataSnapshot.data!.data() as Map<String, dynamic>;
                String job = biodata['job'] ?? 'Not available';
                String gender = biodata['gender'] ?? 'Not available';
                String phone = biodata['phone'] ?? 'Not available';
                String address = biodata['address'] ?? 'Not available';

                return SingleChildScrollView(
                  child: Container(
                    height: 820,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/images/bg2.png"),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Center(
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.9,
                          padding: EdgeInsets.all(20),
                          margin: EdgeInsets.symmetric(vertical: 20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(
                                0.15), // Efek transparan lebih elegan
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 15,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(
                                  sigmaX: 10, sigmaY: 10), // Efek blur
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Foto Profil berbentuk KOTAK dengan border elegan
                                  Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          12), // Sudut membulat
                                      border: Border.all(
                                          color: Colors.white,
                                          width: 3), // Border putih
                                      image: DecorationImage(
                                        image: photoUrl.isNotEmpty
                                            ? NetworkImage(photoUrl)
                                            : AssetImage(
                                                    'assets/default_avatar.png')
                                                as ImageProvider,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          Colors.white, // Warna lebih kontras
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    emailFromFirestore,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  const SizedBox(height: 10),

                                  // Role dengan gradient dan padding yang lebih rapi
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.blue.shade400,
                                          Colors.blue.shade700
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      role,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 20),
                                  Divider(thickness: 2, color: Colors.white54),

                                  // Informasi Pribadi dengan icon untuk tampilan lebih modern
                                  const Text(
                                    "Informasi Pribadi",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  _buildInfoRow(Icons.work, "Pekerjaan", job),
                                  _buildInfoRow(
                                      Icons.person, "Jenis Kelamin", gender),
                                  _buildInfoRow(
                                      Icons.phone, "No. Telepon", phone),
                                  _buildInfoRow(Icons.home, "Alamat", address),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: const CustomFloatingBackButton(),
    );
  }

// Fungsi untuk membuat row dengan icon
  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: Color.fromARGB(220, 255, 255, 255), size: 20),
          const SizedBox(width: 10),
          Text(
            "$title: ",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                  fontSize: 16, color: Color.fromARGB(220, 255, 255, 255)),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
