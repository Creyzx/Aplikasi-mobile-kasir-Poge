import 'dart:typed_data';

class Product {
  const Product({
    this.id,
    required this.name,
    required this.category,
    required this.unit,
    required this.salePrice,
    this.costPrice,
    this.imagePath,
    this.imageData,
    this.isActive = true,
  });

  final int? id;
  final String name;
  final String category;
  final String unit;
  final int salePrice;
  final int? costPrice;
  final String? imagePath;
  final Uint8List? imageData;
  final bool isActive;

  Map<String, Object?> toMap() => {
    'id': id,
    'name': name,
    'category': category,
    'unit': unit,
    'sale_price': salePrice,
    'cost_price': costPrice,
    'image_path': imagePath,
    'image_data': imageData,
    'is_active': isActive ? 1 : 0,
  };

  factory Product.fromMap(Map<String, Object?> map) => Product(
    id: map['id'] as int?,
    name: map['name'] as String,
    category: map['category'] as String,
    unit: map['unit'] as String,
    salePrice: map['sale_price'] as int,
    costPrice: map['cost_price'] as int?,
    imagePath: map['image_path'] as String?,
    imageData: map['image_data'] as Uint8List?,
    isActive: (map['is_active'] as int? ?? 1) == 1,
  );
}

class CartItem {
  const CartItem({required this.product, required this.quantity});

  final Product product;
  final int quantity;

  int get subtotal => product.salePrice * quantity;
}

class TransactionRecord {
  const TransactionRecord({
    required this.id,
    required this.invoiceNumber,
    required this.buyerName,
    required this.paymentMethod,
    required this.paidAmount,
    required this.changeAmount,
    required this.subtotal,
    required this.discount,
    required this.total,
    required this.status,
    required this.createdAt,
  });

  final int id;
  final String invoiceNumber;
  final String buyerName;
  final String paymentMethod;
  final int paidAmount;
  final int changeAmount;
  final int subtotal;
  final int discount;
  final int total;
  final String status;
  final DateTime createdAt;

  factory TransactionRecord.fromMap(Map<String, Object?> map) =>
      TransactionRecord(
        id: map['id'] as int,
        invoiceNumber: map['invoice_number'] as String,
        buyerName: map['buyer_name'] as String,
        paymentMethod: map['payment_method'] as String,
        paidAmount: map['paid_amount'] as int,
        changeAmount: map['change_amount'] as int,
        subtotal: map['subtotal'] as int,
        discount: map['discount'] as int,
        total: map['total'] as int,
        status: map['status'] as String,
        createdAt: DateTime.parse(map['created_at'] as String),
      );
}

class TransactionItem {
  const TransactionItem({
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  final String productName;
  final int quantity;
  final int unitPrice;
  final int subtotal;

  factory TransactionItem.fromMap(Map<String, Object?> map) => TransactionItem(
    productName: map['product_name'] as String,
    quantity: map['quantity'] as int,
    unitPrice: map['unit_price'] as int,
    subtotal: map['subtotal'] as int,
  );
}

class DashboardSummary {
  const DashboardSummary({
    required this.transactionCount,
    required this.salesTotal,
    required this.productsSold,
  });

  final int transactionCount;
  final int salesTotal;
  final int productsSold;
}

class DailySales {
  const DailySales({required this.date, required this.total});

  final DateTime date;
  final int total;
}
