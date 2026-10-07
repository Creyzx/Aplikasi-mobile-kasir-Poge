import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'app_background.dart';
import 'database/db_helper.dart';
import 'database/models.dart';
import 'produk.dart';
import 'keranjang.dart';
import 'riwayat.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  DashboardSummary _summary = const DashboardSummary(
    transactionCount: 0,
    salesTotal: 0,
    productsSold: 0,
  );
  List<TransactionRecord> _recentTransactions = const [];
  List<DailySales> _salesByDay = const [];

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    final results = await Future.wait([
      DatabaseHelper.instance.getDashboardSummary(),
      DatabaseHelper.instance.getRecentTransactions(),
      DatabaseHelper.instance.getRecentDailySales(),
    ]);
    if (!mounted) return;
    setState(() {
      _summary = results[0] as DashboardSummary;
      _recentTransactions = results[1] as List<TransactionRecord>;
      _salesByDay = results[2] as List<DailySales>;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: AppBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16.0, 64.0, 16.0, 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Banner Selamat Datang & Logo KOPI POGE
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Selamat Datang',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      Column(
                        children: [
                          Image.asset(
                            'assets/Logo.png',
                            width: 58,
                            height: 48,
                            fit: BoxFit.contain,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // 2. Bar Tanggal & Filter "Hari Ini"
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatCurrentDate(DateTime.now()),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.italic,
                        fontSize: 14,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.black26),
                      ),
                      child: const Text(
                        'Hari Ini',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // 3. Kartu Penjualan
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Penjualan',
                            style: TextStyle(
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Rp ${_formatAmount(_summary.salesTotal)}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Icon(Icons.payments_outlined, size: 36),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // 4. Kartu Total Transaksi & Produk Terjual
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 80,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.black12),
                        ),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            'Total Transaksi\n${_summary.transactionCount}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 80,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.black12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Produk Terjual',
                              style: TextStyle(
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${_summary.productsSold}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // 5. Grafik penjualan tujuh hari terakhir dari database
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Penjualan 7 Hari Terakhir',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '(Rupiah)',
                        style: TextStyle(fontSize: 12, color: Colors.black87),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(height: 150, child: _buildSalesChart()),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Riwayat Transaksi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 8),
                if (_recentTransactions.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black12),
                    ),
                    child: const Text(
                      'Belum ada transaksi',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  )
                else
                  ..._recentTransactions.map(_buildRecentTransaction),
              ],
            ),
          ),
        ),
      ),

      // 7. Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) async {
          setState(() {
            _selectedIndex = index;
          });

          switch (index) {
            case 1:
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProdukPage()),
              );
              await _loadDashboard();
              break;
            case 2:
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const KeranjangPage()),
              );
              await _loadDashboard();
              break;
            case 3:
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RiwayatTransaksiPage(),
                ),
              );
              await _loadDashboard();
              break;
            default:
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.brown,
        unselectedItemColor: Colors.black54,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            label: 'Produk',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            label: 'Keranjang',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Pesanan'),
        ],
      ),
    );
  }

  Widget _buildSalesChart() {
    if (_salesByDay.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final maxSales = _salesByDay.fold<int>(
      0,
      (highest, day) => math.max(highest, day.total),
    );
    final maxY = (maxSales > 0 ? maxSales * 1.2 : 1).toDouble();
    final spots = [
      for (var index = 0; index < _salesByDay.length; index++)
        FlSpot(index.toDouble(), _salesByDay[index].total.toDouble()),
    ];

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (_salesByDay.length - 1).toDouble(),
        minY: 0,
        maxY: maxY,
        gridData: const FlGridData(show: true),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 46,
              interval: maxY / 4,
              getTitlesWidget: (value, meta) => SideTitleWidget(
                meta: meta,
                child: Text(
                  _formatCompactAmount(value),
                  style: const TextStyle(fontSize: 9),
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final index = value.round();
                if (index < 0 || index >= _salesByDay.length) {
                  return const SizedBox.shrink();
                }
                final date = _salesByDay[index].date;
                return SideTitleWidget(
                  meta: meta,
                  child: Text(
                    '${_weekdayShort(date.weekday)} ${date.day}',
                    style: const TextStyle(fontSize: 9),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.black26),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.brown,
            barWidth: 2,
            dotData: const FlDotData(show: true),
          ),
        ],
      ),
    );
  }

  String _formatCompactAmount(double amount) {
    if (amount >= 1000000) return '${(amount / 1000000).toStringAsFixed(1)}jt';
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(0)}rb';
    return amount.toInt().toString();
  }

  String _weekdayShort(int weekday) =>
      const ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'][weekday - 1];

  String _formatCurrentDate(DateTime date) =>
      '${_weekdayShort(date.weekday)}, '
      '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/${date.year}';

  String _formatAmount(int amount) => amount.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (match) => '.',
  );

  Widget _buildRecentTransaction(TransactionRecord transaction) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.invoiceNumber,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  '${transaction.buyerName} - ${_formatDate(transaction.createdAt)}',
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
              Text('Rp ${transaction.total}'),
              Text(
                transaction.status,
                style: const TextStyle(color: Colors.green, fontSize: 12),
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
    return '$day/$month/${date.year} $hour:$minute';
  }
}
