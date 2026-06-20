import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> createOrder({
    required List<Map<String, dynamic>> items,
    required String fullName,
    required String phone,
    required String address,
    required int subtotal,
    required int shippingFee,
    required int total,
    required String paymentMethod,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 'Bạn cần đăng nhập để đặt hàng';

      final orderRef = _firestore.collection('orders').doc();

      await orderRef.set({
        'orderId': orderRef.id,
        'userId': user.uid,
        'fullName': fullName,
        'phone': phone,
        'address': address,
        'items': items,
        'subtotal': subtotal,
        'shippingFee': shippingFee,
        'total': total,
        'paymentMethod': paymentMethod,
        'status': 'Pending',
        'createdAt': Timestamp.now(),
      });

      final cartSnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('cart')
          .get();

      for (final doc in cartSnapshot.docs) {
        await doc.reference.delete();
      }

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Stream<List<Map<String, dynamic>>> getMyOrders() {
    final user = _auth.currentUser;

    if (user == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }
}