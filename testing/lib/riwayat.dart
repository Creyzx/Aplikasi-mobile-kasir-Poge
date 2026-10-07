import 'package:flutter/material.dart';

import 'app_background.dart';
import 'database/db_helper.dart';
import 'database/models.dart';
import 'home_page.dart';
import 'keranjang.dart';
import 'produk.dart';

class RiwayatTransaksiPage extends StatelessWidget {
  const RiwayatTransaksiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: FutureBuilder<List<TransactionRecord>>(
        future: DatabaseHelper.instance.getTransactions(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return AppBackground(
            child: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
                      child: Column(
                        children: [
                          _buildHeader(context),
                          const SizedBox(height: 22),
                          _buildFilters(),
                          const SizedBox(height: 18),
                          ...snapshot.data!.map(_buildTransaction),
                        ],
                      ),
                    ),
                  ),
                  _buildBottomNav(context),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back_ios_new_rounded, size: 22),
        ),
        const Expanded(
          child: Center(
            child: Text(
              'Riwayat Transaksi',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const Icon(Icons.shopping_cart_outlined, size: 25),
      ],
    );
  }

  Widget _buildFilters() {
    const filters = ['semua', 'Hari Ini', 'Minggu Ini', 'Bulan ini'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: filters.map((filter) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.black.withValues(alpha: 0.35)),
          ),
          child: Text(
            filter,
            style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 14),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTransaction(TransactionRecord transaction) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 14, 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.62),
        border: Border(
          bottom: BorderSide(color: Colors.black.withValues(alpha: 0.7)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.invoiceNumber,
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDate(transaction.createdAt),
                  style: const TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Rp ${transaction.total}',
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
              const Text(
                'Selesai',
                style: TextStyle(
                  color: Colors.green,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month/${date.year}  $hour:$minute';
  }

  Widget _buildBottomNav(BuildContext context) {
    final items = [
      (Icons.home_outlined, 'Beranda'),
      (Icons.inventory_2_outlined, 'Produk'),
      (Icons.shopping_cart_outlined, 'Keranjang'),
      (Icons.history, 'Pesanan'),
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(top: 10, bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items.map((item) {
          final selected = item.$2 == 'Pesanan';
          return GestureDetector(
            onTap: () {
              if (item.$2 == 'Beranda') {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const HomePage()),
                  (_) => false,
                );
              } else if (item.$2 == 'Produk') {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const ProdukPage()),
                  (_) => false,
                );
              } else if (item.$2 == 'Keranjang') {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const KeranjangPage()),
                  (_) => false,
                );
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  item.$1,
                  size: 23,
                  color: selected ? Colors.black : Colors.black87,
                ),
                const SizedBox(height: 3),
                Text(
                  item.$2,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
