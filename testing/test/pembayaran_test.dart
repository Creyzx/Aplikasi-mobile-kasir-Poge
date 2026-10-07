import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:testing/database/models.dart';
import 'package:testing/pembayaran.dart';

void main() {
  testWidgets('nominal tunai memperbarui kembalian dengan format rupiah', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 1100);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: PembayaranPage(
          items: [
            CartItem(
              product: const Product(
                name: 'Kopi Hitam',
                category: 'Minuman',
                unit: 'Gelas',
                salePrice: 5000,
              ),
              quantity: 1,
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Rp 55.000'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(1), '7000');
    await tester.pump();

    expect(find.text('Rp 2.000'), findsOneWidget);
  });
}