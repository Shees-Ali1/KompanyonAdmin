
import 'package:admin_panel_komp/responsive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../constants.dart';
import 'Login_Page.dart';

class Header extends StatelessWidget {
  const Header({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        children: [
          if (!Responsive.isDesktop(context))
            IconButton(icon: Icon(Icons.menu), onPressed: () {}
              // context.read<MenuAppController>().controlMenu,
            ),
          if (!Responsive.isMobile(context))
            Row(
              children: [
                Text(
                  "Dashboard",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SizedBox(width: 30,),
                IconButton(icon: Icon(Icons.notifications), onPressed: () {
                  // Get.to(NotificationScreen());
                })
              ],
            ),

          if (!Responsive.isMobile(context))
            Spacer(flex: Responsive.isDesktop(context) ? 2 : 1),
          // Expanded(child: SearchField()),
          ProfileCard()
        ],
      ),
    );
  }
}

class ProfileCard extends StatefulWidget {
  const ProfileCard({
    Key? key,
  }) : super(key: key);

  @override
  State<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  String userName = '';
  String userImage = '';

  @override
  void initState () {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_){
      asyncInitState();
    });
  }

  asyncInitState() async {
    DocumentSnapshot user = await firestore.collection('userDetails').doc(auth.currentUser!.uid).get();
    setState(() {
      userName = user['name'];
      userImage = user['profileImageUrl'];
    });
    print("loaded: ${userName}");
    print("loaded: ${userImage}");
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: secondaryColor,
          title: Text('Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              child: Text(
                'No',
                style: TextStyle(color: Colors.blue),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
            ),
            TextButton(
              child: Text(
                'Yes',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () async {
                await FirebaseAuth.instance.signOut(); // Sign out from Firebase
                Navigator.of(context).pop(); // Dismiss the dialog
                // Optionally navigate to the login screen or handle the logout logic here
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                      builder: (context) =>
                          LoginPage()), // Assuming you have a LoginScreen
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: defaultPadding),
      padding: EdgeInsets.symmetric(
        horizontal: defaultPadding,
        vertical: defaultPadding / 2,
      ),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        border: Border.all(color: Colors.white10),
      ),
      child: GestureDetector(
        onTap: _showLogoutDialog,
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      image: NetworkImage(userImage),
                      fit: BoxFit.cover)),
            ),
            if (!Responsive.isMobile(context))
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: defaultPadding / 2),
                child: Row(
                  children: [
                    Text(userName!),
                    SizedBox(
                      width: 10,
                    ),
                    Icon(Icons.logout_outlined),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
