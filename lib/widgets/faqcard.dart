import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FAQListWidget extends StatefulWidget {
  const FAQListWidget({super.key});

  @override
  State<FAQListWidget> createState() => _FAQListWidgetState();
}

class _FAQListWidgetState extends State<FAQListWidget> {
  String _selectedStatus = "Semua";
  String _searchQuery = "";

  final List<String> statusOptions = [
    "Semua",
    "Khusus",
    "Penting",
    "Teknis",
    "Umum"
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Daftar Pertanyaan FAQ",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            "Berikut adalah daftar pertanyaan dan jawaban yang sering ditanyakan.",
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 12),

          /// Search Bar & Dropdown Filter
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Cari pertanyaan...",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                ),
              ),
              const SizedBox(width: 10),
              DropdownButton<String>(
                value: _selectedStatus,
                items: statusOptions.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedStatus = newValue!;
                  });
                },
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(thickness: 1.5),
          const SizedBox(height: 8),

          /// List FAQ with Filters
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('faq').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator.adaptive());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "Tidak ada FAQ yang tersedia",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  );
                }

                /// Filter berdasarkan search query dan status yang dipilih
                var faqList = snapshot.data!.docs.where((doc) {
                  String question =
                      doc['question']?.toString().toLowerCase() ?? "";
                  String status = doc['status'] ?? "Umum";

                  bool matchesSearch = question.contains(_searchQuery);
                  bool matchesStatus =
                      _selectedStatus == "Semua" || status == _selectedStatus;

                  return matchesSearch && matchesStatus;
                }).toList();

                if (faqList.isEmpty) {
                  return const Center(
                    child: Text("Tidak ada hasil yang cocok dengan filter."),
                  );
                }

                return ListView.builder(
                  itemCount: faqList.length,
                  itemBuilder: (context, index) {
                    var faqData = faqList[index];
                    String question =
                        faqData['question'] ?? 'Pertanyaan tidak tersedia';
                    String answer =
                        faqData['answer'] ?? 'Jawaban tidak tersedia';
                    int count = faqData['count'] ?? 0;
                    String status = faqData['status'] ?? 'Umum';
                    bool requiresQuestion =
                        faqData['requires_question'] ?? false;
                    String docId = faqData.id;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                question,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                answer,
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.black87),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Kategori: $status',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.blueAccent,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        'Ditanyakan: $count kali',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      _actionButton(
                                        icon: Icons.edit_outlined,
                                        color: Colors.blue,
                                        onTap: () {
                                          showEditDialog(context, docId, answer,
                                              requiresQuestion, status);
                                        },
                                      ),
                                      const SizedBox(width: 6),
                                      _actionButton(
                                        icon: Icons.delete,
                                        color: Colors.red,
                                        onTap: () {
                                          showDeleteDialog(context, docId);
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
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
        ],
      ),
    );
  }
}

/// Button Action Widget
Widget _actionButton(
    {required IconData icon,
    required Color color,
    required VoidCallback onTap}) {
  return InkWell(
    borderRadius: BorderRadius.circular(10),
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color, size: 24),
    ),
  );
}

/// Function to Show Delete Dialog
void showDeleteDialog(BuildContext context, String docId) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Hapus FAQ"),
      content: const Text("Apakah Anda yakin ingin menghapus FAQ ini?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Batal"),
        ),
        TextButton(
          onPressed: () {
            showDeleteDialog(context, docId);
            Navigator.pop(context);
          },
          child: const Text("Hapus", style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}

/// Function to Delete FAQ with Snackbar
void deleteFAQ(BuildContext context, String docId) {
  FirebaseFirestore.instance.collection('faq').doc(docId).delete().then((_) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("FAQ berhasil dihapus!"),
        backgroundColor: Colors.red, // Warna merah
        behavior: SnackBarBehavior.floating,
      ),
    );
  }).catchError((error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Gagal menghapus: $error"),
        backgroundColor: Colors.grey, // Warna abu-abu jika gagal
        behavior: SnackBarBehavior.floating,
      ),
    );
  });
}

void showEditDialog(BuildContext context, String docId, String currentAnswer,
    bool currentRequiresQuestion, String currentStatus) {
  TextEditingController answerController =
      TextEditingController(text: currentAnswer);
  bool requiresQuestion = currentRequiresQuestion;
  String status = currentStatus;

  List<String> statusOptions = ['Khusus', 'Penting', 'Teknis', 'Umum'];
  if (!statusOptions.contains(status)) {
    status = 'Umum';
  }

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: const Text("Edit FAQ"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: answerController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: "Masukkan jawaban baru",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Pertanyaan wajib?"),
                  Switch(
                    value: requiresQuestion,
                    onChanged: (value) =>
                        setState(() => requiresQuestion = value),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Status"),
                  DropdownButton<String>(
                    value: status,
                    items: statusOptions.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) => setState(() => status = newValue!),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            TextButton(
              onPressed: () {
                updateFAQ(context, docId, answerController.text,
                    requiresQuestion, status);
                Navigator.pop(context);
              },
              child: const Text("Simpan", style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    ),
  );
}

void updateFAQ(BuildContext context, String docId, String newAnswer,
    bool requiresQuestion, String status) {
  FirebaseFirestore.instance.collection('faq').doc(docId).update({
    'answer': newAnswer,
    'requires_question': requiresQuestion,
    'status': status,
  }).then((_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("FAQ berhasil diperbarui!"),
          backgroundColor: Colors.green,
        ),
      );
    }
  }).catchError((error) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal memperbarui FAQ: $error"),
          backgroundColor: Colors.red,
        ),
      );
    }
  });
}
