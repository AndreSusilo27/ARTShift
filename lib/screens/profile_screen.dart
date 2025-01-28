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

            // Extract user data
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

                // Extract biodata
                var biodata =
                    biodataSnapshot.data!.data() as Map<String, dynamic>;
                String job = biodata['job'] ?? 'Not available';
                String gender = biodata['gender'] ?? 'Not available';
                String phone = biodata['phone'] ?? 'Not available';
                String address = biodata['address'] ?? 'Not available';

                return SingleChildScrollView(
                  child: Container(
                    height: 825,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                            "assets/images/bg2.png"), // Background image
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Profile Card with Glass Effect
                          Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 8,
                            shadowColor: Colors.blueAccent.withOpacity(0.3),
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                children: [
                                  // Profile Picture
                                  CircleAvatar(
                                    radius: 55,
                                    backgroundColor: Colors.blueAccent.shade100,
                                    backgroundImage: photoUrl.isNotEmpty
                                        ? NetworkImage(photoUrl)
                                        : const AssetImage(
                                                'assets/default_avatar.png')
                                            as ImageProvider,
                                  ),
                                  const SizedBox(height: 15),
                                  // Name
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  // Email
                                  Text(
                                    emailFromFirestore,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  // Role
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade100,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      role,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 25),

                          // Additional Biodata
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blueAccent.withOpacity(0.2),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildInfoRow("Pekerjaan", job),
                                _buildInfoRow("Jenis Kelamin", gender),
                                _buildInfoRow("No.Telepon", phone),
                                _buildInfoRow("Alamat", address),
                              ],
                            ),
                          ),
                          const SizedBox(height: 25),
                        ],
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

  // Helper method for building user information row
  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            "$title: ",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
