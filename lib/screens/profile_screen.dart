import 'package:ARTShift/widgets/custom_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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

            // Extract user data from the snapshot
            var userData =
                snapshot.data!.docs[0].data() as Map<String, dynamic>;
            String name = userData['name'] ?? 'Name not available';
            String photoUrl = userData['photoUrl'] ?? '';
            String emailFromFirestore =
                userData['email'] ?? 'Email not available';
            String role = userData['role'] ?? 'Role not available';

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('biodata') // 'biodata' collection
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

                // Extract biodata from the snapshot
                var biodata =
                    biodataSnapshot.data!.data() as Map<String, dynamic>;
                String job = biodata['job'] ?? 'Job not available';
                String gender = biodata['gender'] ?? 'Gender not available';
                String phone = biodata['phone'] ?? 'Phone not available';
                String address = biodata['address'] ?? 'Address not available';

                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Center(
                    // Center the entire content of the screen
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.center, // Center all children
                      children: [
                        // Profile Card
                        Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 5,
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              children: [
                                // Profile Picture
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
                                  "Hello, $name",
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  emailFromFirestore,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Display Role
                                Text(
                                  " $role ",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.blue[800],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        // Display Additional Biodata
                        Text(
                          "Job: $job",
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Gender: $gender",
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Phone: $phone",
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Address: $address",
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: CustomFloatingBackButton(),
    );
  }
}
