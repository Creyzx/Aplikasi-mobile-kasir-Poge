import 'package:flutter/material.dart';

import 'app_background.dart';
import 'database/db_helper.dart';
import 'database/models.dart';
import 'keranjang.dart';
import 'home_page.dart';
import 'riwayat.dart';
import 'tambah_produk.dart';

class ProdukPage extends StatefulWidget {
  const ProdukPage({super.key});

  @override
  State<ProdukPage> createState() => _ProdukPageState();
}

class _ProdukPageState extends State<ProdukPage> {
  String _searchQuery = '';
  String _selectedCategory = 'semua';

  Future<List<Product>> _loadProducts() {
    return DatabaseHelper.instance.getProducts(
      search: _searchQuery,
      category: _selectedCategory == 'semua'
          ? null
          : _selectedCategory[0].toUpperCase() + _selectedCategory.substring(1),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(painter: CoffeeDoodlePainter()),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 8,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    _buildHeader(context),
                    const SizedBox(height: 18),
                    _buildSearchBar(),
                    const SizedBox(height: 14),
                    _buildCategoryRow(),
                    const SizedBox(height: 14),
                    Expanded(
                      child: FutureBuilder<List<Product>>(
                        future: _loadProducts(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          return ListView(
                            children: snapshot.data!.map((product) {
                              return _buildProductItem(
                                context,
                                product: product,
                                name: product.name,
                                price: 'Rp${product.salePrice}',
                                icon: Icons.local_cafe,
                                iconColor: const Color(0xFF5B3A29),
                                bgColor: const Color(0xFFE5D5C5),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildAddProductRow(context),
                    const SizedBox(height: 14),
                    _buildBottomNav(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: const Color(0xFFE7DED3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black.withValues(alpha: 0.15)),
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        ),
        Expanded(
          child: Center(
            child: Text(
              'Produk',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1E1E1E),
                fontFamily: 'Roboto',
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const KeranjangPage()),
            );
          },
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFFE7DED3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black.withValues(alpha: 0.15)),
            ),
            child: const Icon(Icons.shopping_cart_rounded, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F1EA),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: Color(0xFF5E5E5E)),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: const InputDecoration(
                hintText: 'Cari produk...',
                hintStyle: TextStyle(color: Color(0xFF6A6A6A), fontSize: 16),
                border: InputBorder.none,
                isDense: true,
              ),
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryRow() {
    final categories = ['semua', 'minuman', 'makanan', 'snack'];

    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final selected = categories[index] == _selectedCategory;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = categories[index]),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFFE8E1D8)
                    : const Color(0xFFF6F1EB),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.black.withValues(alpha: 0.12)),
              ),
              child: Text(
                categories[index],
                style: TextStyle(
                  color: const Color(0xFF2A2A2A),
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductItem(
    BuildContext context, {
    required Product product,
    required String name,
    required String price,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF5EFEA),
        borderRadius: BorderRadius.circular(0),
        border: const Border(
          bottom: BorderSide(color: Color(0xFF2E2E2E), width: 1.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
            ),
            child: product.imageData == null
                ? Icon(icon, color: iconColor, size: 30)
                : ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.memory(
                      product.imageData!,
                      width: 58,
                      height: 58,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) =>
                          Icon(icon, color: iconColor, size: 30),
                    ),
                  ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1D1D1D),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1D1D1D),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () async {
              if (product.id == null) return;
              await DatabaseHelper.instance.addToCart(product.id!);
              if (!context.mounted) return;
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const KeranjangPage()),
              );
            },
            child: Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: Color(0xFF232323),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddProductRow(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TambahProdukPage()),
        );
        if (mounted) setState(() {});
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF4EFE9),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.black.withValues(alpha: 0.12)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Tambah Produk',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1B1B1B),
              ),
            ),
            Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: Color(0xFF1E1E1E),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 26),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    final items = [
      {'icon': Icons.home_rounded, 'label': 'Beranda'},
      {'icon': Icons.inventory_2_rounded, 'label': 'Produk'},
      {'icon': Icons.local_shipping_rounded, 'label': 'Keranjang'},
      {'icon': Icons.receipt_long_rounded, 'label': 'Pesanan'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF6F0EA),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(18),
          topRight: Radius.circular(18),
        ),
        border: Border.all(color: Colors.black.withValues(alpha: 0.12)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: items.map((item) {
            final isSelected = item['label'] == 'Produk';
            final label = item['label'] as String;

            return GestureDetector(
              onTap: () {
                if (label == 'Beranda') {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                    (route) => false,
                  );
                } else if (label == 'Keranjang') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const KeranjangPage(),
                    ),
                  );
                } else if (label == 'Pesanan') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RiwayatTransaksiPage(),
                    ),
                  );
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    item['icon'] as IconData,
                    size: 24,
                    color: isSelected
                        ? const Color(0xFF111111)
                        : const Color(0xFF6D6D6D),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      color: isSelected
                          ? const Color(0xFF111111)
                          : const Color(0xFF6D6D6D),
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class CoffeeDoodlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2B2B2B).withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final path1 = Path()
      ..moveTo(size.width * 0.1, size.height * 0.82)
      ..quadraticBezierTo(
        size.width * 0.18,
        size.height * 0.7,
        size.width * 0.23,
        size.height * 0.8,
      )
      ..quadraticBezierTo(
        size.width * 0.18,
        size.height * 0.93,
        size.width * 0.12,
        size.height * 0.96,
      );

    final path2 = Path()
      ..moveTo(size.width * 0.74, size.height * 0.15)
      ..quadraticBezierTo(
        size.width * 0.82,
        size.height * 0.08,
        size.width * 0.92,
        size.height * 0.18,
      )
      ..quadraticBezierTo(
        size.width * 0.88,
        size.height * 0.32,
        size.width * 0.72,
        size.height * 0.32,
      );

    final path3 = Path()
      ..moveTo(size.width * 0.7, size.height * 0.78)
      ..quadraticBezierTo(
        size.width * 0.8,
        size.height * 0.72,
        size.width * 0.95,
        size.height * 0.84,
      );

    canvas.drawPath(path1, paint);
    canvas.drawPath(path2, paint);
    canvas.drawPath(path3, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
