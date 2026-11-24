import 'package:agri_mart_admin/constants/discount.dart';
import 'package:agri_mart_admin/models/products_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Admin discountPercent', () {
    test('calculates percentage discount accurately', () {
      expect(discountPercent(1000, 750), '25');
      expect(discountPercent(500, 500), '0');
    });

    test('handles zero oldPrice safely', () {
      expect(discountPercent(0, 100), '0');
    });
  });

  group('Admin ProductsModel', () {
    test('parses product JSON with defaults', () {
      final product = ProductsModel.fromJson({
        'name': 'Organic Fertilizer',
        'desc': 'High-yield fertilizer',
        'image': 'https://example.com/img.png',
        'old_price': 500,
        'new_price': 400,
        'category': 'fertilizers',
        'quantity': 20,
      }, 'prod_1');

      expect(product.id, 'prod_1');
      expect(product.name, 'Organic Fertilizer');
      expect(product.old_price, 500);
      expect(product.new_price, 400);
      expect(product.maxQuantity, 20);
    });
  });
}
