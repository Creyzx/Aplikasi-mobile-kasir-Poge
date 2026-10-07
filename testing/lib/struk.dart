import 'package:flutter/material.dart';

import 'app_background.dart';
import 'database/db_helper.dart';
import 'database/models.dart';

class StrukPage extends StatelessWidget {
  const StrukPage({super.key, this.transactionId});

  final int? transactionId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
            child: Column(
              children: [
                _buildHeader(context),
                const SizedBox(height: 18),
                if (transactionId == null)
                  _buildReceiptCard(null, const [])
                else
                  FutureBuilder<TransactionRecord?>(
                    future: DatabaseHelper.instance.getTransaction(
                      transactionId!,
                    ),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data == null) {
                        return const CircularProgressIndicator();
                      }
                      return FutureBuilder<List<TransactionItem>>(
                        future: DatabaseHelper.instance.getTransactionItems(
                          transactionId!,
                        ),
                        builder: (context, itemsSnapshot) {
                          if (!itemsSnapshot.hasData) {
                            return const CircularProgressIndicator();
                          }
                          return _buildReceiptCard(
                            snapshot.data,
                            itemsSnapshot.data!,
                          );
                        },
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
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
              'Struk',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 22),
      ],
    );
  }

  Widget _buildReceiptCard(
    TransactionRecord? transaction,
    List<TransactionItem> items,
  ) {
    final invoice = transaction?.invoiceNumber ?? '#INV-00123';
    final date = transaction == null
        ? '20 Mei 2024  10:23'
        : _formatDate(transaction.createdAt);
    final buyer = transaction?.buyerName ?? 'Kasir';
    final subtotal = transaction?.subtotal ?? 60000;
    final discount = transaction?.discount ?? 0;
    final total = transaction?.total ?? 60000;
    final paid = transaction?.paidAmount ?? 100000;
    final change = transaction?.changeAmount ?? 40000;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.58),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Image.asset('assets/Logo.png', width: 92, height: 62),
                ],
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Text(
                    'Jl. Kopi No 1, malang\ntelp. 0812-3456-7890',
                    style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 28, color: Colors.black54),
          _detailRow('No. Transaksi', invoice),
          _detailRow('Tanggal', date),
          _detailRow('Pembeli', buyer),
          const Divider(height: 24, color: Colors.black54),
          _buildTableHeader(),
          if (items.isEmpty)
            _buildItemRow('Es Kopi Susu', '2', '15.000', '30.000')
          else
            ...items.map(
              (item) => _buildItemRow(
                item.productName,
                item.quantity.toString(),
                item.unitPrice.toString(),
                item.subtotal.toString(),
              ),
            ),
          const Divider(height: 18, color: Colors.black54),
          _amountRow('Subtotal', 'Rp $subtotal'),
          _amountRow('Diskon', 'Rp $discount'),
          const Divider(height: 18, color: Colors.black54),
          _amountRow('Total', 'Rp $total', emphasized: true),
          const Divider(height: 18, color: Colors.black54),
          _amountRow(
            'Bayar\nKembalian',
            'Rp $paid\nRp $change',
            greenSecondLine: true,
          ),
          const SizedBox(height: 48),
          const Center(
            child: Text(
              'Terimah kasih atas kunjungan anda!\nbarang yang sudah di beli tidak\ndapat di kembalikan.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
            ),
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

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          SizedBox(
            width: 114,
            child: Text(
              label,
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
          Expanded(
            child: Text(
              ': $value',
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return const Padding(
      padding: EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              'Produk',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Qty',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Harga',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Subtotal',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(
    String product,
    String quantity,
    String price,
    String subtotal,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              product,
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
          Expanded(
            child: Text(
              quantity,
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
          Expanded(
            child: Text(
              price,
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
          Expanded(
            child: Text(
              subtotal,
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }

  Widget _amountRow(
    String label,
    String amount, {
    bool emphasized = false,
    bool greenSecondLine = false,
  }) {
    final lines = amount.split('\n');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: emphasized ? FontWeight.w700 : FontWeight.normal,
              fontStyle: FontStyle.italic,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: lines.asMap().entries.map((entry) {
              return Text(
                entry.value,
                style: TextStyle(
                  fontWeight: emphasized ? FontWeight.w700 : FontWeight.normal,
                  fontStyle: FontStyle.italic,
                  color: greenSecondLine && entry.key == 1
                      ? Colors.green
                      : Colors.black,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
