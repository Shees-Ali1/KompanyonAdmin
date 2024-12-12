import 'package:admin_panel_komp/colors.dart';
import 'package:admin_panel_komp/custom_text.dart';
import 'package:admin_panel_komp/sidebar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController passwordController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  bool isPasswordVisible = false;
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  bool isLoading = false; // Add this at the top of your widget class

  void login() async {
    setState(() {
      isLoading = true; // Show loading indicator
    });

    try {
      // Sign in with email and password
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      String? uid = userCredential.user?.uid;
      print("Admin UID: $uid");

      // Fetch the ID token result to get the custom claims
      IdTokenResult idTokenResult =
      await userCredential.user!.getIdTokenResult();

      // Check if the user has the admin claim
      bool isAdmin = idTokenResult.claims?['admin'] == true;
      if (isAdmin) {
        print("Admin logged in: $uid");

        final UserController userController = Get.put(UserController());
        userController.setUid(uid!); // Update the controller with the UID
        Get.offAll(HomeMain()); // Navigate to MainDashboard
      } else {
        await FirebaseAuth.instance.signOut();

        print("User is not an admin");
        Get.snackbar("Access Denied", "You do not have admin privileges.");
      }
    } catch (e) {
      print("Login Error: $e"); // Print the error to the terminal
      Get.snackbar("Login Error", e.toString());
    } finally {
      setState(() {
        isLoading = false; // Hide loading indicator
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final width =MediaQuery.of(context).size.width;
    return Scaffold(
        body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
        width <= 1440
            ? SizedBox(
                width: 80,
                height: 80,
                child: Image.asset('assets/images/bglogo.png'))
            : width > 1440 && width <= 2550
                ? SizedBox(
                    width: 100,
                    height: 100,
                    child: Image.asset('assets/images/bglogo.png'))
                : SizedBox(
                    width: 150,
                    height: 150,
                    child: Image.asset('assets/images/bglogo.png')),
        const SizedBox(
          height: 30,
        ),
        const AsulCustomText(
          fontWeight: FontWeight.w700,
          fontsize: 20,
          text: 'Login',
        ),
        const SizedBox(
          height: 20,
        ),
        Container(
          width: width < 425
              ? 280 // You can specify the width for widths less than 425
              : width < 768
              ? 300 // You can specify the width for widths less than 768
              : width <= 1440
              ? 400
              : width > 1440 && width <= 2550
              ? 400
              : 700,

          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(
              color: Colors.grey,
              width: 1.0,
            ),
          ),
          child: TextField(
            style: const TextStyle(color: Colors.black),
            controller: emailController,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.all(14.0),
              prefixIcon: Icon(
                Icons.mail_outline,
                color: Color(0xFF264653),
              ),
              hintText: 'Enter email',
              border: InputBorder.none, // Remove the default underline border
            ),
          ),
        ),
        const SizedBox(
          height: 15,
        ),
        Align(
          alignment: Alignment.center,
          child: Container(
            width:width < 425
                ? 280 // You can specify the width for widths less than 425
                : width < 768
                ? 300 // You can specify the width for widths less than 768
                : width <= 1440
                ? 400
                : width > 1440 && width <= 2550
                ? 400
                : 700,

            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: Colors.grey,
                width: 1.0,
              ),
            ),
            child: TextField(
              style: const TextStyle(color: Colors.black),
              controller: passwordController,
              obscureText: !isPasswordVisible,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(14.0),
                prefixIcon: const Icon(Icons.lock, color: Color(0xFF264653)),
                suffixIcon: IconButton(
                  icon: Icon(
                    isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: const Color(0xFF264653),
                  ),
                  onPressed: () {
                    setState(() {
                      isPasswordVisible = !isPasswordVisible;
                    });
                  },
                ),
                hintText: 'Password',
                border: InputBorder.none,
              ),
            ),
          ),
        ),

        const SizedBox(
          height: 30,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const AsulCustomText(
              fontWeight: FontWeight.w700,
              fontsize: 20,
              text: 'Login',
            ),
            SizedBox(width: width < 425
                ? 170 // You can specify the width for widths less than 425
                : width < 768
                ? 190 // You can specify the width for widths less than 768
                : width <= 1440
                ? 300
                : width > 1440 && width <= 2550
                ? 300
                : 700,
            ),
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    blurRadius: 2,
                  ),
                ],
              ),
              child: isLoading
                  ? Center(
                    child: CircularProgressIndicator(
                                    color: primaryColorKom,
                                    // valueColor: AlwaysStoppedAnimation<Color>(primaryColorKom),
                                  ),
                  )
                  : IconButton(
                onPressed: login,
                icon: Transform.scale(
                  scale: 0.5,
                  child: Image.asset(
                    'assets/images/arrowIcon.png',
                    color: primaryColorKom,
                  ),
                ),
              ),
            ),

          ],
        ),
        const SizedBox(
          height: 60,
        ),
              ],
            ));
  }
}

class UserController extends GetxController {
  var uid = ''.obs;

  void setUid(String uid) {
    this.uid.value = uid;
  }
}
