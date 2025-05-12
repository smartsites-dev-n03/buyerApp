import 'dart:convert';
import 'dart:developer';
import 'package:buyerApp/ui/trackOrder.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'editProfilePage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  IconAlignment _iconAlignment = IconAlignment.start;

  Future<DocumentSnapshot> getUserData(String uid) {
    return FirebaseFirestore.instance.collection('users').doc(uid).get();
  }

  Stream<QuerySnapshot> getUserCart(String uid) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('cart')
        .snapshots();
  }

  Stream<QuerySnapshot> getUserOrders(String uid) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('orders')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text("User not logged in")));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile"),
        backgroundColor: Colors.white,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: getUserData(user.uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          final data = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 20.0,
                  ),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.blue,
                            child: Text(
                              data['name'][0].toUpperCase(),
                              style: const TextStyle(
                                fontSize: 40,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['name'],
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  data['email'],
                                  style: TextStyle(color: Colors.grey),
                                ),
                                Text(data['phone'] ?? 'N/A'),

                                Text(data['address'] ?? 'N/A'),
                                Text(data['gender'] ?? 'N/A'),
                              ],
                            ),
                          ),
                          /*IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                ),
                                onPressed: () {},
                              ),*/
                          FilledButton.tonalIcon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditProfilePage(),
                                ),
                              ).then(
                                (_) => setState(() {
                                  getUserData(user.uid);
                                }),
                              );
                            },
                            icon: const Icon(Icons.edit),
                            label: const Text('Edit'),
                            iconAlignment: _iconAlignment,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const Divider(),

                ListTile(
                  leading: const Icon(Icons.phone, color: Colors.blue),
                  title: Text(data['phone'] ?? 'N/A'),
                ),
                ListTile(
                  leading: const Icon(Icons.home, color: Colors.blue),
                  title: Text(data['address'] ?? 'N/A'),
                ),
                ListTile(
                  leading: const Icon(Icons.person, color: Colors.blue),
                  title: Text(data['gender'] ?? 'N/A'),
                ),

                const Divider(thickness: 1, height: 40),

                const Text(
                  "My Cart",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                StreamBuilder(
                  stream: getUserCart(user.uid),
                  builder: (context, cartSnapshot) {
                    if (!cartSnapshot.hasData)
                      return const CircularProgressIndicator();

                    final cartItems =
                        cartSnapshot.data!.docs
                            .where((doc) => (doc.data() as Map)['name'] != "")
                            .toList();

                    if (cartItems.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("No items in cart."),
                      );
                    }

                    return ListView.builder(
                      itemCount: cartItems.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final item = cartItems[index];
                        final itemData = item.data() as Map<String, dynamic>;

                        return GestureDetector(
                          onTap: () {
                            itemData['isCheckout']
                                ? Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => OrderTrackingMap(
                                          orderId:
                                              itemData['orderDetails']['orderId'],
                                        ),
                                  ),
                                )
                                : "";
                          },
                          child: Card(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: ListTile(
                              leading:
                                  itemData['image'] != null &&
                                          itemData['image'] != ""
                                      ? Image(
                                        image: AssetImage(
                                          "assets/" + itemData['image'],
                                        ),
                                        height: 80,
                                      )
                                      : const Icon(Icons.image, size: 60),
                              title: Text(itemData['name']),
                              subtitle: Text(
                                "Qty: ${itemData['qty']} • Rs.${itemData['price']}",
                              ),
                              trailing: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    itemData['isCheckout']
                                        ? "Checked Out"
                                        : "In Cart",
                                    style: TextStyle(
                                      color:
                                          itemData['isCheckout']
                                              ? Colors.blue
                                              : Colors.black,
                                    ),
                                  ),
                                  Text(
                                    itemData['isDelivered']
                                        ? "Delivered"
                                        : "Pending",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color:
                                          itemData['isDelivered']
                                              ? Colors.green
                                              : Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),

                Divider(),

                const Text(
                  "Recent Orders",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                StreamBuilder(
                  stream: getUserOrders(user.uid),
                  builder: (context, orderSnapshot) {
                    if (!orderSnapshot.hasData)
                      return const CircularProgressIndicator();

                    final orderItems =
                        orderSnapshot.data!.docs
                            .where((doc) => (doc.data() as Map)['status'] != '')
                            .toList();

                    if (orderItems.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("No recent orders."),
                      );
                    }

                    return ListView.builder(
                      itemCount: orderItems.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final item = orderItems[index];
                        final itemData = item.data() as Map<String, dynamic>;

                        log(itemData['items'].toString());

                        // Get the first item in the 'items' list
                        final List<dynamic> itemsList = itemData['items'];
                        final firstItem =
                            itemsList.isNotEmpty ? itemsList[0] : null;

                        return GestureDetector(
                          onTap: () {},
                          child: Card(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: ListTile(
                              leading:
                                  firstItem != null &&
                                          firstItem['image'] != null &&
                                          firstItem['image'] != ""
                                      ? Image.asset(
                                        "assets/${firstItem['image']}",
                                        height: 80,
                                      )
                                      : const Icon(Icons.image, size: 60),

                              title: Text(firstItem['name']),
                              trailing: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  /*Text(
                                    itemData['isCheckout']
                                        ? "Checked Out"
                                        : "In Cart",
                                    style: TextStyle(
                                      color:
                                          itemData['isCheckout']
                                              ? Colors.blue
                                              : Colors.black,
                                    ),
                                  ),
                                  Text(
                                    itemData['isDelivered']
                                        ? "Delivered"
                                        : "Pending",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color:
                                          itemData['isDelivered']
                                              ? Colors.green
                                              : Colors.red,
                                    ),
                                  ),*/
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
