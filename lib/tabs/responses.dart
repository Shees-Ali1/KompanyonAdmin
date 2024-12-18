import 'package:admin_panel_komp/widgets/colors.dart';
import 'package:admin_panel_komp/widgets/custom_text.dart';
import 'package:admin_panel_komp/sidebar_controller.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:admin_panel_komp/widgets/custom_text.dart';
import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;

import '../widgets/custom_buuton.dart';


class Responses extends StatelessWidget {
  // Fetch all user responses from the userResponses collection
  Future<List<Map<String, dynamic>>> fetchAllUserResponses() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('userResponses').get();
      List<Map<String, dynamic>> allResponses = querySnapshot.docs.map((doc) {
        return {
          'uid': doc.id, // Document ID (uid)
          'responses': doc['responses'] as Map<String, dynamic>, // Responses map
        };
      }).toList();
      return allResponses;
    } catch (e) {
      print('Error fetching all user responses: $e');
      return [];
    }
  }

  Future<String> fetchUserName(String uid) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('userDetails').doc(uid).get();

      if (userDoc.exists) {
        final userName = userDoc['name']; // Fetch the 'name' field from the document
        if (userName != null) {
          print('Name found for $uid: $userName');
          return userName ?? 'Unknown'; // Providing a fallback value if userName is null
        } else {
          print('Name field is missing for $uid');
          return 'Name not found';
        }
      } else {
        print('User document not found for $uid');
        return 'User not found';
      }
    } catch (e) {
      print('Error fetching user name for $uid: $e');
      return 'Error fetching name';
    }
  }

  // Generate the PDF with user responses
  Future<Uint8List> generatePdf(List<Map<String, dynamic>> data) async {
    final pdf = pw.Document();

    // Fetch all user names first, then generate the PDF
    List<String> userNames = await Future.wait(data.map((userResponse) {
      return fetchUserName(userResponse['uid']);
    }));

    // Print names to debug
    print('Fetched user names: $userNames'); // Debugging line

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (context) => [
          for (var i = 0; i < data.length; i++) _buildUserResponse(data[i], userNames[i], i),
        ],
      ),
    );

    return pdf.save();
  }

  // Build a single user's response details
  pw.Widget _buildUserResponse(Map<String, dynamic> userResponse, String userName, int userIndex) {
    final uid = userResponse['uid'];
    final responses = userResponse['responses'] as Map<String, dynamic>;

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 20),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            "User Name: $userName", // Displaying "User 1", "User 2", etc. with name
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          _buildResponses(responses),
          pw.Divider(),
        ],
      ),
    );
  }

  // Recursive function to handle nested data
  pw.Widget _buildResponses(Map<String, dynamic> responses) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: responses.entries.map((entry) {
        final key = entry.key;
        final value = entry.value;

        if (value is Map<String, dynamic>) {
          return pw.Container(
            margin: const pw.EdgeInsets.only(left: 10),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  "$key:",
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                _buildResponses(value),
              ],
            ),
          );
        } else if (value is List) {
          return pw.Text("$key: ${value.join(", ")}");
        } else {
          return pw.Text("$key: $value");
        }
      }).toList(),
    );
  }

  // Download PDF
  void downloadPdf(Uint8List pdfBytes) {
    final blob = html.Blob([pdfBytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..target = 'blank'
      ..download = "user_responses.pdf"
      ..click();
    html.Url.revokeObjectUrl(url);
  }
  final SidebarController sidebarController = Get.put(SidebarController());

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(

      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: width < 380
              ? 5
              : width < 425
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 15),
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AsulCustomText(
                  text: "All User Responses",
                  fontsize: 22,
                ),
               FutureBuilder<List<Map<String, dynamic>>>( // Future to fetch data
                  future: fetchAllUserResponses(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator(color: Colors.white,backgroundColor: Colors.white,),);
                    } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      return CustomButton(
                        text: 'Download Responses',
                        height: 40,
                        width: 160,
                        onPressed: () async {
                          final pdfBytes = await generatePdf(snapshot.data!);
                          downloadPdf(pdfBytes);
                        },
                      );
                    } else {
                      return SizedBox();
                    }
                  },
                )
              ],
            ),
            const SizedBox(height: 15),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: fetchAllUserResponses(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    // Get the list of all user responses
                    List<Map<String, dynamic>> allResponses = snapshot.data!;

                    if (allResponses.isEmpty) {
                      return const Center(child: Text("No user responses found"));
                    }

                    return ListView.builder(
                      itemCount: allResponses.length,
                      itemBuilder: (context, index) {
                        // Get each user's responses
                        Map<String, dynamic> userResponse = allResponses[index];

                        // Check if the necessary data exists
                        if (userResponse['uid'] == null || userResponse['responses'] == null) {
                          return ListTile(
                            title: Text("User not found or missing responses"),
                          );
                        }

                        String userId = userResponse['uid'];
                        Map<String, dynamic> responsesMap = userResponse['responses'];

                        // Convert responses map to a list of entries
                        List<MapEntry<String, dynamic>> responsesList = responsesMap.entries.toList();

                        return Theme(
                          data: Theme.of(context).copyWith(
                            dividerColor: Colors.transparent,
                          ),
                          child: ExpansionTile(
                            title: AsulCustomText(text: "User ID: $userId"),
                            children: responsesList.map((entry) {
                              String key = entry.key;
                              dynamic value = entry.value;

                              // Handle if value is a list or a single item
                              String displayValue;
                              if (value is List) {
                                displayValue = value.join(", ");
                              } else {
                                displayValue = value.toString();
                              }

                              return ListTile(
                                leading: Text(key),
                                title: Text(displayValue),
                              );
                            }).toList(),
                          ),
                        );
                      },
                    );
                  } else {
                    return const Center(child: Text("No user responses found"));
                  }
                },
              ),
            ),

          ],
        ),
      ),
    );
  }
}
