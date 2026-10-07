import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'models.dart';

class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    final databasesPath = await getDatabasesPath();
    _database = await openDatabase(
      join(databasesPath, 'kopi_poge.db'),
      version: 3,
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
    await _seedProducts(_database!);
    return _database!;
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        unit TEXT NOT NULL,
        sale_price INTEGER NOT NULL,
        cost_price INTEGER,
        image_path TEXT,
        image_data BLOB,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
    ''');
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        invoice_number TEXT NOT NULL UNIQUE,
        buyer_name TEXT NOT NULL,
        payment_method TEXT NOT NULL,
        paid_amount INTEGER NOT NULL,
        change_amount INTEGER NOT NULL,
        subtotal INTEGER NOT NULL,
        discount INTEGER NOT NULL DEFAULT 0,
        total INTEGER NOT NULL,
        status TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE transaction_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        transaction_id INTEGER NOT NULL,
        product_id INTEGER,
        product_name TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        unit_price INTEGER NOT NULL,
        subtotal INTEGER NOT NULL,
        FOREIGN KEY (transaction_id) REFERENCES transactions(id) ON DELETE CASCADE,
        FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE SET NULL
      )
    ''');
    await _createCartTable(db);
    await db.execute(
      'CREATE INDEX idx_transactions_created_at ON transactions(created_at)',
    );
    await db.execute(
      'CREATE INDEX idx_transaction_items_transaction_id ON transaction_items(transaction_id)',
    );
  }

  Future<void> _upgradeDatabase(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) await _createCartTable(db);
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE products ADD COLUMN image_data BLOB');
    }
  }

  Future<void> _createCartTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS cart_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER NOT NULL UNIQUE,
        quantity INTEGER NOT NULL CHECK(quantity > 0),
        FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _seedProducts(Database db) async {
    final products = [
      Product(
        name: 'Kopi Hitam',
        category: 'Minuman',
        unit: 'Gelas',
        salePrice: 5000,
        imageData: await _loadAssetImage('assets/product_kopi.png'),
      ),
      Product(
        name: 'Pop Ice Coklat',
        category: 'Minuman',
        unit: 'Gelas',
        salePrice: 5000,
        imageData: await _loadAssetImage('assets/product_pop_ice.png'),
      ),
      Product(
        name: 'Gorengan',
        category: 'Makanan',
        unit: 'Porsi',
        salePrice: 10000,
        imageData: await _loadAssetImage('assets/product_gorengan.png'),
      ),
    ];

    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM products'),
    );
    if ((count ?? 0) > 0) {
      for (final product in products) {
        await db.update(
          'products',
          {'image_data': product.imageData},
          where: 'name = ? AND image_data IS NULL',
          whereArgs: [product.name],
        );
      }
      return;
    }

    for (final product in products) {
      await db.insert('products', product.toMap()..remove('id'));
    }
  }

  Future<Uint8List> _loadAssetImage(String assetPath) async {
    final image = await rootBundle.load(assetPath);
    return image.buffer.asUint8List(image.offsetInBytes, image.lengthInBytes);
  }

  Future<List<Product>> getProducts({String? search, String? category}) async {
    final db = await database;
    final where = <String>['is_active = 1'];
    final args = <Object?>[];
    if (search != null && search.trim().isNotEmpty) {
      where.add('name LIKE ?');
      args.add('%${search.trim()}%');
    }
    if (category != null && category != 'semua') {
      where.add('category = ?');
      args.add(category);
    }
    final rows = await db.query(
      'products',
      where: where.join(' AND '),
      whereArgs: args,
      orderBy: 'name COLLATE NOCASE',
    );
    return rows.map(Product.fromMap).toList();
  }

  Future<int> insertProduct(Product product) async {
    final db = await database;
    final values = product.toMap()..remove('id');
    return db.insert('products', values);
  }

  Future<int> updateProduct(Product product) async {
    if (product.id == null) throw ArgumentError('Product id is required');
    final db = await database;
    final values = product.toMap()..remove('id');
    return db.update(
      'products',
      values,
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<int> deactivateProduct(int id) async {
    final db = await database;
    return db.update(
      'products',
      {'is_active': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> addToCart(int productId, {int quantity = 1}) async {
    if (quantity < 1) throw ArgumentError('Quantity must be positive');
    final db = await database;
    await db.rawInsert(
      '''
      INSERT INTO cart_items (product_id, quantity) VALUES (?, ?)
      ON CONFLICT(product_id) DO UPDATE SET quantity = quantity + excluded.quantity
    ''',
      [productId, quantity],
    );
  }

  Future<List<CartItem>> getCartItems() async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT p.* , c.quantity AS cart_quantity
      FROM cart_items c
      INNER JOIN products p ON p.id = c.product_id
      WHERE p.is_active = 1
      ORDER BY c.id ASC
    ''');
    return rows
        .map(
          (row) => CartItem(
            product: Product.fromMap(row),
            quantity: row['cart_quantity'] as int,
          ),
        )
        .toList();
  }

  Future<void> updateCartQuantity(int productId, int quantity) async {
    final db = await database;
    if (quantity <= 0) {
      await db.delete(
        'cart_items',
        where: 'product_id = ?',
        whereArgs: [productId],
      );
    } else {
      await db.update(
        'cart_items',
        {'quantity': quantity},
        where: 'product_id = ?',
        whereArgs: [productId],
      );
    }
  }

  Future<void> clearCart() async {
    final db = await database;
    await db.delete('cart_items');
  }

  Future<int> createTransaction({
    required String buyerName,
    required int paidAmount,
    required List<CartItem> items,
    int discount = 0,
  }) async {
    if (buyerName.trim().isEmpty) throw ArgumentError('Buyer name is required');
    if (items.isEmpty) throw ArgumentError('Transaction must have items');
    final subtotal = items.fold<int>(0, (sum, item) => sum + item.subtotal);
    final total = subtotal - discount;
    if (paidAmount < total) throw ArgumentError('Paid amount is insufficient');

    final db = await database;
    return db.transaction((txn) async {
      final now = DateTime.now();
      final invoice = '#INV-${now.microsecondsSinceEpoch}';
      final transactionId = await txn.insert('transactions', {
        'invoice_number': invoice,
        'buyer_name': buyerName.trim(),
        'payment_method': 'Tunai',
        'paid_amount': paidAmount,
        'change_amount': paidAmount - total,
        'subtotal': subtotal,
        'discount': discount,
        'total': total,
        'status': 'Selesai',
        'created_at': now.toIso8601String(),
      });
      for (final item in items) {
        await txn.insert('transaction_items', {
          'transaction_id': transactionId,
          'product_id': item.product.id,
          'product_name': item.product.name,
          'quantity': item.quantity,
          'unit_price': item.product.salePrice,
          'subtotal': item.subtotal,
        });
      }
      return transactionId;
    });
  }

  Future<List<TransactionRecord>> getTransactions() async {
    final db = await database;
    final rows = await db.query('transactions', orderBy: 'created_at DESC');
    return rows.map(TransactionRecord.fromMap).toList();
  }

  Future<List<TransactionRecord>> getRecentTransactions({int limit = 5}) async {
    final db = await database;
    final rows = await db.query(
      'transactions',
      orderBy: 'created_at DESC',
      limit: limit,
    );
    return rows.map(TransactionRecord.fromMap).toList();
  }

  Future<DashboardSummary> getDashboardSummary() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT
        COUNT(*) AS transaction_count,
        COALESCE(SUM(total), 0) AS sales_total
      FROM transactions
      WHERE status = 'Selesai'
    ''');
    final row = result.first;
    final soldResult = await db.rawQuery('''
      SELECT COALESCE(SUM(quantity), 0) AS sold_quantity
      FROM transaction_items
      INNER JOIN transactions ON transactions.id = transaction_items.transaction_id
      WHERE transactions.status = 'Selesai'
    ''');
    return DashboardSummary(
      transactionCount: (row['transaction_count'] as int?) ?? 0,
      salesTotal: (row['sales_total'] as int?) ?? 0,
      productsSold: (soldResult.first['sold_quantity'] as int?) ?? 0,
    );
  }

  Future<List<DailySales>> getRecentDailySales({int dayCount = 7}) async {
    if (dayCount < 1) throw ArgumentError.value(dayCount, 'dayCount');

    final today = DateTime.now();
    final firstDay = DateTime(today.year, today.month, today.day)
        .subtract(Duration(days: dayCount - 1));
    String dateKey(DateTime date) =>
        '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';

    final db = await database;
    final rows = await db.rawQuery(
      '''
      SELECT substr(created_at, 1, 10) AS sales_date,
             COALESCE(SUM(total), 0) AS sales_total
      FROM transactions
      WHERE status = 'Selesai'
        AND substr(created_at, 1, 10) BETWEEN ? AND ?
      GROUP BY sales_date
      ORDER BY sales_date ASC
      ''',
      [dateKey(firstDay), dateKey(today)],
    );
    final totalsByDate = {
      for (final row in rows)
        row['sales_date'] as String: row['sales_total'] as int,
    };

    return List.generate(dayCount, (index) {
      final date = firstDay.add(Duration(days: index));
      return DailySales(date: date, total: totalsByDate[dateKey(date)] ?? 0);
    });
  }

  Future<TransactionRecord?> getTransaction(int id) async {
    final db = await database;
    final rows = await db.query(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (rows.isEmpty) return null;
    return TransactionRecord.fromMap(rows.first);
  }

  Future<List<TransactionItem>> getTransactionItems(int transactionId) async {
    final db = await database;
    final rows = await db.query(
      'transaction_items',
      where: 'transaction_id = ?',
      whereArgs: [transactionId],
      orderBy: 'id ASC',
    );
    return rows.map(TransactionItem.fromMap).toList();
  }
}
