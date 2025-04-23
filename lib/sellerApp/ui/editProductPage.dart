import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EditProductPage extends StatefulWidget {
  final Map<String, dynamic> product;
  final int index;

  const EditProductPage({
    super.key,
    required this.product,
    required this.index,
  });

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  File? _imageFile;
  bool approvalController = false;

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(text: widget.product['name']);

    priceController = TextEditingController(
      text: widget.product['price'].toString(),
    );

    descriptionController = TextEditingController(
      text: widget.product['description'],
    );

    approvalController = widget.product['isApproved'];

    if (widget.product['image'] != null) {
      _imageFile = File(widget.product['image']);
    }
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Product")),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child:
                  _imageFile != null
                      ? Image.file(
                        _imageFile!,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      )
                      : const Icon(Icons.image, size: 100),
            ),
            const SizedBox(height: 16),
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
              checkColor: Colors.white,
              value: approvalController,
              onChanged: (bool? value) {
                setState(() {
                  approvalController = value!;
                });
              },
            ),
            const Spacer(),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, {
                  'name': nameController.text,
                  'price': double.tryParse(priceController.text) ?? 0,
                  'image': _imageFile?.path ?? widget.product['image'],
                  'isApproved': widget.product['isApproved'] ?? false,
                });
              },
              child: const Text("Save Changes"),
            ),
          ],
        ),
      ),
    );
  }
}
