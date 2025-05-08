import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  Future<void> createProduct({
    required String name,
    required String price,
    required String description,
    required bool isFeatured,
  }) async {
    final String imageUrl = "male-daura.jpg";
    await FirebaseFirestore.instance.collection('products').add({
      'name': name,
      'price': price,
      'image': imageUrl,
      'description': description,
      'isFeatured': isFeatured,
    });
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
                createProduct(
                  name: nameController.text,
                  price: priceController.text,
                  description: descriptionController.text,
                  isFeatured: _isChecked,
                );
              },
              child: const Text("Save Product"),
            ),
          ],
        ),
      ),
    );
  }
}
