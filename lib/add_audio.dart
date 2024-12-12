import 'dart:typed_data';
import 'dart:html' as html; // For web file handling
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddAudio extends StatefulWidget {
  const AddAudio({super.key});

  @override
  State<AddAudio> createState() => _AddAudioState();
}

class _AddAudioState extends State<AddAudio> {
  bool _isUploading = false;
  String? _uploadStatus;

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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Audio"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Input fields for category, duration, and title
            TextField(
              decoration: const InputDecoration(labelText: 'Category'),
              onChanged: (value) {
                setState(() {
                  _category = value;
                });
              },
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Duration'),
              onChanged: (value) {
                setState(() {
                  _duration = value;
                });
              },
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Title'),
              onChanged: (value) {
                setState(() {
                  _title = value;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isUploading ? null : uploadAudio,
              icon: const Icon(Icons.upload_file),
              label: const Text("Upload Audio"),
            ),
            if (_isUploading) const CircularProgressIndicator(),
            if (_uploadStatus != null) ...[
              const SizedBox(height: 20),
              Text(
                _uploadStatus!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _uploadStatus!.contains("Error")
                      ? Colors.red
                      : Colors.green,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
