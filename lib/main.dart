import 'package:admin_panel_komp/Login_Page.dart';
import 'package:admin_panel_komp/widgets/colors.dart';
import 'package:admin_panel_komp/sidebar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: ' Admin',
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: backgroundColor,
        canvasColor: secondaryColor,

      ),
      getPages: const [],
      unknownRoute: GetPage(
        name: '/home',
        page: () => FirebaseAuth.instance.currentUser == null
            ? const LoginPage()
            : const HomeMain(),
        binding: BindingsBuilder(() {
          Get.lazyPut(() => UserController());
        }),
      ),
    );
  }
}
