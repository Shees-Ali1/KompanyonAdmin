import 'package:admin_panel_komp/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _totalUsers = 0;
  int _totalAssessmentsCompleted = 0;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    // Fetch total users from 'userDetails' collection
    QuerySnapshot userSnapshot =
        await _firestore.collection('userDetails').get();
    setState(() {
      _totalUsers = userSnapshot.docs.length;
    });

    // Fetch completed assessments from 'userDetails' collection, counting users with 'completed' field set to true
    QuerySnapshot completedSnapshot = await _firestore
        .collection('userDetails')
        .where('completed', isEqualTo: true)
        .get();
    setState(() {
      _totalAssessmentsCompleted = completedSnapshot.docs.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dashboard',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              title: const Text('Total Users'),
              trailing: Text(_totalUsers.toString()),
            ),
            ListTile(
              title: const Text('Completed Assessments'),
              trailing: Text(_totalAssessmentsCompleted.toString()),
            ),
          ],
        ),
      ),
    );
  }
}
