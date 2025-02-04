import 'package:ARTShift/widgets/apptheme.dart';
import 'package:ARTShift/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class KelolaFAQScreen extends StatefulWidget {
  const KelolaFAQScreen({super.key});

  @override
  State<KelolaFAQScreen> createState() => _KelolaFAQScreenState();
}

class _KelolaFAQScreenState extends State<KelolaFAQScreen> {
  final TextEditingController _answerController = TextEditingController();
  String _selectedStatus = 'Umum';
  bool _requiresQuestion = true;

  Future<void> addAnswer(String question, String answer, String docId) async {
    if (answer.isNotEmpty) {
      await FirebaseFirestore.instance.collection('faq').add({
        'question': question,
        'answer': answer,
        'count': 0,
        'status': _selectedStatus,
        'requires_question': _requiresQuestion,
      });

      await FirebaseFirestore.instance
          .collection('pending_questions')
          .doc(docId)
          .delete();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Jawaban tidak boleh kosong")),
      );
    }
  }

  Future<void> deletePendingQuestion(String docId) async {
    await FirebaseFirestore.instance
        .collection('pending_questions')
        .doc(docId)
        .delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Pertanyaan berhasil dihapus")),
    );
  }

  void showDeleteDialog(BuildContext context, String questionId) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.red,
                size: 28,
              ),
              SizedBox(width: 10),
              Text(
                "Konfirmasi Hapus Pertanyaan",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          content: const Text(
            "Apakah Anda yakin ingin menghapus pertanyaan ini?",
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text("Batal", style: TextStyle(color: Colors.green)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                deletePendingQuestion(questionId);
              },
              child: const Text("Hapus", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void showAnswerDialog(BuildContext context, String question, String docId) {
    bool localRequiresQuestion = _requiresQuestion;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              insetPadding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 20,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          'Tambahkan Jawaban',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _answerController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Masukkan jawaban Anda...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        items: ['Khusus', 'Penting', 'Teknis', 'Umum']
                            .map((status) => DropdownMenuItem(
                                  value: status,
                                  child: Text(status),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setDialogState(() {
                            _selectedStatus = value!;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Pilih Status',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Butuh Pertanyaan?",
                            style: TextStyle(fontSize: 16),
                          ),
                          Switch(
                            value: localRequiresQuestion,
                            activeColor: Colors.blueAccent,
                            onChanged: (value) {
                              setDialogState(() {
                                localRequiresQuestion = value;
                              });
                              _requiresQuestion = value;
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              _answerController.clear();
                              Navigator.pop(context);
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.redAccent,
                            ),
                            child: const Text('Batal'),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () {
                              addAnswer(
                                  question, _answerController.text, docId);
                              _answerController.clear();
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Simpan',
                              style: TextStyle(color: Colors.white),
                            ),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTheme.appBar(titleText: 'Kelola FAQ'),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Judul & Deskripsi
            const Text(
              "Pertanyaan yang Perlu Ditinjau",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              "Daftar pertanyaan ini memerlukan tinjauan sebelum dipublikasikan. Anda bisa menambahkan jawaban atau menghapus pertanyaan yang tidak relevan.",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            const Divider(thickness: 1.5),
            const SizedBox(height: 8),

            // Daftar Pertanyaan (Menggunakan StreamBuilder)
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('pending_questions')
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator.adaptive());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        "Tidak ada pertanyaan yang ditemukan",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    );
                  }

                  var pendingQuestions = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: pendingQuestions.length,
                    itemBuilder: (context, index) {
                      var questionData = pendingQuestions[index];
                      String question =
                          questionData['question'] ?? 'Pertanyaan kosong';
                      int userCount = questionData['user_count'] ?? 0;

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
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
                                      'Ditanyakan: $userCount kali',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Row(
                                children: [
                                  _actionButton(
                                    icon: Icons.add,
                                    color: Colors.blue,
                                    onTap: () {
                                      showAnswerDialog(
                                          context, question, questionData.id);
                                    },
                                  ),
                                  const SizedBox(width: 6),
                                  _actionButton(
                                    icon: Icons.delete,
                                    color: Colors.red,
                                    onTap: () {
                                      showDeleteDialog(
                                          context, questionData.id);
                                    },
                                  ),
                                ],
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
          ],
        ),
      ),
      floatingActionButton: CustomFloatingBackButton(),
    );
  }
}

// Fungsi untuk membuat tombol aksi dengan efek interaktif
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
