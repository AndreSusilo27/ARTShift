import 'package:ARTShift/widgets/logout.dart';
import 'package:flutter/material.dart';

class DashboardKaryawanScreen extends StatelessWidget {
  final String email;
  final String name;
  final String photoUrl;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  DashboardKaryawanScreen(this.name, this.email, this.photoUrl, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => _scaffoldKey.currentState!.openDrawer(),
          icon: Image.asset(
            'assets/icons/drawer_icon.png',
            height: 24,
            width: 24,
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.only(top: 8.5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/icons/ARTShift_icon.png',
                height: 26,
              ),
              const SizedBox(width: 5),
              const Text(
                "ARTShift",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: Color.fromARGB(255, 128, 82, 227),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 210, 210, 210),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              accountEmail: Text(email),
              currentAccountPicture: Stack(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundImage: NetworkImage(photoUrl),
                  ),
                  Positioned(
                    bottom: 3,
                    right: 8,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.2),
                      ),
                    ),
                  ),
                ],
              ),
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
            ),
            _buildDrawerItem(Icons.home, "Dashboard", () {}),
            _buildDrawerItem(Icons.settings, "Pengaturan", () {}),
            _buildDrawerItem(Icons.logout, "Keluar", () {
              showLogoutDialog(context);
            }),
          ],
        ),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: NetworkImage(photoUrl),
                          ),
                          Positioned(
                            bottom: 4,
                            right: 8,
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 2),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Selamat datang, $name",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        email,
                        style:
                            const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.analytics),
                label: const Text("Lihat Laporan"),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Widget untuk membuat item di Drawer lebih rapi
  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, size: 24),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      onTap: onTap,
    );
  }
}
