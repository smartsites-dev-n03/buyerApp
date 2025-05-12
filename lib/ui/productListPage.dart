import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:buyerApp/sellerApp/ui/createProduct.dart';
import 'package:buyerApp/ui/galleryPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../ui/productDetailPage.dart';
import '../../ui/profilePage.dart';
import '../../ui/splash.dart';

import 'package:buyerApp/sellerApp/ui/editProductPage.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<ProductListPage> {
  List<Map<String, dynamic>> products = [];

  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future<void> loadProducts() async {
    final allProducts = FirebaseFirestore.instance.collection('products').get();

    log("Products: " + allProducts.toString());
  }

  Future<void> approveProduct(int index) async {
    setState(() {
      products[index]['isApproved'] = true;
    });

    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList(
      "user_products",
      products.map((e) => jsonEncode(e)).toList(),
    );
  }

  Future<void> cancelApproveProduct(int index) async {
    setState(() {
      products[index]['isApproved'] = false;
    });

    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList(
      "user_products",
      products.map((e) => jsonEncode(e)).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // You can filter approved products like this:
    final approvedProducts =
        products.where((p) => p['isApproved'] == true).toList();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "All Products",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_outlined),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const Createproduct()),
              );
              loadProducts();
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Column(
                children: [
                  Text(
                    "Lukut Store",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  ListTile(
                    trailing: Icon(Icons.close),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProfilePage()),
                      );
                    },
                    child: Image(
                      image: AssetImage("assets/drawer-image.png"),
                      width: MediaQuery.of(context).size.width / 2,
                      height: 110,
                    ),
                  ),

                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProfilePage()),
                      );
                    },
                    icon: const Icon(Icons.all_inclusive),
                    label: const Text("My Profile"),
                  ),
                ],
              ),
              Divider(endIndent: 20, indent: 20),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Home'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProductListPage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.category),
                title: const Text('Categories'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // Update the state of the app.
                  // ...
                },
              ),
              ListTile(
                leading: const Icon(Icons.storefront),
                title: const Text('All Products'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // Update the state of the app.
                  // ...
                },
              ),
              ListTile(
                leading: const Icon(Icons.burst_mode),
                title: const Text("Gallery"),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => GalleryPage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.shopping_bag),
                title: const Text("My Orders"),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // Navigate to Orders
                },
              ),
              ListTile(
                leading: const Icon(Icons.favorite_border),
                title: const Text("Wishlist"),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // Navigate to Wishlist
                },
              ),
              ListTile(
                leading: const Icon(Icons.location_on),
                title: const Text("My Addresses"),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // Navigate to Addresses
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text("Settings"),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // Navigate to Settings
                },
              ),
              ListTile(
                leading: const Icon(Icons.help_outline),
                title: const Text("Help & Support"),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // Navigate to Help
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  "Logout",
                  style: TextStyle(color: Colors.red),
                ),

                onTap: () async {
                  SharedPreferences logoutPref =
                      await SharedPreferences.getInstance();
                  logoutPref.clear();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => SplashPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance
                .collection('products')
                //.where('sellerId', isEqualTo: currentUserId)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final product = docs[index].data() as Map<String, dynamic>;
              final isApproved = product['isApproved'] == true;

              return ListTile(
                shape: Border(bottom: BorderSide(color: Colors.black12)),
                leading: Expanded(
                  child:
                      product['image'] != null && product['image'] != ""
                          ? Image(
                            image: AssetImage("assets/" + product['image']),
                            width: 50,
                            height: 100,
                          )
                          : const Icon(Icons.image, size: 80),
                ),
                title: Text(product['name']),
                subtitle: Text("Rs. ${product['price']}"),
                //isThreeLine: true,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isApproved)
                      IconButton(
                        icon: const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                        ),
                        tooltip: "Approve",
                        onPressed: () => approveProduct(index),
                      ),
                    if (isApproved)
                      IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.green),
                        tooltip: "Approve",
                        onPressed: () => cancelApproveProduct(index),
                      ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        //products.removeAt(index);
                        loadProducts();
                      },
                    ),

                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () async {
                        final updatedProduct = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => EditProductPage(
                                  product: products[index],
                                  index: index,
                                ),
                          ),
                        );

                        if (updatedProduct != null) {
                          setState(() {
                            products[index] = updatedProduct;
                          });
                          final prefs = await SharedPreferences.getInstance();
                          prefs.setStringList(
                            "user_products",
                            products.map((e) => jsonEncode(e)).toList(),
                          );
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
