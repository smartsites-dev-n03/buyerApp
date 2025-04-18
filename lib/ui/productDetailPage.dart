
import 'dart:convert';
import 'dart:developer';
import 'dart:ffi';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:buyerApp/ui/cartPage.dart';


class ProductDetailPage extends StatefulWidget {
  final Map<String, dynamic> product;
  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetailPage> {

  List<Map<String, dynamic>> cartItems = [];
  @override
  void initState() {
    super.initState();
    loadCartItems();
  }

  Future<void> loadCartItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> cart = prefs.getStringList('cart') ?? [];

    setState(() {
      cartItems =
          cart.map((item) => jsonDecode(item) as Map<String, dynamic>).toList();
    });
  }

  Future<void> addCartItems(Map<String, dynamic> product) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> cart = prefs.getStringList('cart') ?? [];

    List<Map<String, dynamic>> cartList = cart.map((item) => jsonDecode(item) as Map<String, dynamic>).toList();

    int index = cartList.indexWhere((item) => item['name'] == product['name']);
    log("got index:"+index.toString());
    if (index != -1) {
      cartList[index]['qty'] = (cartList[index]['qty'] ?? 1) + 1;
    } else {
      product['qty'] = 1;
      cartList.add(product);
    }
    await prefs.setStringList(
      'cart',
      cartList.map((item) => jsonEncode(item)).toList(),
    );

    loadCartItems();
    // log(cart.toString());
    ScaffoldMessenger.of(context,).showSnackBar(
        const SnackBar(content: Text("Added item to cart."))
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.black),
        title: Text(
          widget.product['name'],
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CartPage()),
                    ).then((_) => loadCartItems());
                  },
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
      body: SingleChildScrollView (
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 250,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    widget.product['image'],
                    height: 350,
                    width: double.infinity,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                widget.product['name'],
                style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              const SizedBox(height: 10),
              Text(
                'Rs.${widget.product['price'].toStringAsFixed(2)}',
                style: const TextStyle(
                    fontSize: 22, color: Colors.green, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              /*Text(
                widget.product['description'],
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.6,
                ),
              ),*/
              const SizedBox(height: 20),
              Center(
                child: SizedBox(
                  width: 150,
                  child: ElevatedButton(
                    onPressed: () {
                      addCartItems(widget.product);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Added to cart!')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      backgroundColor: Colors.black,
                      elevation: 5,
                    ),
                    child: const Text(
                      'Add to Cart',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}