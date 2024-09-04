import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'colors.dart';

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

  Future<void> _addUser() async {
    // Validate input fields
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter all fields')),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      final uid = userCredential.user?.uid;
      if (uid != null) {
        await _firestore.collection('userDetails').doc(uid).set({
          'name': _nameController.text,
          'email': _emailController.text,
          'password': _passwordController.text,
          'uid': uid,
          'role': _roleController.text,
        });

        _nameController.clear();
        _emailController.clear();
        _passwordController.clear();
        _confirmPasswordController.clear();
        _roleController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User added successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error creating user')),
        );
      }
    } catch (e) {
      print('Error adding user: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error adding user')),
      );
    }
  }

  Future<void> _deleteUser(String userId) async {
    bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this user?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
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
    String updatedName = currentName;
    String updatedEmail = currentEmail;
    String selectedRole = currentRole;

    await showDialog(

      context: context,
      builder: (context) {
        return AlertDialog(

          backgroundColor: secondaryColor,
          title: const Text('Edit User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: TextEditingController(text: currentName),
                onChanged: (value) {
                  updatedName = value;
                },
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              SizedBox(
                height: 20,
              ),
              TextField(
                controller: TextEditingController(text: currentEmail),
                onChanged: (value) {
                  updatedEmail = value;
                },
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              SizedBox(
                height: 20,
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  // fillColor: Colors.white,
                  // /filled: true,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 10.0,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: secondaryColor),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: secondaryColor),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: secondaryColor),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                hint: Text(
                  '[role]',
                  style: TextStyle(color: primaryColor),
                ),
                value: selectedRole,
                onChanged: (String? newValue) {
                  selectedRole = newValue ?? currentRole;
                },
                items: <String>['Admin', 'User', 'Guest']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
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
              child: const Text('Update'),
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
    stream =_firestore.collection('userDetails').snapshots();

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
                  hintText: "Search",
                  fillColor: secondaryColor,
                  filled: true,
                  border: const OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  suffixIcon: Container(
                    padding: const EdgeInsets.all(defaultPadding * 0.75),
                    margin: const EdgeInsets.symmetric(
                        horizontal: defaultPadding / 2),
                    decoration: const BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    child: const Icon(
                      Icons.search,
                      color: Colors.white,
                    ),
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
                    child: Text(
                      'Name',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.blue),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Email',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.blue),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Role',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.blue),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(width: 150),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:stream,
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
                                child: Text(
                                  user['name']?.isNotEmpty == true
                                      ? user['name']
                                      : user['name'] ?? '',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Expanded(
                                  child: Text(user['email'] ?? '',
                                      textAlign: TextAlign.center)),
                              Expanded(
                                  child: Text(user['role'] ?? '',
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
                                color: Colors.blue,
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
