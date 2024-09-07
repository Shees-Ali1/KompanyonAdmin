import 'dart:io';
import 'package:admin_panel_komp/read.dart';
import 'package:admin_panel_komp/responses.dart';
import 'package:admin_panel_komp/sidebar_controller.dart';
import 'package:admin_panel_komp/user_details.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'assessments.dart';
import 'home_main_admin.dart';

class HomeMain extends StatefulWidget {
  const HomeMain({super.key});

  @override
  State<HomeMain> createState() => _HomeMainState();
}

class _HomeMainState extends State<HomeMain> {
  final SidebarController sidebarController = Get.put(SidebarController());
  @override
  Widget build(BuildContext context) {
    final width=MediaQuery.of(context)!.size.width;
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          if(sidebarController.showsidebar.value ==true) {
            sidebarController.showsidebar.value =false;
          }
        },
        child: Stack(
          children: [
            Row(
              children: [
                width>=768?ExampleSidebarX():SizedBox.shrink(),
                Expanded(
                    child: Obx(() => sidebarController.selectedindex.value == 0
                        ? UserDetails()
                        : sidebarController.selectedindex.value == 1
                        ? Assessments()
                        : sidebarController.selectedindex.value == 2
                        ? Read()
                        : Responses()))
              ],
            ),
            Obx(()=>sidebarController.showsidebar.value == true? ExampleSidebarX():SizedBox.shrink(),)

          ],
        ),
      ),
    );
  }
}
