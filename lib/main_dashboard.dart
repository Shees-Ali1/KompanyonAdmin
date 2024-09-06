import 'package:admin_panel_komp/assessments.dart';
import 'package:admin_panel_komp/colors.dart';
import 'package:admin_panel_komp/header.dart';
import 'package:admin_panel_komp/read.dart';
import 'package:admin_panel_komp/responses.dart';
import 'package:admin_panel_komp/user_details.dart';
import 'package:flutter/material.dart';

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.all(15.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(
                height: 25,
              ),
              const Header(),
              const SizedBox(
                height: 20,
              ),
              Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0, top: 10),
                        child: Column(
                          children: [

                            SizedBox(
                              width: 200,
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _selectedIndex = 0;
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: _selectedIndex == 0
                                        ?primaryColorKom
                                        :  primaryColorKom.withOpacity(0.1),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12))),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10.0),
                                  child: Text('Users Data',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 20)),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            SizedBox(
                              width: 200,
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _selectedIndex = 1;
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: _selectedIndex == 1
                                        ? primaryColorKom
                                        :  primaryColorKom.withOpacity(0.1),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12))),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10.0),
                                  child: Text('Assessments',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 20)),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            SizedBox(
                              width: 200,
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _selectedIndex = 2;
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: _selectedIndex == 2
                                        ?primaryColorKom
                                        :  primaryColorKom.withOpacity(0.1),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(12))),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10.0),
                                  child: Text('Read',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 20)),
                                ),
                              ),
                            ),
                            const SizedBox(height: 15,),
                            SizedBox(
                              width: 200,
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _selectedIndex = 3;
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: _selectedIndex == 3
                                        ?primaryColorKom
                                        :  primaryColorKom.withOpacity(0.1),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(12))),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10.0),
                                  child: Text('Responses',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w400,
                                          fontSize: 20)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 15,
                      ),

                      if (_selectedIndex == 0)
                        Column(
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height,
                              width: MediaQuery.of(context).size.width / 1.3,
                              child:  UserDetails(),
                            ),
                          ],
                        ),
                      if (_selectedIndex == 1)
                        Column(
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height,
                              width: MediaQuery.of(context).size.width / 1.3,
                              child: const Assessments(),
                            ),
                          ],
                        ),
                      if (_selectedIndex == 2)
                        Column(
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height,
                              width: MediaQuery.of(context).size.width / 1.3,
                              child: const Read(),
                            ),
                          ],
                        ),
                      if (_selectedIndex == 3)
                        Column(
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height,
                              width: MediaQuery.of(context).size.width / 1.3,
                              child:  Responses(),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ])),
      ),
    );
  }
}
