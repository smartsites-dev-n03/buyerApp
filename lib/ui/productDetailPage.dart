import 'dart:convert';
import 'dart:developer';

import 'package:buyerApp/ui/staticHomepage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:buyerApp/ui/cartPage.dart';

class ProductDetailPage extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String cartId = "";

  List<Map<String, dynamic>> cartItems = [];
  int totalCartItems = 0;

  @override
  void initState() {
    super.initState();
    loadCartItems();
  }

  Future<void> addToCart(Map<String, dynamic> product) async {
    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to purchase')),
      );
      return;
    }
    cartId = DateTime.now().millisecondsSinceEpoch.toString();

    final cartRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .doc(product['id']);

    final existing = await cartRef.get();

    log(existing.data().toString());

    if (existing.exists) {
      final currentQty = existing.data()?['qty'] ?? 1;
      await cartRef.update({'qty': currentQty + 1, 'isCheckout': false});
    } else {
      await cartRef.set({
        'name': product['name'],
        'price': product['price'],
        'image': product['image'],
        'qty': 1,
        'isCheckout': false,
        'isDelivered': false,
        'cartId': cartId,
        'id': product['id'],
      });
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Added to cart!')));

    setState(() {
      loadCartItems();
    });
  }

  Future<void> loadCartItems() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('User not logged in');
    }

    final cartSnapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('cart')
            .get();

    // Extracting the document data
    List<Map<String, dynamic>> cartProducts =
        cartSnapshot.docs.map((doc) {
          return doc.data();
        }).toList();

    setState(() {
      cartItems = cartProducts;
    });

    log(cartItems.toString());
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Top Image with curved background
                Container(
                  height: 350,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.deepPurple, Colors.purpleAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40),
                    ),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return Dialog(
                            insetPadding: const EdgeInsets.all(10),
                            backgroundColor: Colors.transparent,
                            child: InteractiveViewer(
                              panEnabled: true,
                              minScale: 1,
                              maxScale: 4,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image(
                                  image: AssetImage(
                                    "assets/" + product['image'],
                                  ),
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: Center(
                      child: Hero(
                        tag: 'product-image',
                        child: Image(
                          image: AssetImage("assets/" + product['image']),
                          fit: BoxFit.contain,
                          height: 250,
                        ),
                      ),
                    ),
                  ),
                ),

                // Bottom Content
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(20),
                    child: ListView(
                      children: [
                        // Title and Price
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              product['name'],
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            /*Text(
                              "\$" + product['price'],
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700],
                              ),
                            ),*/
                          ],
                        ),

                        SizedBox(height: 10),

                        // Rating
                        Row(
                          children: List.generate(5, (index) {
                            return Icon(
                              Icons.star,
                              color: Colors.orange,
                              size: 20,
                            );
                          }),
                        ),

                        SizedBox(height: 20),

                        // Description
                        Text(
                          product['description'],
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        ),

                        SizedBox(height: 30),

                        // Add to Cart Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              addToCart(product);
                            },
                            icon: Icon(Icons.shopping_cart),
                            label: Text("Add to Cart"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              textStyle: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Floating AppBar with SafeArea
            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                      color: Colors.black,
                    ),
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.grey.shade400,
                    child: Stack(
                      children: [
                        IconButton(
                          icon: Icon(Icons.shopping_cart_outlined),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CartPage(),
                              ),
                            );
                          },
                          color: Colors.black,
                        ),
                        if (cartItems.isNotEmpty)
                          Positioned(
                            right: 4,
                            top: 1,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 20,
                                minHeight: 20,
                              ),
                              child: Text(
                                cartItems.length.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
