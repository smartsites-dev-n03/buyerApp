import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/integration/googleLogin.dart';
import 'package:buyerApp/loginPage.dart';
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
  TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> cartItems = [];
  List<Map<String, dynamic>> filteredProducts = [];

  @override
  void initState() {
    super.initState();
    loadCartItems();
    loadProfileImage();
    loadUserProducts();
    filteredProducts = products;
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

  /*List<Map<String, dynamic>> products = [
    {
      'image':
          'https://hukut.com/_next/image?url=https%3A%2F%2Fcdn.hukut.com%2Fiphone-16-pro-max-desert-titanium.webp1728298969978&w=1920&q=75',
      'name': 'iPhone 13 Pro Max',
      'price': 2070.00,
    },
    {
      'image':
          'https://hukut.com/_next/image?url=https%3A%2F%2Fcdn.hukut.com%2FOnePlus-Nord-CE4-Lite-5G-price-in-nepal-2.webp1726996501943&w=1920&q=75',
      'name': 'OnePlus Nord CE4 Lite 5G',
      'price': 299.99,
    },
    {
      'image':
          'https://hukut.com/_next/image?url=https%3A%2F%2Fcdn.hukut.com%2FUltima-Atom-820-Grey.webp&w=1920&q=75',
      'name': 'Ultima Atom 820',
      'price': 18.99,
    },
    {
      'image':
          'https://hukut.com/_next/image?url=https%3A%2F%2Fcdn.hukut.com%2Fgo-pro-hero-13-black-2.png1739871585852&w=1920&q=75',
      'name': 'GoPro HERO 13 Black',
      'price': 664.99,
    },
    {
      'image':
          'https://hukut.com/_next/image?url=https%3A%2F%2Fcdn.hukut.com%2FSamsung%2520Galaxy%2520Tab%2520S9%2520FE%2520Silver%25201.webp&w=1920&q=75',
      'name': 'Samsung Galaxy Tab S9 FE',
      'price': 809.99,
    },
    {
      'image':
          'https://hukut.com/_next/image?url=https%3A%2F%2Fcdn.hukut.com%2FAmazfit%2520GTS%25202%2520Desert%2520Gold.webp&w=1920&q=75',
      'name': 'Amazfit GTS 2 Smartwatch',
      'price': 190.00,
    },
  ];*/

  List<Map<String, dynamic>> blogItems = [
    {'image': 'assets/black-friday.jpg', 'name': 'iPhone 13 Pro Max'},
    {
      'image': 'assets/cyber-monday-banner.jpg',
      'name': 'OnePlus Nord CE4 Lite 5G',
    },
    {'image': 'assets/black-friday-banner.jpg', 'name': 'Ultima Atom 820'},
    {'image': 'assets/cyber-monday.jpg', 'name': 'GoPro HERO 13 Black'},
  ];

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

    /*cart.add(jsonEncode(product));
    await prefs.setStringList('cart', cart);*/

    List<Map<String, dynamic>> cartList =
        cart.map((item) => jsonDecode(item) as Map<String, dynamic>).toList();

    int index = cartList.indexWhere((item) => item['name'] == product['name']);
    log("got index:" + index.toString());
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Added item to cart.")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: true,
        //title: Text("Lukut Store", style: TextStyle(fontWeight: FontWeight.bold),),
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
            /*setState(() {
             filteredProducts = products
                 .where((item) => item['name']
                 .contains(value.toLowerCase()
                 .toString())).toList();
            });*/
            /*setState(() {
              filteredProducts = products
                  .where((item) => item['price'].toString()
                  .contains(value)
              ).toList();
            });*/
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

              /*filteredProducts = products.where((product) {
                final nameMatch = product['name']
                    .toLowerCase()
                    .contains(value.toLowerCase());

                final priceMatch = double.tryParse(value) != null &&
                    product['price'].toString().contains(value);

                return nameMatch || priceMatch;
              }).toList();*/
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
                                : const AssetImage('assets/icon.jpg'),
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
                  Image(
                    image: AssetImage("assets/drawer-image.png"),
                    width: MediaQuery.of(context).size.width / 2,
                    height: 110,
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
                        onAddToCart: () => addCartItems(product),
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
  final VoidCallback onAddToCart;

  const ProductCard({
    super.key,
    required this.image,
    required this.name,
    required this.price,
    required this.onAddToCart,
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
            ElevatedButton(
              onPressed: onAddToCart,
              child: const Text('Add to Cart'),
            ),
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
