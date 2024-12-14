import 'dart:html' as html; // For web file handling
import 'package:admin_panel_komp/tabs/notification_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../sidebar_controller.dart';
import '../widgets/colors.dart';
import '../widgets/custom_text.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  final SidebarController sidebarController = Get.put(SidebarController());
  final NotificationsModel notificationVM = Get.put(NotificationsModel());

  final TextEditingController titleController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  // Add a variable to track loading state
  bool isLoading = false;

  void saveNotification() async {
    String title = titleController.text.trim();
    String message = messageController.text.trim();

    if (title.isEmpty || message.isEmpty) {
      Get.snackbar(
        "Error",
        "Title and message cannot be empty.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Set loading to true when notification is being sent
    setState(() {
      isLoading = true;
    });

    try {
      await FirebaseFirestore.instance.collection("notifications").add({
        "title": title,
        "message": message,
        "timestamp": FieldValue.serverTimestamp(),
      });

      await notificationVM.sendNotificationtoAll("", "");

      Get.snackbar(
        "Success",
        "Notification sent successfully.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Clear input fields
      titleController.clear();
      messageController.clear();
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to send notification. Please try again.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      // Set loading to false after operation completes
      setState(() {
        isLoading = false;
      });
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
                text: 'Add Notifications',
                fontsize: 24,
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 25),
              buildTextField(
                controller: titleController,
                label: 'SnackBar Title',
              ),
              buildTextField(
                controller: messageController,
                label: 'Message',
              ),
              const SizedBox(height: 20),
              SizedBox(
                child: ElevatedButton.icon(
                  onPressed: saveNotification,
                  icon: const Icon(Icons.send, color: Colors.white),
                  label: const Text(
                    "Push Notification",
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColorKom,
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              // Show loader when isLoading is true
              if (isLoading)
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: CircularProgressIndicator(
                    color: primaryColorKom,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: SizedBox(
        width: 700,
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
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
      ),
    );
  }
}
