import 'package:admin_panel_komp/sidebar_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:sidebarx/sidebarx.dart';

import 'Login_Page.dart';
import 'colors.dart';

class ExampleSidebarX extends StatelessWidget {
  FirebaseAuth auth = FirebaseAuth.instance;

  final SidebarController sidebarController = Get.put(SidebarController());

  @override
  Widget build(BuildContext context) {
    print('hellosidebarController${sidebarController.selectedindex.value}');
    // final setNameProvider=Provider.of<GetHeadingNurseName>(context,listen: false);
    return SidebarX(
      controller: sidebarController.controller,
      theme: SidebarXTheme(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: primaryColorKom,
          borderRadius: BorderRadius.circular(20),
        ),
        hoverColor: backgroundColor,
        textStyle: TextStyle(color: primaryColorKom.withOpacity(0.5), fontSize: 18),
        selectedTextStyle: const TextStyle(color: primaryColorKom, fontSize: 18),
        hoverTextStyle: const TextStyle(
          fontSize: 18,
          color: primaryColorKom,
          fontWeight: FontWeight.w600,
        ),
        itemTextPadding: const EdgeInsets.only(left: 10),
        selectedItemTextPadding: const EdgeInsets.only(left: 10),
        itemDecoration: BoxDecoration(

          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: primaryColorKom),
        ),
        selectedItemDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: whiteColor,
          ),
          gradient: LinearGradient(
            colors: [Colors.white70, primaryColorKom.withOpacity(0.5)],
          ),
          boxShadow: [
            BoxShadow(
              color: backgroundColor,
              blurRadius: 30,
            )
          ],
        ),
        iconTheme: IconThemeData(
          color: primaryColorKom,
          size: 10,
        ),
        selectedIconTheme: const IconThemeData(
          color: Colors.white,
          size: 10,
        ),
      ),
      extendedTheme: SidebarXTheme(
        width: 200,
        decoration: BoxDecoration(
          color: backgroundColor,
        ),
      ),
      footerDivider: Divider(),
      headerBuilder: (context, extended) {
        return Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Obx(
              () => sidebarController.showsidebar.value == true
                  ? Align(
                      alignment: Alignment.topRight,
                      child: Icon(
                        Icons.clear_sharp,
                        color: primaryColorKom,
                      ))
                  : SizedBox.shrink(),
            ),
            Get.width <= 1440
                ? SizedBox(
                    height: 100,
                    width: 500,
                    child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Image.asset('assets/images/bgName.png')),
                  )
                : Get.width > 1440 && Get.width <= 2550
                    ? SizedBox(
                        height: 100,
                        width: 500,
                        child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Image.asset('assets/images/bgName.png')),
                      )
                    : SizedBox(
                        height: 80,
                        width: 220,
                        child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Image.asset('assets/images/bgName.png')),
                      ),
          ],
        );
      },
      items: [
        SidebarXItem(
            onTap: () {
              sidebarController.selectedindex.value = 0;
              // setNameProvider.setName('Home');
            },
            iconBuilder: (selected, hovered) {
              return Icon(Icons.home,color: Colors.transparent,);

            },
            label: 'User Data'),
        SidebarXItem(
            onTap: () {
              sidebarController.selectedindex.value = 1;

              // setNameProvider.setName('Diary');
            },
            iconBuilder: (selected, hovered) {
              return Icon(Icons.home,color: Colors.transparent,);

            },
            label: 'Assesments'),
        SidebarXItem(
            onTap: () {
              sidebarController.selectedindex.value = 2;

              // setNameProvider.setName('Previous Bookings');
            },
            iconBuilder: (selected, hovered) {
              return Icon(Icons.home,color: Colors.transparent,);

            },
            label: 'Read'),
        SidebarXItem(
            onTap: () {
              sidebarController.selectedindex.value = 3;

              // setNameProvider.setName('Profile');
            },
            iconBuilder: (selected, hovered) {
              return Icon(Icons.home,color: Colors.transparent,);
            },
            label: 'Responses'),
        SidebarXItem(
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pop();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => LoginPage()),
                (Route<dynamic> route) =>
                    false, // This ensures all previous routes are removed
              );

              // setNameProvider.setName('Log out');
              //
              // backendController.logOutUser(context);
            },
            iconBuilder: (selected, hovered) {
              return Icon(Icons.home,color: Colors.transparent,);

            },
            label: 'Log out'),
      ],
    );
  }
}
