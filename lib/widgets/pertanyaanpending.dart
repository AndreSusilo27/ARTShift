import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PendingQuestionsWidget extends StatefulWidget {
  const PendingQuestionsWidget({super.key});

  @override
  State<PendingQuestionsWidget> createState() => _PendingQuestionsWidgetState();
}

class _PendingQuestionsWidgetState extends State<PendingQuestionsWidget> {
  final TextEditingController _answerController = TextEditingController();
  String _selectedStatus = 'Umum';
  bool _requiresQuestion = true;

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _addAnswer(String question, String answer, String docId) async {
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
      _showSnackBar("Jawaban berhasil ditambahkan",
          backgroundColor: Colors.green);
    } else {
      _showSnackBar("Jawaban tidak boleh kosong", backgroundColor: Colors.red);
    }
  }

  Future<void> _deletePendingQuestion(String docId) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Konfirmasi Hapus"),
          content: const Text(
              "Apakah Anda yakin ingin menghapus pertanyaan ini? Tindakan ini tidak dapat dibatalkan."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context); // Tutup dialog sebelum menghapus
                await FirebaseFirestore.instance
                    .collection('pending_questions')
                    .doc(docId)
                    .delete();
                _showSnackBar("Pertanyaan berhasil dihapus",
                    backgroundColor: Colors.red);
              },
              child: const Text("Ya", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(String message, {Color backgroundColor = Colors.black}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
        ),
      );
    }
  }

  void _showAnswerDialog(String question, String docId) {
    _answerController.clear();
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text("Tambahkan Jawaban",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blueAccent)),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _answerController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Masukkan jawaban Anda...',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedStatus,
                      items: ['Khusus', 'Penting', 'Teknis', 'Umum']
                          .map((status) => DropdownMenuItem(
                              value: status, child: Text(status)))
                          .toList(),
                      onChanged: (value) =>
                          setStateDialog(() => _selectedStatus = value!),
                      decoration: InputDecoration(
                        labelText: 'Pilih Status',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: const Text("Butuh Pertanyaan?"),
                      value: _requiresQuestion,
                      activeColor: Colors.blueAccent,
                      onChanged: (value) {
                        setStateDialog(() => _requiresQuestion = value);
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                              foregroundColor: Colors.redAccent),
                          child: const Text('Batal'),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            _addAnswer(question, _answerController.text, docId);
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent),
                          child: const Text('Simpan',
                              style: TextStyle(color: Colors.white)),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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
                                  icon: Icons.post_add,
                                  color: Colors.blue,
                                  onTap: () {
                                    _showAnswerDialog(
                                        question, questionData.id);
                                  },
                                ),
                                const SizedBox(width: 6),
                                _actionButton(
                                  icon: Icons.delete,
                                  color: Colors.red,
                                  onTap: () {
                                    _deletePendingQuestion(questionData.id);
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
    );
  }
}

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
