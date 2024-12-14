import 'dart:typed_data';
import 'dart:html' as html; // For web file handling
import 'package:admin_panel_komp/sidebar_controller.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../widgets/colors.dart';
import '../widgets/custom_text.dart';

class AddAudio extends StatefulWidget {
  const AddAudio({super.key});

  @override
  State<AddAudio> createState() => _AddAudioState();
}

class _AddAudioState extends State<AddAudio> {
  bool _isUploading = false;
  String? _uploadStatus;
  final SidebarController sidebarController =Get.put(SidebarController());

  String? _category; // To store category input
  String? _duration; // To store duration input
  String? _title; // To store title input

  Future<void> uploadAudio() async {
    try {
      // Pick an audio file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'wav', 'm4a'],
      );

      if (result != null) {
        // Get the selected file
        String fileName = result.files.single.name;
        var platformFile = result.files.single;

        // Web-specific file handling
        Uint8List? fileBytes;
        if (html.window.navigator.userAgent.contains('Chrome')) {
          // Web-specific handling for Chrome
          fileBytes = platformFile.bytes;
        } else {
          // Mobile or other platforms, we can use file directly
          fileBytes = platformFile.bytes;
        }

        // Show uploading status
        setState(() {
          _isUploading = true;
          _uploadStatus = "Uploading $fileName...";
        });

        // Upload to Firebase Storage
        final storageRef = FirebaseStorage.instance.ref('audio/$fileName');
        final uploadTask = storageRef.putData(fileBytes!);

        await uploadTask.whenComplete(() async {
          final downloadUrl = await storageRef.getDownloadURL();

          // Save metadata to Firestore
          await FirebaseFirestore.instance.collection('audio_files').add({
            'Category': _category ?? 'Default Category', // Ensure you get the category from user input
            'duration': _duration ?? 'Unknown Duration', // Ensure you get the duration from user input
            'title': _title ?? fileName, // Use the provided title or the file name as default
            'url': downloadUrl,
            'uploadedAt': FieldValue.serverTimestamp(),
          });

          setState(() {
            _uploadStatus = "Upload successful: $fileName";
          });
        });
      } else {
        setState(() {
          _uploadStatus = "No file selected.";
        });
      }
    } catch (e) {
      setState(() {
        _uploadStatus = "Error during upload: $e";
      });
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(

      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: width<380?5:width < 425
              ? 15 // You can specify the width for widths less than 425
              : width < 768
              ? 20 // You can specify the width for widths less than 768
              : width < 1024
              ? 70 // You can specify the width for widths less than 1024
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

              Get.width<768?  GestureDetector(
                onTap: () {
                  sidebarController.showsidebar.value =true;
                },
                child:SvgPicture.asset('assets/images/drawernavigation.svg',color: primaryColorKom,),

              ):SizedBox.shrink(),
              SizedBox(height: 20,),
              const AsulCustomText(
                text: 'Add Audio',
                fontsize: 24,
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 25),              buildTextField(
                label: 'Category',
                onChanged: (value) => setState(() => _category = value),
              ),
              buildTextField(
                label: 'Duration',
                onChanged: (value) => setState(() => _duration = value),
              ),
              buildTextField(
                label: 'Title',
                onChanged: (value) => setState(() => _title = value),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: 180,
                child: ElevatedButton.icon(
                  onPressed: _isUploading ? null : uploadAudio,
                  icon: const Icon(Icons.upload_file, color: Colors.white),
                  label: const Text(
                    "Upload Audio",
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
              if (_isUploading)
                const SizedBox(height: 20),
              if (_isUploading)
                CircularProgressIndicator(
                  strokeWidth: 3.0, // Smaller stroke width for a more elegant loader
                ),

              if (_uploadStatus != null) ...[
                const SizedBox(height: 20),
                Text(
                  _uploadStatus!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _uploadStatus!.contains("Error")
                        ? Colors.red
                        : Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // A helper function to create text fields with consistent styling
  Widget buildTextField({
    required String label,
    required Function(String) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: SizedBox(
        width: 700,
        child: TextField(

          onChanged: onChanged,
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
            // filled: true,
            // fillColor: Colors.grey[200],
          ),
        ),
      ),
    );
  }
}
