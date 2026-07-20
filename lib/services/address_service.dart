import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/address_model.dart';

class AddressService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // shorthand collection reference
  CollectionReference<Map<String, dynamic>>? _col() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    return _db.collection('users').doc(uid).collection('addresses');
  }

  // ── Stream danh sách địa chỉ ──────────────────────────────────────────────
  Stream<List<AddressModel>> watchAddresses() {
    final col = _col();
    if (col == null) return Stream.value([]);

    return col
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snap) => snap.docs
        .map((d) => AddressModel.fromFirestore(d.id, d.data()))
        .toList());
  }

  // ── Thêm địa chỉ mới ─────────────────────────────────────────────────────
  Future<String?> addAddress(AddressModel address) async {
    try {
      final col = _col();
      if (col == null) return 'Bạn cần đăng nhập';

      // Nếu đây là địa chỉ mặc định → bỏ mặc định của tất cả địa chỉ cũ
      if (address.isDefault) await _clearDefault();

      await col.add(address.toMap());
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // ── Cập nhật địa chỉ ─────────────────────────────────────────────────────
  Future<String?> updateAddress(AddressModel address) async {
    try {
      final col = _col();
      if (col == null) return 'Bạn cần đăng nhập';

      if (address.isDefault) await _clearDefault(excludeId: address.id);

      await col.doc(address.id).update(address.toMap());
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // ── Xoá địa chỉ ──────────────────────────────────────────────────────────
  Future<String?> deleteAddress(String id) async {
    try {
      final col = _col();
      if (col == null) return 'Bạn cần đăng nhập';
      await col.doc(id).delete();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // ── Đặt làm mặc định ─────────────────────────────────────────────────────
  Future<String?> setDefault(String id) async {
    try {
      final col = _col();
      if (col == null) return 'Bạn cần đăng nhập';

      await _clearDefault();
      await col.doc(id).update({'isDefault': true});
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // ── Lấy địa chỉ mặc định (1 lần) ─────────────────────────────────────────
  Future<AddressModel?> getDefaultAddress() async {
    try {
      final col = _col();
      if (col == null) return null;

      final snap = await col
          .where('isDefault', isEqualTo: true)
          .limit(1)
          .get();

      if (snap.docs.isEmpty) return null;
      return AddressModel.fromFirestore(
          snap.docs.first.id, snap.docs.first.data());
    } catch (_) {
      return null;
    }
  }

  // ── Bỏ cờ isDefault cho tất cả (batch) ───────────────────────────────────
  Future<void> _clearDefault({String? excludeId}) async {
    final col = _col();
    if (col == null) return;

    final snap = await col.where('isDefault', isEqualTo: true).get();
    final batch = _db.batch();
    for (final doc in snap.docs) {
      if (doc.id == excludeId) continue;
      batch.update(doc.reference, {'isDefault': false});
    }
    await batch.commit();
  }
}
