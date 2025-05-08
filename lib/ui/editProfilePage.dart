import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final user = FirebaseAuth.instance.currentUser!;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  String? profileImageBase64;
  File? _selectedImage;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        nameController.text = data['name'] ?? '';
        emailController.text = data['email'] ?? user.email!;
        phoneController.text = data['phone'] ?? '';
        profileImageBase64 = data['profileImageBase64'];
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
    setState(() => isLoading = false);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final imageBytes = await picked.readAsBytes();
      setState(() {
        _selectedImage = File(picked.path);
        profileImageBase64 = base64Encode(imageBytes);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      await _firestore.collection('users').doc(user.uid).set({
        'name': nameController.text,
        'email': emailController.text,
        'phone': phoneController.text,
        'profileImageBase64': profileImageBase64,
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile updated')));
      Navigator.pop(context);
    } catch (e) {
      print("Error saving profile: $e");
    }

    setState(() => isLoading = false);
  }

  ImageProvider getProfileImage() {
    if (profileImageBase64 != null) {
      try {
        return MemoryImage(base64Decode(profileImageBase64!));
      } catch (_) {
        return const AssetImage('assets/profile.jpg');
      }
    } else {
      return const AssetImage('assets/profile.jpg');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Profile Image
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: getProfileImage(),
                          ),
                          CircleAvatar(
                            backgroundColor: Colors.blue,
                            radius: 18,
                            child: IconButton(
                              icon: const Icon(
                                Icons.edit,
                                size: 16,
                                color: Colors.white,
                              ),
                              onPressed: _pickImage,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      // Name
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          border: OutlineInputBorder(),
                        ),
                        validator:
                            (val) =>
                                val == null || val.isEmpty
                                    ? 'Enter name'
                                    : null,
                      ),
                      const SizedBox(height: 16),
                      // Email
                      TextFormField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email Address',
                          border: OutlineInputBorder(),
                        ),
                        validator:
                            (val) =>
                                val != null && val.contains('@')
                                    ? null
                                    : 'Enter valid email',
                      ),
                      const SizedBox(height: 16),
                      // Phone
                      TextFormField(
                        controller: phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                          border: OutlineInputBorder(),
                        ),
                        validator:
                            (val) =>
                                val != null && val.length >= 8
                                    ? null
                                    : 'Enter valid phone number',
                      ),
                      const SizedBox(height: 30),
                      // Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: _saveProfile,
                            child: const Text("Save"),
                          ),
                          OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("Cancel"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
