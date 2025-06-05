import 'medicine.dart';

class CartItem {
  final Medicine medicine;
  final int quantity;

  CartItem({
    required this.medicine,
    required this.quantity,
  });

  double get totalPrice => medicine.price * quantity;

  CartItem copyWith({
    Medicine? medicine,
    int? quantity,
  }) {
    return CartItem(
      medicine: medicine ?? this.medicine,
      quantity: quantity ?? this.quantity,
    );
  }
}

class Cart {
  final String userId;
  final List<CartItem> items;

  Cart({
    required this.userId,
    required this.items,
  });

  double get totalPrice => items.fold(0, (sum, item) => sum + item.totalPrice);

  Cart copyWith({
    String? userId,
    List<CartItem>? items,
  }) {
    return Cart(
      userId: userId ?? this.userId,
      items: items ?? this.items,
    );
  }
}
