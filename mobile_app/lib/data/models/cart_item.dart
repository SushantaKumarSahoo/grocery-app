import 'product.dart';

class CartItem {
  final Product product;
  double quantity;
  String? packaging;
  String? notes;

  CartItem({
    required this.product,
    required this.quantity,
    this.packaging,
    this.notes,
  });

  double get subtotal => product.price * quantity;
}
