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

class Help extends StatefulWidget {
  const Help({super.key});

  @override
  State<Help> createState() => _HelpState();
}

class _HelpState extends State<Help> {
  final SidebarController sidebarController = Get.put(SidebarController());
  final TextEditingController questionController = TextEditingController();
  final TextEditingController answerController = TextEditingController();

  // Function to add a new FAQ to Firebase Firestore
  Future<void> addFAQ() async {
    if (questionController.text.isNotEmpty && answerController.text.isNotEmpty) {
      await FirebaseFirestore.instance.collection('help_section').add({
        'question': questionController.text,
        'answer': answerController.text,
        'created_at': FieldValue.serverTimestamp(),
      });
      questionController.clear();
      answerController.clear();
      Get.snackbar('Success', 'FAQ added successfully');
    } else {
      Get.snackbar('Error', 'Please fill in both fields');
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
                text: 'Add Help',
                fontsize: 24,
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 25),
              TextField(
                controller: questionController,
                decoration: InputDecoration(
                  labelText: 'Question',
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
                controller: answerController,
                maxLines: 8,
                decoration: InputDecoration(
                  labelText: 'Answer',
                  labelStyle: const TextStyle(color: primaryColorKom),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.deepPurple),
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
              ),


              const SizedBox(height: 20),
              CustomButton(
                text: 'Publish FAQs',
                onPressed: addFAQ,
                height: 38,
                width: 150,
              ),
              const SizedBox(height: 40),

              // Display FAQs from Firestore
              const AsulCustomText(
                text: 'FAQs',
                fontsize: 24,
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 20),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('help_section')
                    .orderBy('created_at', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),  // Loader while waiting
                    );
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text('Something went wrong'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No FAQs available.'));
                  }

                  final faqs = snapshot.data!.docs;
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: faqs.length,
                    itemBuilder: (context, index) {
                      final faq = faqs[index];
                      final faqId = faq.id; // Get the document ID

                      return Dismissible(
                        key: Key(faqId),  // Unique key for each item
                        direction: DismissDirection.endToStart, // Slide to the right to delete
                        onDismissed: (direction) async {
                          // Delete the FAQ from Firestore
                          try {
                            await FirebaseFirestore.instance
                                .collection('help_section')
                                .doc(faqId)
                                .delete();
                            Get.snackbar('Success', 'FAQ deleted successfully');
                          } catch (e) {
                            Get.snackbar('Error', 'Error deleting FAQ');
                          }
                        },
                        background: Container(
                          color: Colors.red,  // Red background when swiped
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                        child: Card(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          child: Padding(
                            padding: const EdgeInsets.all(15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  faq['question'],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(faq['answer']),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              )


            ],
          ),
        ),
      ),
    );
  }
}
