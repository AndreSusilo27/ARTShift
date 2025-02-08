import 'package:ARTShift/widgets/apptheme.dart';

import 'package:ARTShift/widgets/faqcard.dart';
import 'package:ARTShift/widgets/pertanyaanpending.dart';
import 'package:flutter/material.dart';

class KelolaFAQScreen extends StatefulWidget {
  const KelolaFAQScreen({super.key});

  @override
  State<KelolaFAQScreen> createState() => _KelolaFAQScreenState();
}

class _KelolaFAQScreenState extends State<KelolaFAQScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTheme.appBar(
        bottom: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                width: 4.0,
                color: Colors.white,
              ),
            ),
          ),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.blueGrey[400],
          labelStyle: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.7,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          tabs: [
            Tab(
              icon: Icon(Icons.pending_actions, size: 28),
              text: 'Pending',
            ),
            Tab(
              icon: Icon(Icons.list_alt, size: 28),
              text: 'FAQ',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          PendingQuestionsWidget(),
          FAQListWidget(),
        ],
      ),
    );
  }
}
