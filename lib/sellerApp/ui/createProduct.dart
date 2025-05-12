import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Createproduct extends StatefulWidget {
  const Createproduct({super.key});

  @override
  State<Createproduct> createState() => _CreateproductState();
}

class _CreateproductState extends State<Createproduct> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  bool _isChecked = false;
  String productId = DateTime.now().millisecondsSinceEpoch.toString();

  String generateProductId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  Future<void> createProduct() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('User not logged in');
    }

    final name = nameController.text.trim();
    final price = double.tryParse(priceController.text) ?? 0.0;
    final description = descriptionController.text.trim();
    bool isFeatured = _isChecked;

    if (name.isEmpty || price == 0.0 || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields properly")),
      );
      return;
    } else {
      final String imageUrl = "male-daura.jpg";
      await FirebaseFirestore.instance.collection('products').add({
        'name': name,
        'price': price,
        'image': imageUrl,
        'description': description,
        'isFeatured': isFeatured,
        'id': generateProductId(),
        'sellerId': user.uid,
      });

      nameController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create New Product")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Product Name"),
            ),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Price"),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: "Description"),
            ),
            Checkbox(
              activeColor: Color(0xff2196f3),
              checkColor: Color(0xffffffff),
              value: _isChecked,
              onChanged: (bool? value) {
                // log(value.toString());
                setState(() {
                  _isChecked = value!;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                createProduct();
              },
              child: const Text("Save Product"),
            ),
          ],
        ),
      ),
    );
  }
}
