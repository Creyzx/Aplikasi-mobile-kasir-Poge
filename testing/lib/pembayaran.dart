import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_background.dart';
import 'database/db_helper.dart';
import 'database/models.dart';
import 'struk.dart';

class PembayaranPage extends StatefulWidget {
  const PembayaranPage({super.key, required this.items});

  final List<CartItem> items;

  @override
  State<PembayaranPage> createState() => _PembayaranPageState();
}

class _PembayaranPageState extends State<PembayaranPage> {
  final TextEditingController buyerNameController = TextEditingController();
  final TextEditingController nominalController = TextEditingController(
    text: '0',
  );

  @override
  void dispose() {
    buyerNameController.dispose();
    nominalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.items.fold<int>(0, (sum, item) => sum + item.subtotal);
    final paidAmount =
        int.tryParse(
          nominalController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        ) ??
        0;
    final kembalian = paidAmount >= total ? paidAmount - total : 0;

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
                  vertical: 8,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    _buildHeader(),
                    const SizedBox(height: 18),
                    _buildTotalCard(total),
                    const SizedBox(height: 18),
                    _buildPaymentMethod(),
                    const SizedBox(height: 18),
                    _buildCashInput(kembalian),
                    const SizedBox(height: 18),
                    _buildPayButton(total),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
              color: const Color(0xFFE8E0D5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black.withValues(alpha: 0.15)),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
          ),
        ),
        const Expanded(
          child: Center(
            child: Text(
              'Pembayaran',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1B1B1B),
              ),
            ),
          ),
        ),
        const SizedBox(width: 30),
      ],
    );
  }

  Widget _buildTotalCard(int total) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF2EEE9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Pembayaran',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1B1B1B),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Rp $total',
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1C1C1C),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethod() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Metode Pembayaran',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1C1C1C),
            ),
          ),
          const SizedBox(height: 10),
          _buildRadioOption(),
        ],
      ),
    );
  }

  Widget _buildRadioOption() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFF2B2B2B), width: 1.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF1E1E1E), width: 2),
              color: const Color(0xFF1E1E1E),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Tunai',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1B1B1B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCashInput(int kembalian) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nama Pembeli',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1B1B1B),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: buyerNameController,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF5F0EC),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            hintText: 'Masukkan nama pembeli',
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Bayar Tunai',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1B1B1B),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Masukkan Nominal',
          style: TextStyle(fontSize: 16, color: Color(0xFF3A3A3A)),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: nominalController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF5F0EC),
            prefixText: 'Rp ',
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            hintText: 'Rp 0',
          ),
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1B1B1B),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Kembalian',
          style: TextStyle(fontSize: 18, color: Color(0xFF1B1B1B)),
        ),
        const SizedBox(height: 6),
        Text(
          'Rp ${_formatAmount(kembalian)}',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E8F45),
          ),
        ),
      ],
    );
  }

  String _formatAmount(int amount) => amount.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (match) => '.',
  );

  Widget _buildPayButton(int total) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          if (buyerNameController.text.trim().isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Nama pembeli wajib diisi')),
            );
            return;
          }
          final paidAmount =
              int.tryParse(
                nominalController.text.replaceAll(RegExp(r'[^0-9]'), ''),
              ) ??
              0;
          if (paidAmount < total) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Nominal pembayaran kurang')),
            );
            return;
          }
          final transactionId = await DatabaseHelper.instance.createTransaction(
            buyerName: buyerNameController.text,
            paidAmount: paidAmount,
            items: widget.items,
          );
          await DatabaseHelper.instance.clearCart();
          if (!mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StrukPage(transactionId: transactionId),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5D2B13),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Bayar & Cetak Struk',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
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
