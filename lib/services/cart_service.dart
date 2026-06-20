import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product_model.dart';

class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> addToCart({
    required ProductModel product,
    required int quantity,
  }) async {
    try {
      final user = _auth.currentUser;

      if (user == null) {
        return 'Bạn cần đăng nhập để thêm vào giỏ hàng';
      }

      final cartRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('cart')
          .doc(product.id);

      final cartDoc = await cartRef.get();

      if (cartDoc.exists) {
        final oldQuantity = cartDoc.data()?['quantity'] ?? 0;

        await cartRef.update({
          'quantity': oldQuantity + quantity,
          'updatedAt': Timestamp.now(),
        });
      } else {
        await cartRef.set({
          'productId': product.id,
          'name': product.name,
          'category': product.category,
          'price': product.price,
          'oldPrice': product.oldPrice,
          'image': product.image,
          'quantity': quantity,
          'stock': product.stock,
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        });
      }

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> addOrderItemsToCart(
      List<Map<String, dynamic>> items,
      ) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return 'Bạn cần đăng nhập để mua lại';
      }

      for (final item in items) {
        final productId = item['productId'];
        if (productId == null) continue;

        final cartRef = _firestore
            .collection('users')
            .doc(user.uid)
            .collection('cart')
            .doc(productId);

        final cartDoc = await cartRef.get();

        final int quantity = (item['quantity'] as num?)?.toInt() ?? 1;

        if (cartDoc.exists) {
          final int oldQuantity =
              (cartDoc.data()?['quantity'] as num?)?.toInt() ?? 0;

          await cartRef.update({
            'quantity': oldQuantity + quantity,
            'updatedAt': Timestamp.now(),
          });
        } else {
          await cartRef.set({
            'productId': productId,
            'name': item['name'],
            'category': item['category'],
            'price': item['price'],
            'oldPrice': item['oldPrice'],
            'image': item['image'],
            'quantity': quantity,
            'stock': item['stock'],
            'createdAt': Timestamp.now(),
            'updatedAt': Timestamp.now(),
          });
        }
      }

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Stream<List<Map<String, dynamic>>> getCartItems() {
    final user = _auth.currentUser;

    if (user == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  Future<void> updateQuantity({
    required String productId,
    required int quantity,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .doc(productId)
        .update({
      'quantity': quantity,
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> removeFromCart(String productId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .doc(productId)
        .delete();
  }
}