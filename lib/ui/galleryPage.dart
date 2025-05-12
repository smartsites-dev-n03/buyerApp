import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../ui/profilePage.dart';
import '../../ui/splash.dart';
import '../sellerApp/ui/homePage.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  List<String> videoIds = [];

  @override
  void initState() {
    super.initState();
    fetchYtbVideos();
  }

  Future<void> fetchYtbVideos() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('youtube_videos').get();

    List<String> ids = [];
    for (var doc in snapshot.docs) {
      final List<dynamic> videoList = doc['videoId'];
      ids.addAll(videoList.map((e) => e.toString()));
    }

    setState(() {
      videoIds = ids;
      //log(videoIds.toString());

      if (videoIds.isNotEmpty) {}
    });
  }

  final _controller = YoutubePlayerController.fromVideoId(
    videoId: 'sivn5BX3Lic',
    autoPlay: false,
    params: const YoutubePlayerParams(showFullscreenButton: true),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Video Gallery",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [IconButton(icon: const Icon(Icons.add), onPressed: () {})],
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          YoutubePlayer(controller: _controller, aspectRatio: 16 / 9),
          SizedBox(height: 10),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
              ),
              itemCount: videoIds.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    _controller.loadVideoById(videoId: videoIds[index]);
                  },
                  child: Container(
                    child: Image.network(
                      "https://img.youtube.com/vi/${videoIds[index]}/hqdefault.jpg",
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
