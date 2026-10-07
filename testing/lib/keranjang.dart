import 'package:flutter/material.dart';

import 'app_background.dart';
import 'database/db_helper.dart';
import 'database/models.dart';
import 'pembayaran.dart';
import 'produk.dart';
import 'home_page.dart';
import 'riwayat.dart';

class KeranjangPage extends StatefulWidget {
  const KeranjangPage({super.key});

  @override
  State<KeranjangPage> createState() => _KeranjangPageState();
}

class _KeranjangPageState extends State<KeranjangPage> {
  List<CartItem>? _items;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    final items = await DatabaseHelper.instance.getCartItems();
    if (!mounted) return;
    setState(() => _items = items);
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;
    if (items == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final subtotal = items.fold<int>(0, (sum, item) => sum + item.subtotal);

    const discount = 0;
    final total = subtotal - discount;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(painter: CoffeePatternPainter()),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 10,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    _buildHeader(context),
                    const SizedBox(height: 10),
                    _buildTableHeader(),
                    const SizedBox(height: 10),
                    ...items.map((item) => _buildCartItem(item)),
                    const SizedBox(height: 18),
                    _buildSummary(
                      subtotal: subtotal,
                      discount: discount,
                      total: total,
                    ),
                    const SizedBox(height: 18),
                    _buildCheckoutButton(context, items),
                    const Spacer(),
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
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: const Color(0xFFEAE1D5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black.withValues(alpha: 0.15)),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
          ),
        ),
        const Expanded(
          child: Center(
            child: Text(
              'Keranjang',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1B1B1B),
              ),
            ),
          ),
        ),
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: const Color(0xFFEAE1D5),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.black.withValues(alpha: 0.15)),
          ),
          child: const Icon(Icons.shopping_cart_rounded, size: 18),
        ),
      ],
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: const [
          Expanded(
            child: Text(
              'Produk',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
          SizedBox(width: 40),
          SizedBox(
            width: 60,
            child: Center(
              child: Text(
                'Qty',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          SizedBox(
            width: 90,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Subtotal',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(CartItem item) {
    final name = item.product.name;
    final price = item.product.salePrice;
    final qty = item.quantity;
    final subtotal = item.subtotal;

    return Container(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1C1C1C),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Rp. ${price.toString().replaceAllMapped(RegExp(r'B(?=(?:\d{3})+(?!\d))'), (m) => '.')} ',
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF1C1C1C),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 104,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _roundQtyButton(Icons.remove, () async {
                  if (item.product.id == null) return;
                  await DatabaseHelper.instance.updateCartQuantity(
                    item.product.id!,
                    qty - 1,
                  );
                  _loadCart();
                }),
                const SizedBox(width: 10),
                Container(
                  width: 28,
                  alignment: Alignment.center,
                  child: Text(
                    qty.toString(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1D1D1D),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                _roundQtyButton(Icons.add, () async {
                  if (item.product.id == null) return;
                  await DatabaseHelper.instance.updateCartQuantity(
                    item.product.id!,
                    qty + 1,
                  );
                  _loadCart();
                }),
              ],
            ),
          ),
          SizedBox(
            width: 95,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Rp.${subtotal.toString().replaceAllMapped(RegExp(r'B(?=(?:\d{3})+(?!\d))'), (m) => '.')}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1D1D1D),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _roundQtyButton(IconData icon, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: const Color(0xFFE7E1D7),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black.withValues(alpha: 0.2)),
        ),
        child: Icon(icon, size: 16, color: const Color(0xFF1E1E1E)),
      ),
    );
  }

  Widget _buildSummary({
    required int subtotal,
    required int discount,
    required int total,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF4EFE8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Subtotal',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              Text(
                'Rp ${subtotal.toString().replaceAllMapped(RegExp(r'B(?=(?:\d{3})+(?!\d))'), (m) => '.')}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Diskon',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              Text(
                'Rp ${discount.toString().replaceAllMapped(RegExp(r'B(?=(?:\d{3})+(?!\d))'), (m) => '.')}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Divider(color: Color(0xFF2A2A2A), thickness: 1.1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              Text(
                'Rp ${total.toString().replaceAllMapped(RegExp(r'B(?=(?:\d{3})+(?!\d))'), (m) => '.')}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutButton(BuildContext context, List<CartItem> items) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PembayaranPage(items: items),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5C2D14),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Lanjut Ke Pembayaran',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
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
      width: double.infinity,
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
            final isSelected = item['label'] == 'Keranjang';
            final label = item['label'] as String;

            return GestureDetector(
              onTap: () {
                if (label == 'Beranda') {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                    (route) => false,
                  );
                } else if (label == 'Produk') {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const ProdukPage()),
                    (route) => false,
                  );
                } else if (label == 'Pesanan') {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RiwayatTransaksiPage(),
                    ),
                    (route) => false,
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

class CoffeePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2B2B2B).withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final shapes = [
      Path()
        ..moveTo(size.width * 0.08, size.height * 0.82)
        ..quadraticBezierTo(
          size.width * 0.17,
          size.height * 0.7,
          size.width * 0.24,
          size.height * 0.82,
        )
        ..quadraticBezierTo(
          size.width * 0.18,
          size.height * 0.92,
          size.width * 0.1,
          size.height * 0.96,
        ),
      Path()
        ..moveTo(size.width * 0.72, size.height * 0.12)
        ..quadraticBezierTo(
          size.width * 0.81,
          size.height * 0.06,
          size.width * 0.91,
          size.height * 0.18,
        )
        ..quadraticBezierTo(
          size.width * 0.89,
          size.height * 0.29,
          size.width * 0.72,
          size.height * 0.3,
        ),
      Path()
        ..moveTo(size.width * 0.69, size.height * 0.8)
        ..quadraticBezierTo(
          size.width * 0.82,
          size.height * 0.72,
          size.width * 0.95,
          size.height * 0.83,
        ),
      Path()
        ..moveTo(size.width * 0.22, size.height * 0.42)
        ..quadraticBezierTo(
          size.width * 0.42,
          size.height * 0.34,
          size.width * 0.52,
          size.height * 0.52,
        )
        ..quadraticBezierTo(
          size.width * 0.4,
          size.height * 0.62,
          size.width * 0.26,
          size.height * 0.6,
        ),
    ];

    for (final item in shapes) {
      canvas.drawPath(item, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
