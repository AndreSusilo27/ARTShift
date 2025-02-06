import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FAQList extends StatelessWidget {
  final bool showCount;

  const FAQList({super.key, this.showCount = true}); // Default true

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('faq')
            .where('requires_question',
                isEqualTo: false) // Hanya data yang requires_question == false
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Tidak ada data FAQ."));
          }

          final faqs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: faqs.length,
            itemBuilder: (context, index) {
              final faqData = faqs[index];
              return CardFAQ(
                question: faqData['question'] ?? "Pertanyaan tidak tersedia",
                answer: faqData['answer'] ?? "Jawaban tidak tersedia",
                count: faqData['count'] ?? 0,
                showCount: showCount,
              );
            },
          );
        },
      ),
    );
  }
}

class CardFAQ extends StatefulWidget {
  final String question;
  final String answer;
  final int count;
  final bool showCount;

  const CardFAQ({
    super.key,
    required this.question,
    required this.answer,
    required this.count,
    this.showCount = true,
  });

  @override
  State<CardFAQ> createState() => _CardFAQState();
}

class _CardFAQState extends State<CardFAQ> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shadowColor: const Color.fromARGB(135, 0, 0, 0),
      margin: const EdgeInsets.only(top: 8, left: 10, right: 10, bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          ListTile(
            title: Text(
              widget.question,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            subtitle: widget.showCount
                ? Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: Text(
                      'Jumlah jawaban: ${widget.count}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  )
                : null,
            trailing: IconButton(
              icon: AnimatedRotation(
                turns: _isExpanded ? 0.5 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: const Icon(
                  Icons.keyboard_arrow_down_sharp,
                  color: Colors.blue,
                  size: 35,
                ),
              ),
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _isExpanded
                ? Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Text(
                      widget.answer,
                      style: const TextStyle(fontSize: 16),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
