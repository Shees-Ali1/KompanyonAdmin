import 'package:admin_panel_komp/colors.dart';
import 'package:admin_panel_komp/custom_text.dart';
import 'package:admin_panel_komp/sidebar_controller.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class Responses extends StatelessWidget {
  // Fetch all user responses from the userResponses collection
  Future<List<Map<String, dynamic>>> fetchAllUserResponses() async {
    try {
      // Fetch all documents from the userResponses collection
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('userResponses').get();

      // Convert each document into a map with its ID and responses
      List<Map<String, dynamic>> allResponses = querySnapshot.docs.map((doc) {
        return {
          'id': doc.id, // Document ID (user ID)
          'responses':
              doc['responses'] as Map<String, dynamic>, // Responses map
        };
      }).toList();

      return allResponses;
    } catch (e) {
      print('Error fetching all user responses: $e');
      return [];
    }
  }

  final SidebarController sidebarController = Get.put(SidebarController());

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
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
              Get.width < 768
                  ? GestureDetector(
                      onTap: () {
                        sidebarController.showsidebar.value = true;
                      },
                      child: SvgPicture.asset(
                        'assets/images/drawernavigation.svg',
                        color: primaryColorKom,
                      ),
                    )
                  : SizedBox.shrink(),
              SizedBox(
                height: 20,
              ),
              AsulCustomText(
                text: "All User Responses",
                fontsize: 22,
              ),
              const SizedBox(height: 25),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: fetchAllUserResponses(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                    // Get the list of all user responses
                    List<Map<String, dynamic>> allResponses = snapshot.data!;

                    return ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: allResponses.length,
                      itemBuilder: (context, index) {
                        // Get each user's responses
                        Map<String, dynamic> userResponse = allResponses[index];
                        String userId = userResponse['id'];
                        Map<String, dynamic> responsesMap =
                            userResponse['responses'];

                        // Convert responses map to a list of entries
                        List<MapEntry<String, dynamic>> responsesList =
                            responsesMap.entries.toList();

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
                    return Center(child: Text("No user responses found"));
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
