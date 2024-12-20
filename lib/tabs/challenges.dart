import 'dart:html' as html; // For web file handling
import 'package:admin_panel_komp/tabs/notification_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../sidebar_controller.dart';
import '../widgets/colors.dart';
import '../widgets/custom_buuton.dart';
import '../widgets/custom_text.dart';

class Challenges extends StatefulWidget {
  const Challenges({super.key});

  @override
  State<Challenges> createState() => _ChallengesState();
}

class _ChallengesState extends State<Challenges> {
  final SidebarController sidebarController = Get.put(SidebarController());

  // Controllers for the input fields
  final TextEditingController challengeTitleController =
      TextEditingController();
  final TextEditingController challengeDescriptionController =
      TextEditingController();

  // Function to add a challenge to Firestore
  Future<void> addChallenge() async {
    if (challengeTitleController.text.isNotEmpty &&
        challengeDescriptionController.text.isNotEmpty) {
      await FirebaseFirestore.instance.collection('Challenges_section').add({
        'title': challengeTitleController.text,
        'description': challengeDescriptionController.text,
        'created_at': FieldValue.serverTimestamp(),
        'completed': false, // Initially not completed
      });

      // Clear the input fields after adding
      challengeTitleController.clear();
      challengeDescriptionController.clear();

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Challenge added successfully!')),
      );
    }
  }

  // Function to remove a challenge from Firestore
  Future<void> removeChallenge(String challengeId) async {
    try {
      // Delete the challenge document
      await FirebaseFirestore.instance
          .collection('Challenges_section')
          .doc(challengeId)
          .delete();

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Challenge removed successfully!')),
      );
    } catch (e) {
      // Handle error
      print("Error removing challenge: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error removing challenge!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: width < 380
              ? 5
              : width < 425
                  ? 15
                  : width < 768
                      ? 20
                      : width < 1024
                          ? 70
                          : width <= 1440
                              ? 60
                              : width > 1440 && width <= 2550
                                  ? 60
                                  : 80,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 35),
              if (Get.width < 768)
                GestureDetector(
                  onTap: () {
                    sidebarController.showsidebar.value = true;
                  },
                  child: SvgPicture.asset(
                    'assets/images/drawernavigation.svg',
                    color: primaryColorKom,
                  ),
                ),
              const SizedBox(height: 20),
              const AsulCustomText(
                text: 'Add Challenges',
                fontsize: 24,
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 25),

              // Input fields for Challenge Title and Description
              TextField(
                controller: challengeTitleController,
                decoration: InputDecoration(
                  labelText: 'Challenge Title',
                  labelStyle: const TextStyle(color: primaryColorKom),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: primaryColorKom),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: primaryColorKom),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: challengeDescriptionController,
                decoration: InputDecoration(
                  labelText: 'Challenge',
                  labelStyle: const TextStyle(color: primaryColorKom),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: primaryColorKom),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: primaryColorKom),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Button to Add Challenge
              CustomButton(
                text: 'Add Challenge',
                onPressed: addChallenge,
                height: 38,
                width: 150,
              ),
              const SizedBox(height: 40),

              // Display Existing Challenges from Firestore
              const AsulCustomText(
                text: 'Challenges',
                fontsize: 24,
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 20),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Challenges_section')
                    .orderBy('created_at', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text('Something went wrong'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                        child: Text('No challenges available.'));
                  }

                  final challenges = snapshot.data!.docs;
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: challenges.length,
                    itemBuilder: (context, index) {
                      final challenge = challenges[index];
                      final challengeId = challenge.id; // Get the document ID
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                challenge['title'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(challenge['description']),
                              const SizedBox(height: 20),
                              CustomButton(
                                height: 40,
                                width: 150,
                                text: 'Remove Challenge',
                                onPressed: () {
                                  removeChallenge(
                                      challengeId); // Call removeChallenge function
                                },
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
