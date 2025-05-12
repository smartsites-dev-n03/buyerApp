import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ui/galleryPage.dart';
import '../ui/profilePage.dart';
import '../ui/splash.dart';

import 'package:buyerApp/ui/productListPage.dart';

class AppConst {
  /*Drawer ecomDrawer = Drawer(
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
            title: const Text("Logout", style: TextStyle(color: Colors.red)),

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
  );*/

  //static BuildContext get context => null;
}
