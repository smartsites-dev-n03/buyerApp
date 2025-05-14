import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:buyerApp/sellerApp/ui/createProduct.dart';
import 'package:buyerApp/ui/galleryPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../ui/productDetailPage.dart';
import '../../ui/productListPage.dart';
import '../../ui/profilePage.dart';
import '../../ui/splash.dart';
import 'addProductPage.dart';
import 'editProductPage.dart';
import 'package:http/http.dart' as http;
import '../model/itemModel.dart';

class SellerHomePage extends StatefulWidget {
  const SellerHomePage({super.key});

  @override
  State<SellerHomePage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<SellerHomePage> {
  List<Map<String, dynamic>> products = [];

  BarrelStock? selectedStock;

  //final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    //loadProducts();
    fetchStockData();
  }

  Future<List<BarrelStock>> fetchStockData() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    final response = await http.get(
      Uri.parse(
        'https://api-barrel.sooritechnology.com.np/api/v1/barrel-app/barrel-stock-analysis?offset=0&limit=20&ordering=-id',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${preferences.getString("accessToken")}',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final parsed = BarrelStockAnalysisResponse.fromJson(jsonData);
      return parsed.results;
    } else {
      throw Exception("Failed to fetch data");
    }
  }

  Future<void> loadProducts() async {
    final allProducts = FirebaseFirestore.instance.collection('products').get();

    setState(() {
      //products =
    });
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
          "Lukut Store Seller",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_outlined),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddProductPage()),
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
                    MaterialPageRoute(builder: (context) => SellerHomePage()),
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProductListPage()),
                  );
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FutureBuilder<List<BarrelStock>>(
              future: fetchStockData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}");
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Text("No data found");
                }

                final stockList = snapshot.data!;

                return DropdownButtonFormField<BarrelStock>(
                  value: selectedStock,
                  hint: Text("Select Item"),
                  items:
                      stockList.map((stock) {
                        return DropdownMenuItem(
                          value: stock,
                          child: Text(stock.item.name),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedStock = value;
                    });
                    print(
                      "Selected: ${value!.item.name}, Batch: ${value.batchNo}, Qty: ${value.quantity}",
                    );
                  },
                );
              },
            ),
          ),

          /*StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance
                    .collection('products')
                    .where('sellerId', isEqualTo: currentUserId)
                    .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(child: Text('Something went wrong'));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final docs = snapshot.data!.docs;

              return SizedBox(
                height: 200,
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final product = docs[index].data() as Map<String, dynamic>;
                    final isApproved = product['isApproved'] == true;

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      color: isApproved ? Colors.white : Colors.yellow[100],
                      child: ListTile(
                        leading: Expanded(
                          child:
                              product['image'] != null && product['image'] != ""
                                  ? Image(
                                    image: AssetImage(
                                      "assets/" + product['image'],
                                    ),
                                    width: 50,
                                    height: 100,
                                  )
                                  : const Icon(Icons.image, size: 80),
                        ),
                        title: Text(product['name']),
                        subtitle: Text("Rs. ${product['price']}"),
                        isThreeLine: true,
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
                                icon: const Icon(
                                  Icons.cancel,
                                  color: Colors.green,
                                ),
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
                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  prefs.setStringList(
                                    "user_products",
                                    products.map((e) => jsonEncode(e)).toList(),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),*/
          SizedBox(height: 5),

          Text(
            "Featured Products",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Container(
            height: 200,
            width: 400,
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('products').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Something went wrong'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                return GridView.builder(
                  padding: const EdgeInsets.all(10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ProductDetailPage(product: data),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            /*Expanded(
                                  child:
                                      data['image'] != null &&
                                              data['image'] != ""
                                          ? Image.memory(
                                            base64Decode(data['image']),
                                            fit: BoxFit.cover,
                                          )
                                          : const Icon(Icons.image, size: 80),
                                ),*/
                            /*Expanded(
                              child:
                                  data['image'] != null && data['image'] != ""
                                      ? Image(
                                        image: AssetImage(
                                          "assets/" + data['image'],
                                        ),
                                        width:
                                            MediaQuery.of(context).size.width /
                                            2,
                                        height: 110,
                                      )
                                      : const Icon(Icons.image, size: 80),
                            ),*/
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data['name'] ?? "No Name",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text("Price: Rs .${data['price'] ?? 'N/A'}"),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
