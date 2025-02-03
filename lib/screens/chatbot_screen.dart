import 'package:ARTShift/widgets/apptheme.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // Untuk format tanggal dan waktu

class FAQChatbotScreen extends StatefulWidget {
  const FAQChatbotScreen({super.key});

  @override
  State<FAQChatbotScreen> createState() => _FAQChatbotScreenState();
}

class _FAQChatbotScreenState extends State<FAQChatbotScreen> {
  final TextEditingController _questionController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Mendapatkan email pengguna saat ini
  String get _userEmail => _auth.currentUser?.email ?? 'unknown_user';

  Future<void> sendMessage(String question) async {
    if (question.isNotEmpty) {
      var faqCollection =
          await FirebaseFirestore.instance.collection('faq').get();
      String answer = "Maaf, saya tidak mengerti pertanyaan Anda.";

      bool foundAnswer = false;

      // Normalisasi pertanyaan
      String normalizedQuestion = question
          .toLowerCase()
          .replaceAll(RegExp(r'[^\w\s]'), ' ')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();

      String withoutSpaces = normalizedQuestion.replaceAll(" ", "");

      for (var doc in faqCollection.docs) {
        var faqData = doc.data();
        String normalizedFaqQuestion = faqData['question']
            .toLowerCase()
            .replaceAll(RegExp(r'[^\w\s]'), ' ')
            .replaceAll(RegExp(r'\s+'), ' ')
            .trim();

        String normalizedFaqWithoutSpaces =
            normalizedFaqQuestion.replaceAll(" ", "");

        if (normalizedFaqQuestion.contains(normalizedQuestion) ||
            normalizedFaqWithoutSpaces.contains(withoutSpaces)) {
          answer = faqData['answer'];
          await FirebaseFirestore.instance
              .collection('faq')
              .doc(doc.id)
              .update({'count': FieldValue.increment(1)});
          foundAnswer = true;
          break;
        }
      }

      if (!foundAnswer) {
        var pendingCollection = await FirebaseFirestore.instance
            .collection('pending_questions')
            .where('question', isEqualTo: question)
            .get();

        if (pendingCollection.docs.isEmpty) {
          await FirebaseFirestore.instance.collection('pending_questions').add({
            'question': question,
            'user_count': 1,
          });
        } else {
          await FirebaseFirestore.instance
              .collection('pending_questions')
              .doc(pendingCollection.docs.first.id)
              .update({'user_count': FieldValue.increment(1)});
        }
      }

      await FirebaseFirestore.instance
          .collection('chat_logs')
          .doc(_userEmail)
          .collection('conversations')
          .add({
        'question': question,
        'answer': answer,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _questionController.clear();
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  String formatDate(Timestamp timestamp) {
    if (timestamp.seconds <= 0) return "";
    DateTime date = timestamp.toDate();
    return DateFormat('HH:mm').format(date);
  }

  String getDayFromTimestamp(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    return DateFormat('EEEE, dd MMMM yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTheme.appBar(titleText: 'FAQ Chat AI'),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('chat_logs')
                  .doc(_userEmail)
                  .collection('conversations')
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                var conversations = snapshot.data!.docs;
                String lastDay = "";
                return ListView.builder(
                  controller: _scrollController,
                  itemCount: conversations.length,
                  // Dalam builder ListView, ubah kode ini:
                  itemBuilder: (context, index) {
                    var conversation = conversations[index];
                    var timestampData = conversation['timestamp'];

                    // Memeriksa apakah 'timestamp' null atau tidak bertipe Timestamp
                    if (timestampData == null || timestampData is! Timestamp) {
                      return SizedBox(); // Atau handle error dengan cara lain, misal tampilkan pesan error.
                    }

                    Timestamp timestamp = timestampData;
                    String formattedTime = formatDate(timestamp);
                    String currentDay = getDayFromTimestamp(timestamp);

                    // Cek apakah tanggalnya berubah untuk menambahkan pembatas
                    bool isNewDay = currentDay != lastDay;
                    if (isNewDay) {
                      lastDay = currentDay;
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isNewDay)
                            // Pembatas Hari
                            Align(
                              alignment: Alignment.center,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    vertical: 5.0, horizontal: 15.0),
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: Text(
                                  currentDay, // Menampilkan hari dengan format 'Day, dd MMM yyyy'
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          SizedBox(height: 10),
                          // Pertanyaan User (Align kanan)
                          Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.7),
                              padding: EdgeInsets.all(12.0),
                              decoration: BoxDecoration(
                                color: Colors.blueAccent,
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    conversation['question'],
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    formattedTime,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          // Jawaban Chatbot (Align kiri)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.7),
                              padding: EdgeInsets.all(12.0),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    conversation['answer'],
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    formattedTime,
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(11, 0, 7, 9),
            child: Container(
              decoration: BoxDecoration(
                color: Color.fromARGB(215, 5, 10, 85),
                borderRadius: BorderRadius.circular(
                    20.0), // Sudut melengkung pada background
                boxShadow: [
                  BoxShadow(
                    color:
                        Colors.black.withOpacity(0.1), // Efek bayangan lembut
                    blurRadius: 8.0,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(
                    12.0), // Padding internal untuk memberi ruang
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                              30.0), // Membuat sudut TextField melengkung
                        ),
                        child: TextField(
                          controller: _questionController,
                          decoration: InputDecoration(
                            hintText: 'Tanyakan sesuatu...',
                            hintStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: const Color.fromARGB(145, 0, 0, 0)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: BorderSide
                                  .none, // Menghilangkan border pada TextField
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 15.0, horizontal: 20.0),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        sendMessage(_questionController.text);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors
                              .blueAccent, // Warna tombol kirim tetap biru
                          borderRadius: BorderRadius.circular(50.0),
                        ),
                        padding: EdgeInsets.all(12.0),
                        child: Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
