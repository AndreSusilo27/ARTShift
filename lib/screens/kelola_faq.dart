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

  // Fungsi untuk menambahkan jawaban
  Future<void> addAnswer(String question, String answer, String docId) async {
    if (answer.isNotEmpty) {
      // Menambahkan jawaban ke koleksi FAQ
      await FirebaseFirestore.instance.collection('faq').add({
        'question': question,
        'answer': answer,
        'count': 0,
      });

      // Menghapus pertanyaan yang sudah dijawab dari koleksi pending_questions
      await FirebaseFirestore.instance
          .collection('pending_questions')
          .doc(docId)
          .delete();
    } else {
      // Menampilkan pesan jika jawaban kosong
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Jawaban tidak boleh kosong")),
      );
    }
  }

  // Fungsi untuk menghapus pertanyaan yang ada di koleksi pending_questions
  Future<void> deletePendingQuestion(String docId) async {
    await FirebaseFirestore.instance
        .collection('pending_questions')
        .doc(docId)
        .delete();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Pertanyaan berhasil dihapus")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTheme.appBar(titleText: 'Kelola FAQ'),
      body: StreamBuilder(
        // Mendengarkan perubahan pada koleksi 'pending_questions'
        stream: FirebaseFirestore.instance
            .collection('pending_questions')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            // Jika data belum tersedia, tampilkan loading
            return Center(child: CircularProgressIndicator());
          }

          // Jika tidak ada data dalam 'pending_questions'
          if (snapshot.data!.docs.isEmpty) {
            return Center(child: Text("Tidak ada pertanyaan yang ditemukan"));
          }

          var pendingQuestions = snapshot.data!.docs;
          return ListView.builder(
            itemCount: pendingQuestions.length,
            itemBuilder: (context, index) {
              var questionData = pendingQuestions[index];

              // Mengambil data dengan pengecekan null
              String question = questionData['question'] ?? 'Pertanyaan kosong';
              int userCount = questionData['user_count'] ?? 0;

              return Card(
                margin: EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(question),
                  subtitle: Text('Ditanyakan: $userCount kali'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Tombol untuk menambahkan jawaban
                      InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () {
                          // Menampilkan dialog untuk menambahkan jawaban
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text('Tambahkan Jawaban'),
                                content: TextField(
                                  controller: _answerController,
                                  decoration: InputDecoration(
                                      hintText: 'Masukkan jawaban'),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      addAnswer(
                                        question,
                                        _answerController.text,
                                        questionData.id,
                                      );
                                      _answerController.clear();
                                      Navigator.pop(context);
                                    },
                                    child: Text('Simpan'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(60, 3, 168, 244),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.blue,
                            size: 22,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Tombol untuk menghapus pertanyaan
                      InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () {
                          // Konfirmasi sebelum menghapus
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text('Konfirmasi'),
                                content: Text(
                                    'Apakah Anda yakin ingin menghapus pertanyaan ini?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text('Batal'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      deletePendingQuestion(questionData.id);
                                      Navigator.pop(context);
                                    },
                                    child: Text('Hapus'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(60, 244, 67, 54),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.red,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: CustomFloatingBackButton(),
    );
  }
}
