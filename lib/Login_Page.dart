import 'package:admin_panel_komp/colors.dart';
import 'package:admin_panel_komp/custom_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'Main_Dashboard.dart';

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

  void login() async {
    try {
      // Sign in with email and password
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
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
        Get.offAll(() => MainDashboard()); // Navigate to MainDashboard
      } else {
        await FirebaseAuth.instance.signOut();

        print("User is not an admin");
        Get.snackbar("Access Denied", "You do not have admin privileges.");
      }
    } catch (e) {
      print("Login Error: $e"); // Print the error to the terminal
      Get.snackbar("Login Error", e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.all(22.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
              width: 140,
              height: 130,
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
            width: MediaQuery.of(context).size.width * 0.3,
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
              width: MediaQuery.of(context).size.width * 0.3,
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
                      isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
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
            height: 5,
          ),
          const SizedBox(
            height: 30,
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const  AsulCustomText(
                  fontWeight: FontWeight.w700,
                  fontsize: 20,
                  text: 'Login',
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
                  child: IconButton(
                    onPressed: login,
                    icon: Transform.scale(
                      scale: 0.5,
                      child: Image.asset('assets/images/arrowIcon.png',color: primaryColorKom,),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 60,
          ),
        ],
      ),
    ));
  }
}

class UserController extends GetxController {
  var uid = ''.obs;

  void setUid(String uid) {
    this.uid.value = uid;
  }
}
