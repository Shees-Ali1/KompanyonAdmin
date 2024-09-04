import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'colors.dart';
import 'custom_buuton.dart';
import 'custom_search.dart';
import 'custom_text.dart';

class UserDetails extends StatefulWidget {
  UserDetails({super.key});

  @override
  State<UserDetails> createState() => _UserDetailsState();
}

class _UserDetailsState extends State<UserDetails> {
  String searchQuery = '';
  late Stream<QuerySnapshot> stream;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _deleteUser(String userId) async {
    bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this user?'),
          actions: [
            CustomButton(
              color: Colors.transparent,
              width: 100,
              height: 40,
              text: 'Cancel',
              textColor: Colors.red,
              onPressed: () => Navigator.of(context).pop(false),
            ),
            CustomButton(
              width: 100,
              height: 40,
              text: 'Delete',
              onPressed: () => Navigator.of(context).pop(true),
            ),

          ],
        );
      },
    );

    if (shouldDelete == true) {
      try {
        await _firestore.collection('userDetails').doc(userId).delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User deleted successfully')),
        );
      } catch (e) {
        print('Error deleting user: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error deleting user')),
        );
      }
    }
  }

  Future<void> _editUser(String userId, String currentName, String currentEmail,
      String currentRole) async {
    String? updatedName = currentName;
    String? updatedEmail = currentEmail;
    String selectedRole = currentRole;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: backgroundColor,
          title: const Text('Edit User'),
          content: SizedBox(
            height: 200,
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InputField(
                  onChanged: (value) {
                    updatedName = value;
                  },
                  hint: 'Email',
                  keyboard: TextInputType.text,
                  controller: TextEditingController(text: currentName),
                ),
                SizedBox(
                  height: 20,
                ),
                InputField(
                  onChanged: (value) {
                    updatedEmail = value;
                  },
                  hint: 'Email',
                  keyboard: TextInputType.text,
                  controller: TextEditingController(text: currentEmail),
                ),
                SizedBox(
                  height: 20,
                ),
                DropdownButtonFormField<String>(
                  dropdownColor: backgroundColor,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 12.0,
                      horizontal: 10.0,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: primaryColorKom),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(color: primaryColorKom),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: primaryColorKom),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  hint: AsulCustomText(
                    text: '[role]',
                  ),
                  value: selectedRole,
                  onChanged: (String? newValue) {
                    selectedRole = newValue ?? currentRole;
                  },
                  items: <String>['Admin', 'User', 'Guest']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: AsulCustomText(text: value),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            CustomButton(
              color: Colors.transparent,
              width: 100,
              height: 40,
              text: 'Cancel',
              textColor: Colors.red,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            CustomButton(
              width: 100,
              height: 40,
              text: 'Update',
              onPressed: () async {
                await _firestore.collection('userDetails').doc(userId).update({
                  'name': updatedName,
                  'email': updatedEmail,
                  'role': selectedRole,
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User updated successfully')),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    stream = _firestore.collection('userDetails').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 100, vertical: 20),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    searchQuery =
                        value.toLowerCase(); // Ensure case-insensitive search
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontSize: 16.0,
                  ),
                  fillColor: Colors.white,
                  filled: true,
                  border: const OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: secondaryColor,
                    size: 26,
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(width: 100),
                  Expanded(
                    child: AsulCustomText(
                      text: 'Name',
                      fontsize: 18,
                      fontWeight: FontWeight.w600,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: AsulCustomText(
                      text: 'Email',
                      fontsize: 18,
                      fontWeight: FontWeight.w600,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: AsulCustomText(
                      text: 'Role',
                      fontsize: 18,
                      fontWeight: FontWeight.w600,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(width: 150),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: stream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Text('Error fetching users');
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final users = snapshot.data!.docs.where((user) {
                    final name = (user['name'] ?? '').toString().toLowerCase();
                    return name.contains(searchQuery);
                  }).toList();

                  if (users.isEmpty) {
                    return const Center(
                      child: Text('No users found'),
                    );
                  }

                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      return Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              const SizedBox(width: 30),
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: user['profileImageUrl'] != null
                                      ? Colors.transparent
                                      : Colors.red,
                                ),
                                child: user['profileImageUrl'] != null
                                    ? CircleAvatar(
                                        backgroundImage: NetworkImage(
                                            user['profileImageUrl']),
                                      )
                                    : const Icon(Icons.person,
                                        color: Colors.white),
                              ),
                              Expanded(
                                child: AsulCustomText(
                                  text: user['name']?.isNotEmpty == true
                                      ? user['name']
                                      : user['name'] ?? '',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Expanded(
                                  child: AsulCustomText(
                                text: user['email'] ?? '',
                                textAlign: TextAlign.center,
                              )),
                              Expanded(
                                  child: AsulCustomText(
                                      text: user['role'] ?? '',
                                      textAlign: TextAlign.center)),
                              IconButton(
                                onPressed: () {
                                  _editUser(
                                    user['uid'],
                                    user['name'] ?? '',
                                    user['email'] ?? '',
                                    user['role'] ?? '',
                                  );
                                },
                                icon: const Icon(Icons.edit),
                                color: primaryColorKom,
                              ),
                              IconButton(
                                onPressed: () {
                                  _deleteUser(user.id);
                                },
                                icon: const Icon(Icons.delete),
                                color: Colors.red,
                              ),
                              const SizedBox(width: 80),
                            ],
                          ),
                          const Divider(),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
