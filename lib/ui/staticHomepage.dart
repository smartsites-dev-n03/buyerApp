import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:buyerApp/ui/profilePage.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:buyerApp/ui/cartPage.dart';
import 'package:buyerApp/ui/productDetailPage.dart';
import 'package:buyerApp/ui/splash.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String cartId = "";
  TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> cartItems = [];
  List<Map<String, dynamic>> filteredProducts = [];

  List<String> carouselItems = [];

  @override
  void initState() {
    super.initState();
    loadProfileImage();
    loadUserProducts();
    filteredProducts = products;
    fetchCarouselItems();
    loadCartItems();
  }

  String? _imagePath;

  Future<void> _startScanning() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.9,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              child: ScannerView(
                onBarcodeDetected: (String barcode) async {
                  log(barcode);
                  setState(() {
                    _searchController = TextEditingController(text: barcode);
                    filteredProducts =
                        products.where((product) {
                          final nameMatch = product['name']
                              .toLowerCase()
                              .contains(barcode.toLowerCase());
                          final priceMatch =
                              double.tryParse(barcode) != null &&
                              product['price'].toString().contains(barcode);
                          return nameMatch || priceMatch;
                        }).toList();
                  });
                  if (filteredProducts.isEmpty) {
                    Fluttertoast.showToast(
                      msg: "No Product Found with this name",
                    );
                  }
                  Navigator.pop(context);
                },
              ),
            ),
          ),
    );
  }

  Future<void> loadUserProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final userProductStrings = prefs.getStringList("user_products") ?? [];

    final userProductMaps =
        userProductStrings
            .map((json) => jsonDecode(json) as Map<String, dynamic>)
            .where((product) => product['isApproved'] == true)
            .toList();

    setState(() {
      products.clear();
      products.addAll(userProductMaps);
      filteredProducts = products;
    });
  }

  Future<void> loadProfileImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _imagePath = prefs.getString('profile_image');
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? pickedFile = await showModalBottomSheet<XFile?>(
      context: context,
      builder:
          (_) => BottomSheet(
            onClosing: () {},
            builder:
                (_) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.camera),
                      title: const Text("Take Photo"),
                      onTap: () async {
                        final photo = await picker.pickImage(
                          source: ImageSource.camera,
                        );
                        Navigator.pop(context, photo);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.photo_library),
                      title: const Text("Choose from Gallery"),
                      onTap: () async {
                        final gallery = await picker.pickImage(
                          source: ImageSource.gallery,
                        );
                        Navigator.pop(context, gallery);
                      },
                    ),
                  ],
                ),
          ),
    );

    if (pickedFile != null) {
      final directory = await getApplicationDocumentsDirectory();
      final savedImage = await File(
        pickedFile.path,
      ).copy('${directory.path}/${DateTime.now().millisecondsSinceEpoch}.png');

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_image', savedImage.path);

      setState(() {
        _imagePath = savedImage.path;
      });
    }
  }

  Future<void> fetchCarouselItems() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('homepage_carousel').get();
    List<String> ids = [];
    for (var doc in snapshot.docs) {
      final List<dynamic> imageUrl = doc['image_url'];
      ids.addAll(imageUrl.map((e) => e.toString()));
    }
    setState(() {
      carouselItems = ids;
      //log(carouselItems.toString());
    });
  }

  final List<String> banners = [
    'assets/black-friday.jpg',
    'assets/cyber-monday-banner.jpg',
    'assets/cyber-monday.jpg',
    'assets/black-friday-banner.jpg',
  ];

  final List<Map<String, dynamic>> categories = [
    {
      'icon': Icons.speaker_group_sharp,
      'name': 'Speakers',
      'link': 'speakers',
      'count': '50',
    },
    {
      'icon': Icons.punch_clock,
      'name': 'Smartwatches',
      'link': 'smartwatches',
      'count': '22',
    },
    {
      'icon': Icons.smartphone,
      'name': 'Phones',
      'link': 'phones',
      'count': '33',
    },
    {'icon': Icons.tablet, 'name': 'Tablets', 'link': 'tablets', 'count': '27'},
    {'icon': Icons.laptop, 'name': 'Laptops', 'link': 'laptops', 'count': '53'},
    {
      'icon': Icons.desktop_mac,
      'name': 'Desktops',
      'link': 'desktops',
      'count': '20',
    },
    {
      'icon': Icons.circle,
      'name': 'Accessories',
      'link': 'accessories',
      'count': '102',
    },
  ];

  final List<Map<String, dynamic>> products = [];

  List<Map<String, dynamic>> blogItems = [
    {'image': 'assets/black-friday.jpg', 'name': 'iPhone 13 Pro Max'},
    {
      'image': 'assets/cyber-monday-banner.jpg',
      'name': 'OnePlus Nord CE4 Lite 5G',
    },
    {'image': 'assets/black-friday-banner.jpg', 'name': 'Ultima Atom 820'},
    {'image': 'assets/cyber-monday.jpg', 'name': 'GoPro HERO 13 Black'},
  ];

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
        .doc(cartId);

    final existing = await cartRef.get();

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
      });
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Added to cart!')));
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
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: true,
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: "Search Products..",
            hintStyle: TextStyle(color: Colors.blue.shade500),
            suffixIcon: GestureDetector(
              onTap: () {
                _startScanning();
              },
              child: Icon(Icons.remove_red_eye),
            ),
          ),
          style: TextStyle(color: Colors.blue),
          onChanged: (value) {
            setState(() {
              filteredProducts =
                  products
                      .where(
                        (item) =>
                            (item['name'].toString() + item['price'].toString())
                                .toLowerCase()
                                .contains(value.toLowerCase()),
                      )
                      .toList();
            });
          },
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
                    );
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
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(color: Colors.teal),
                child: Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage:
                            _imagePath != null
                                ? FileImage(File(_imagePath!))
                                : const AssetImage('assets/drawer-image.jpg'),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey),
                            ),
                            padding: const EdgeInsets.all(4),
                            child: const Icon(Icons.camera_alt, size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Column(
                children: [
                  Text(
                    "Lukut Store",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
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
                ],
              ),
              Divider(endIndent: 20, indent: 20),
              ListTile(
                title: const Text('Home'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                },
              ),
              ListTile(
                title: const Text('Categories'),
                onTap: () {
                  // Update the state of the app.
                  // ...
                },
              ),
              ListTile(
                title: const Text('All Products'),
                onTap: () {
                  // Update the state of the app.
                  // ...
                },
              ),
              ListTile(
                title: const Text('Close'),
                leading: Icon(Icons.close),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Logout'),
                leading: Icon(Icons.logout),
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CarouselSlider(
                options: CarouselOptions(
                  height: 130,
                  enlargeCenterPage: false,
                  autoPlay: true,
                  aspectRatio: 16 / 9,
                  viewportFraction: 0.8,
                ),
                items:
                    banners.map((imageUrl) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                            image: AssetImage(imageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    }).toList(),
              ),
              Divider(endIndent: 20, indent: 20),

              Text(
                "Firebase Carousel",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              CarouselSlider(
                options: CarouselOptions(
                  height: 130,
                  enlargeCenterPage: false,
                  autoPlay: true,
                  aspectRatio: 16 / 9,
                  viewportFraction: 0.8,
                ),
                items:
                    carouselItems.map((imageUrl) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(0),
                          image: DecorationImage(
                            image: NetworkImage(imageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    }).toList(),
              ),
              SizedBox(height: 20),
              Divider(endIndent: 20, indent: 20),

              Text(
                "Categories",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                height: 110, // Adjust height based on content
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    return CategoryCard(
                      icon: categories[index]['icon'],
                      name: categories[index]['name'],
                      count: categories[index]['count'],
                    );
                  },
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Featured Products",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Container(
                height: 500,
                width: 400,
                child: StreamBuilder<QuerySnapshot>(
                  stream:
                      FirebaseFirestore.instance
                          .collection('products')
                          .snapshots(),
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
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
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
                                    (context) =>
                                        ProductDetailPage(product: data),
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
                                Expanded(
                                  child:
                                      data['image'] != null &&
                                              data['image'] != ""
                                          ? Image(
                                            image: AssetImage(
                                              "assets/" + data['image'],
                                            ),
                                            width:
                                                MediaQuery.of(
                                                  context,
                                                ).size.width /
                                                2,
                                            height: 110,
                                          )
                                          : const Icon(Icons.image, size: 80),
                                ),

                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        data['name'] ?? "No Name",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        "Price: Rs .${data['price'] ?? 'N/A'}",
                                      ),
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

              Text(
                "Featured Products",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),

              SizedBox(
                height: 250, // Adjust height based on content
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    ProductDetailPage(product: product),
                          ),
                        ).then((_) => loadCartItems());
                      },
                      child: ProductCard(
                        image: product['image'],
                        name: product['name'],
                        price: product['price'],
                        //onAddToCart: () => addCartItems(product),
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: 20),

              Text(
                "Recent Blog Posts",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                height: 200, // Adjust height based on content
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: blogItems.length,
                  itemBuilder: (context, index) {
                    final blog = blogItems[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ProductDetailPage(product: blog),
                          ),
                        ).then((_) => loadCartItems());
                      },
                      child: RecentBlogCard(
                        image: blog['image'],
                        title: blog['name'],
                        onReadMore: () => ProductDetailPage(product: blog),
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final String image, name;
  final double price;

  //final VoidCallback onAddToCart;

  const ProductCard({
    super.key,
    required this.image,
    required this.name,
    required this.price,
    //required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // onTap: (){
      //     Navigator.push(context, MaterialPageRoute(builder: (context)=>ProductDetailPage(name, image, price)));
      // },
      child: Container(
        width: 150, // Adjust width
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 2),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(image, height: 80, width: 80, fit: BoxFit.cover),
            const SizedBox(height: 8),
            Text(
              name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '₹${price.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 14, color: Colors.green),
            ),
            const SizedBox(height: 8),
            /*ElevatedButton(
              onPressed: onAddToCart,
              child: const Text('Add to Cart'),
            ),*/
          ],
        ),
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final IconData icon;
  final String name, count;

  const CategoryCard({
    super.key,
    required this.icon,
    required this.name,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Fluttertoast.showToast(
          msg: "Category: $name",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.blue,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      },
      child: Container(
        width: 100, // Adjust width
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(color: Colors.grey, blurRadius: 5, spreadRadius: 1),
          ],
          color: Colors.white,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.black26),
            // Display the icon above text
            const SizedBox(height: 5),
            Text(
              name,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              count + ' items',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RecentBlogCard extends StatelessWidget {
  final String image, title;
  final VoidCallback onReadMore;

  const RecentBlogCard({
    super.key,
    required this.image,
    required this.title,
    required this.onReadMore,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        width: MediaQuery.of(context).size.width / 2.2, // Adjust width
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 2),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Image.asset(image),
            SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.left,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: onReadMore,
              child: const Text('Read More'),
            ),
          ],
        ),
      ),
    );
  }
}

class ScannerView extends StatefulWidget {
  final Function(String) onBarcodeDetected;

  const ScannerView({Key? key, required this.onBarcodeDetected})
    : super(key: key);

  @override
  State<ScannerView> createState() => _ScannerViewState();
}

class _ScannerViewState extends State<ScannerView>
    with SingleTickerProviderStateMixin {
  final MobileScannerController controller = MobileScannerController();
  bool _isProcessing = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Scanner
            MobileScanner(
              controller: controller,
              onDetect: (capture) {
                if (_isProcessing) return;
                final List<Barcode> barcodes = capture.barcodes;
                if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
                  setState(() => _isProcessing = true);
                  widget.onBarcodeDetected(barcodes.first.rawValue!);
                }
              },
            ),

            // Overlay
            Container(
              decoration: ShapeDecoration(
                shape: ScannerOverlayShape(
                  borderColor: Colors.white,
                  borderRadius: 12,
                  borderLength: 32,
                  borderWidth: 3,
                  cutOutSize: 250,
                ),
              ),
            ),

            // Animated Scanner Line
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return CustomPaint(
                    painter: ScannerLinePainter(
                      progress: _animation.value,
                      color: Theme.of(context).primaryColor.withOpacity(0.5),
                    ),
                  );
                },
              ),
            ),

            // Top Bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.black.withOpacity(0.3),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    // ValueListenableBuilder(
                    //   valueListenable: controller.torchState,
                    //   builder: (context, state, child) {
                    //     return IconButton(
                    //       icon: Icon(
                    //         state == TorchState.off ? Icons.flash_off : Icons.flash_on,
                    //         color: Colors.white,
                    //       ),
                    //       onPressed: () => controller.toggleTorch(),
                    //     );
                    //   },
                    // ),
                  ],
                ),
              ),
            ),

            // Bottom Instructions
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Align barcode within frame',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Scanner will detect automatically',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    controller.dispose();
    super.dispose();
  }
}

class ScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;

  const ScannerOverlayShape({
    this.borderColor = Colors.white,
    this.borderWidth = 3.0,
    this.overlayColor = const Color(0x80000000),
    this.borderRadius = 12.0,
    this.borderLength = 32.0,
    this.cutOutSize = 250.0,
  });

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Path _getLeftTopPath(Rect rect) {
      return Path()
        ..moveTo(rect.left, rect.bottom)
        ..lineTo(rect.left, rect.top)
        ..lineTo(rect.right, rect.top);
    }

    return _getLeftTopPath(rect);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final height = rect.height;
    final cutOutWidth = cutOutSize;
    final cutOutHeight = cutOutSize;
    final left = rect.left + (width - cutOutWidth) / 2;
    final top = rect.top + (height - cutOutHeight) / 3;
    final right = left + cutOutWidth;
    final bottom = top + cutOutHeight;

    final cutOutRect = Rect.fromLTRB(left, top, right, bottom);
    final backgroundPaint = Paint()..color = overlayColor;
    final borderPaint =
        Paint()
          ..color = borderColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = borderWidth;

    final path =
        Path()
          ..fillType = PathFillType.evenOdd
          ..addRect(rect)
          ..addRRect(
            RRect.fromRectAndRadius(cutOutRect, Radius.circular(borderRadius)),
          );

    canvas.drawPath(path, backgroundPaint);

    // Draw corners
    final borderOffset = borderWidth / 2;
    final cornerStart = borderLength;

    // Top left corner
    canvas.drawLine(
      Offset(left - borderOffset, top + cornerStart),
      Offset(left - borderOffset, top - borderOffset),
      borderPaint,
    );
    canvas.drawLine(
      Offset(left - borderOffset, top - borderOffset),
      Offset(left + cornerStart, top - borderOffset),
      borderPaint,
    );

    // Top right corner
    canvas.drawLine(
      Offset(right - cornerStart, top - borderOffset),
      Offset(right + borderOffset, top - borderOffset),
      borderPaint,
    );
    canvas.drawLine(
      Offset(right + borderOffset, top - borderOffset),
      Offset(right + borderOffset, top + cornerStart),
      borderPaint,
    );

    // Bottom right corner
    canvas.drawLine(
      Offset(right + borderOffset, bottom - cornerStart),
      Offset(right + borderOffset, bottom + borderOffset),
      borderPaint,
    );
    canvas.drawLine(
      Offset(right + borderOffset, bottom + borderOffset),
      Offset(right - cornerStart, bottom + borderOffset),
      borderPaint,
    );

    // Bottom left corner
    canvas.drawLine(
      Offset(left + cornerStart, bottom + borderOffset),
      Offset(left - borderOffset, bottom + borderOffset),
      borderPaint,
    );
    canvas.drawLine(
      Offset(left - borderOffset, bottom + borderOffset),
      Offset(left - borderOffset, bottom - cornerStart),
      borderPaint,
    );
  }

  @override
  ShapeBorder scale(double t) {
    return ScannerOverlayShape(
      borderColor: borderColor,
      borderWidth: borderWidth * t,
      overlayColor: overlayColor,
    );
  }
}

class ScannerLinePainter extends CustomPainter {
  final double progress;
  final Color color;

  ScannerLinePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = 3.0;

    final scanLineY = size.height * 0.3 + (size.height * 0.4 * progress);
    canvas.drawLine(
      Offset(size.width * 0.2, scanLineY),
      Offset(size.width * 0.8, scanLineY),
      paint,
    );
  }

  @override
  bool shouldRepaint(ScannerLinePainter oldDelegate) => true;
}
