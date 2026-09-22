import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// ===================== MODEL =====================
class Product {
  String name;
  String desc;
  String img;
  int price;
  int quantity;
  int likes;
  bool isLiked;
  bool isSelected;

  Product({
    required this.name,
    required this.desc,
    required this.img,
    required this.price,
    required this.likes,
    this.quantity = 1,
    this.isLiked = false,
    this.isSelected = false,
  });
}

// MyApp cuma bungkus MaterialApp (StatelessWidget).
// State-nya ada di CartPage supaya SnackBar (long press) bisa jalan.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const CartPage(),
    );
  }
}

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  // ===================== STATE =====================
  int selectedNav = 0;

  List<Product> products = [
    Product(
      name: 'Wireless Headphone',
      desc: 'Sony WH-CH520',
      img: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=300',
      price: 350000,
      likes: 12,
    ),
    Product(
      name: 'Laptop ASUS Vivobook',
      desc: 'ASUS',
      img:
      'https://id.store.asus.com/media/catalog/product/v/i/vivobook_14_x1404vap_product_photo_1s_cool_silver_05_numberpad_non-backlit_1.png',
      price: 7500000,
      likes: 8,
    ),
    Product(
      name: 'Wireless Mouse',
      desc: 'Logitech M330',
      img: 'https://rexus.id/cdn/shop/files/Q35_2_1.jpg?v=1763104504',
      price: 250000,
      likes: 5,
    ),
  ];

  // ===================== HITUNG TOTAL =====================
  int get totalItems {
    int total = 0;
    for (var p in products) {
      total += p.quantity;
    }
    return total;
  }

  int get totalPrice {
    int total = 0;
    for (var p in products) {
      total += p.price * p.quantity;
    }
    return total;
  }

  // 7500000 -> "Rp 7.500.000"
  String formatRupiah(int value) {
    String angka = value.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => '.',
    );
    return 'Rp $angka';
  }

  // ===================== AKSI PENGGUNA =====================
  // TAP -> pilih / batal pilih produk
  void selectProduct(Product item) {
    setState(() {
      item.isSelected = !item.isSelected;
    });
  }

  // DOUBLE TAP -> like +1 (hanya kalau belum di-like)
  void likeProduct(Product item) {
    if (item.isLiked) return;
    setState(() {
      item.isLiked = true;
      item.likes++;
    });
  }

  // TAP ikon hati -> like / unlike
  void toggleLike(Product item) {
    setState(() {
      item.isLiked = !item.isLiked;
      item.likes += item.isLiked ? 1 : -1;
    });
  }

  // TOMBOL + dan -
  void changeQuantity(Product item, int amount) {
    setState(() {
      item.quantity += amount;
      if (item.quantity < 1) item.quantity = 1;
    });
  }

  // LONG PRESS -> munculkan pesan
  void showMessage(Product item) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.grey.shade900,
        // margin bawah dibuat besar supaya pesan muncul di atas layar
        margin: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).size.height - 170,
        ),
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Produk dipilih!',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${item.name} telah dipilih.',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void checkout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Checkout'),
        content: Text('$totalItems produk\nTotal ${formatRupiah(totalPrice)}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  // ===================== BUILD =====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      // ---------- APP BAR ----------
      appBar: AppBar(
        toolbarHeight: 64,
        automaticallyImplyLeading: false, // hilangkan slot leading bawaan
        titleSpacing: 16,
        centerTitle: false,
        // ikon + teks digabung dalam 1 Row supaya menempel
        title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
            const Icon(Icons.shopping_cart_outlined, color: Colors.white),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text(
              'My Cart',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Belanja Lebih Mudah Setiap Hari',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ],
      ),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),

      // ---------- BODY ----------
      body: Column(
        children: [
          // BAGIAN 1: LIST PRODUK (RESPONSIVE)
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // deteksi ukuran layar
                bool isMobile = constraints.maxWidth < 600;

                // mobile = 1 kolom, tablet = 2 kolom, layar lebar = 3 kolom
                int columns = (constraints.maxWidth / 400).floor();
                if (columns < 1) columns = 1;
                if (columns > 3) columns = 3;

                return GridView.builder(
                  padding: EdgeInsets.all(isMobile ? 12 : 24),
                  itemCount: products.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    mainAxisExtent: 140, // tinggi tiap kartu
                  ),
                  itemBuilder: (context, index) {
                    return _buildProductCard(products[index], isMobile);
                  },
                );
              },
            ),
          ),

          // BAGIAN 2: FOOTER (total + checkout)
          _buildFooter(),
        ],
      ),

      // ---------- BOTTOM NAV ----------
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: selectedNav,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            selectedNav = index;
          });
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.category_outlined),
            label: 'Kategori',
          ),
          BottomNavigationBarItem(
            // Badge = bulatan merah berisi jumlah barang
            icon: Badge(
              label: Text('$totalItems'),
              child: const Icon(Icons.shopping_cart),
            ),
            label: 'Keranjang',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.manage_accounts_outlined),
            label: 'Akun',
          ),
        ],
      ),
    );
  }

  // ===================== KARTU PRODUK =====================
  Widget _buildProductCard(Product item, bool isMobile) {
    // ukuran gambar menyesuaikan ukuran layar
    double imageSize = isMobile ? 90 : 110;

    return GestureDetector(
      onTap: () => selectProduct(item),
      onDoubleTap: () => likeProduct(item),
      onLongPress: () => showMessage(item),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: item.isSelected ? Colors.blue.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: item.isSelected ? Colors.blue : Colors.grey.shade300,
            width: item.isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // GAMBAR
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: imageSize,
                height: imageSize,
                color: Colors.grey.shade100,
                child: Image.network(
                  item.img,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.broken_image, color: Colors.grey);
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),

            // DETAIL: nama, brand, harga, like, jumlah
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    item.desc,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatRupiah(item.price),
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // LIKE
                      GestureDetector(
                        onTap: () => toggleLike(item),
                        child: Row(
                          children: [
                            Icon(
                              item.isLiked
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: item.isLiked ? Colors.red : Colors.grey,
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text('${item.likes}'),
                          ],
                        ),
                      ),
                      // JUMLAH BARANG  [-] 1 [+]
                      Row(
                        children: [
                          _buildQtyButton(
                            icon: Icons.remove,
                            isFilled: false,
                            onTap: () => changeQuantity(item, -1),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              '${item.quantity}',
                              style:
                              const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          _buildQtyButton(
                            icon: Icons.add,
                            isFilled: true,
                            onTap: () => changeQuantity(item, 1),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // tombol kecil + / - (dipakai 2x, jadi dibuat 1 fungsi)
  Widget _buildQtyButton({
    required IconData icon,
    required bool isFilled,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: isFilled ? Colors.blue : Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isFilled ? Colors.blue : Colors.grey.shade300,
          ),
        ),
        child: Icon(
          icon,
          size: 16,
          color: isFilled ? Colors.white : Colors.black87,
        ),
      ),
    );
  }

  // ===================== FOOTER =====================
  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Total ($totalItems produk)'),
              Text(
                formatRupiah(totalPrice),
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: checkout,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Checkout',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}