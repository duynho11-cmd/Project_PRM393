import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../models/address_model.dart';
import '../services/address_service.dart';
import '../services/cart_service.dart';
import '../utils/app_responsive.dart';
import 'my_addresses_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _fullNameCtrl = TextEditingController();
  final _phoneCtrl    = TextEditingController();
  final _addressCtrl  = TextEditingController();

  AddressModel? _selectedAddress;
  final int _shippingFee   = 30000;
  bool      _loadingDefault = true;

  @override
  void initState() {
    super.initState();
    _prefillDefault();
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _prefillDefault() async {
    final def = await AddressService().getDefaultAddress();
    if (!mounted) return;
    setState(() {
      _loadingDefault = false;
      if (def != null) _applyAddress(def);
    });
  }

  void _applyAddress(AddressModel a) {
    _selectedAddress    = a;
    _fullNameCtrl.text  = a.fullName;
    _phoneCtrl.text     = a.phone;
    _addressCtrl.text   = a.fullAddress;
  }

  Future<void> _pickAddress() async {
    final result = await Navigator.push<AddressModel>(
      context,
      MaterialPageRoute(
          builder: (_) => const MyAddressesScreen(selectionMode: true)),
    );
    if (result != null) setState(() => _applyAddress(result));
  }

  String _fmt(int price) => '${price.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}đ';

  int _subtotal(List<Map<String, dynamic>> items) {
    int t = 0;
    for (final i in items) {
      t += ((i['price'] as num?)?.toInt() ?? 0) *
          ((i['quantity'] as num?)?.toInt() ?? 0);
    }
    return t;
  }

  void _goToPayment(List<Map<String, dynamic>> items) {
    final name = _fullNameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final addr  = _addressCtrl.text.trim();
    if (name.isEmpty || phone.isEmpty || addr.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Vui lòng nhập đầy đủ thông tin giao hàng'),
        backgroundColor: AppColors.accentRed,
      ));
      return;
    }
    final subtotal = _subtotal(items);
    Navigator.pushNamed(context, '/payment', arguments: {
      'items': items, 'fullName': name, 'phone': phone,
      'address': addr, 'subtotal': subtotal,
      'shippingFee': _shippingFee, 'total': subtotal + _shippingFee,
    });
  }

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Thanh toán')),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: CartService().getCartItems(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting ||
              _loadingDefault) {
            return const Center(
                child: CircularProgressIndicator(
                    color: AppColors.primary));
          }
          final items = snap.data ?? [];
          if (items.isEmpty) {
            return Center(
              child: Text('Giỏ hàng đang trống',
                  style: TextStyle(
                      color: AppColors.textGrey,
                      fontSize: r.sp(16),
                      fontWeight: FontWeight.w600)),
            );
          }
          final subtotal = _subtotal(items);
          final total    = subtotal + _shippingFee;

          return Column(children: [
            Expanded(
              child: ListView(
                padding: r.fromLTRB(20, 8, 20, 24),
                children: [
                  // Hero banner
                  Container(
                    padding: r.all(22),
                    decoration: BoxDecoration(
                      borderRadius:
                      BorderRadius.circular(AppColors.radiusXl),
                      gradient: AppColors.primaryGradient,
                      boxShadow:
                      AppColors.coloredShadow(AppColors.primary),
                    ),
                    child: Row(children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Gần xong rồi! 🎉',
                                style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: r.sp(13),
                                    fontWeight: FontWeight.w600)),
                            SizedBox(height: r.h(4)),
                            Text('Nhập thông tin\nnhận hàng',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: r.sp(22),
                                    fontWeight: FontWeight.w900,
                                    height: 1.25,
                                    letterSpacing: -0.4)),
                          ],
                        ),
                      ),
                      Icon(Icons.local_shipping_rounded,
                          color: AppColors.secondary, size: r.icon(56)),
                    ]),
                  ),

                  SizedBox(height: r.h(24)),

                  // Section header
                  _sectionHeader(r,
                    icon: Icons.location_on_outlined,
                    title: 'Thông tin giao hàng',
                    action: TextButton.icon(
                      onPressed: _pickAddress,
                      icon: Icon(Icons.list_alt_rounded, size: r.icon(16)),
                      label: Text('Chọn địa chỉ',
                          style: TextStyle(
                              fontSize: r.sp(13),
                              fontWeight: FontWeight.w700)),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ),

                  SizedBox(height: r.h(14)),
                  if (_selectedAddress != null)
                    _buildAddressBadge(r),
                  SizedBox(height: r.h(14)),

                  // Form card
                  Container(
                    padding: r.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                      BorderRadius.circular(AppColors.radiusXl),
                      border: Border.all(color: AppColors.border),
                      boxShadow: AppColors.softShadow(),
                    ),
                    child: Column(children: [
                      _buildField(r,
                          controller: _fullNameCtrl,
                          label: 'Họ và tên người nhận',
                          icon: Icons.person_outline_rounded),
                      SizedBox(height: r.h(14)),
                      _buildField(r,
                          controller: _phoneCtrl,
                          label: 'Số điện thoại',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone),
                      SizedBox(height: r.h(14)),
                      _buildField(r,
                          controller: _addressCtrl,
                          label: 'Địa chỉ giao hàng',
                          icon: Icons.home_outlined,
                          maxLines: 2),
                      SizedBox(height: r.h(14)),
                      GestureDetector(
                        onTap: _pickAddress,
                        child: Container(
                          padding: r.sym(16, 12),
                          decoration: BoxDecoration(
                            color: AppColors.primary
                                .withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(
                                AppColors.radiusMd),
                            border: Border.all(
                                color: AppColors.primary
                                    .withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.center,
                            children: [
                              Icon(Icons.location_on_outlined,
                                  size: r.icon(16),
                                  color: AppColors.primary),
                              SizedBox(width: r.w(8)),
                              Text('Chọn từ địa chỉ đã lưu',
                                  style: TextStyle(
                                      fontSize: r.sp(13),
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary)),
                            ],
                          ),
                        ),
                      ),
                    ]),
                  ),

                  SizedBox(height: r.h(24)),
                  _sectionHeader(r,
                      icon: Icons.shopping_bag_outlined,
                      title: 'Sản phẩm (${items.length})'),
                  SizedBox(height: r.h(14)),
                  ...items.map((item) => _buildProductItem(r, item)),
                ],
              ),
            ),
            _buildBottomBar(r, context, items, subtotal, total),
          ]);
        },
      ),
    );
  }

  Widget _buildAddressBadge(AppResponsive r) {
    final a = _selectedAddress!;
    return Container(
      padding: r.all(14),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppColors.radiusLg),
        border: Border.all(
            color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: Row(children: [
        Container(
          width: r.w(36), height: r.w(36),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppColors.radiusSm),
          ),
          child: Icon(Icons.check_circle_rounded,
              color: AppColors.success, size: r.icon(20)),
        ),
        SizedBox(width: r.w(12)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Text(a.label,
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: r.sp(13),
                        color: AppColors.textDark)),
                if (a.isDefault) ...[
                  SizedBox(width: r.w(6)),
                  Container(
                    padding: r.sym(6, 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(r.r(6)),
                    ),
                    child: Text('Mặc định',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: r.sp(9),
                            fontWeight: FontWeight.w700)),
                  ),
                ],
              ]),
              SizedBox(height: r.h(2)),
              Text(a.fullAddress,
                  style: TextStyle(
                      fontSize: r.sp(12), color: AppColors.textGrey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
        GestureDetector(
          onTap: _pickAddress,
          child: Text('Đổi',
              style: TextStyle(
                  fontSize: r.sp(13),
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary)),
        ),
      ]),
    );
  }

  Widget _sectionHeader(AppResponsive r,
      {required IconData icon, required String title, Widget? action}) {
    return Row(children: [
      Container(
        width: r.w(36), height: r.w(36),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppColors.radiusSm),
        ),
        child: Icon(icon, color: AppColors.primary, size: r.icon(18)),
      ),
      SizedBox(width: r.w(10)),
      Text(title,
          style: TextStyle(
              fontSize: r.sp(17),
              fontWeight: FontWeight.w900,
              color: AppColors.textDark,
              letterSpacing: -0.3)),
      if (action != null) ...[const Spacer(), action],
    ]);
  }

  Widget _buildField(AppResponsive r,
      {required TextEditingController controller,
        required String label,
        required IconData icon,
        TextInputType keyboardType = TextInputType.text,
        int maxLines = 1}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      onChanged: (_) {
        if (_selectedAddress != null) {
          setState(() => _selectedAddress = null);
        }
      },
      style: TextStyle(
          fontSize: r.sp(15),
          fontWeight: FontWeight.w500,
          color: AppColors.textDark),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon:
        Icon(icon, size: r.icon(20), color: AppColors.textGrey),
      ),
    );
  }

  Widget _buildProductItem(AppResponsive r, Map<String, dynamic> item) {
    final name  = item['name'] ?? '';
    final image = item['image'] ?? '';
    final price = (item['price'] as num?)?.toInt() ?? 0;
    final qty   = (item['quantity'] as num?)?.toInt() ?? 0;

    return Container(
      margin: EdgeInsets.only(bottom: r.h(12)),
      padding: r.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppColors.radiusXl),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.softShadow(),
      ),
      child: Row(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppColors.radiusMd),
          child: Image.network(image,
              width: r.w(72), height: r.w(72), fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: r.w(72), height: r.w(72),
                color: AppColors.surfaceVariant,
                child: Icon(Icons.image_not_supported_outlined,
                    color: AppColors.textLight, size: r.icon(24)),
              )),
        ),
        SizedBox(width: r.w(14)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w700,
                      fontSize: r.sp(14),
                      height: 1.3)),
              SizedBox(height: r.h(6)),
              Row(children: [
                Container(
                  padding: r.sym(8, 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.07),
                    borderRadius:
                    BorderRadius.circular(AppColors.radiusSm),
                  ),
                  child: Text('x$qty',
                      style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: r.sp(12))),
                ),
                SizedBox(width: r.w(8)),
                Text(_fmt(price),
                    style: TextStyle(
                        color: AppColors.textGrey,
                        fontSize: r.sp(13),
                        fontWeight: FontWeight.w500)),
              ]),
            ],
          ),
        ),
        Text(_fmt(price * qty),
            style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w900,
                fontSize: r.sp(15))),
      ]),
    );
  }

  Widget _buildBottomBar(AppResponsive r, BuildContext context,
      List<Map<String, dynamic>> items, int subtotal, int total) {
    return Container(
      padding: r.fromLTRB(20, 16, 20, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: AppColors.floatingShadow(),
      ),
      child: SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(children: [
            Text('Tạm tính',
                style: TextStyle(
                    fontSize: r.sp(13),
                    color: AppColors.textGrey,
                    fontWeight: FontWeight.w500)),
            const Spacer(),
            Text(_fmt(subtotal),
                style: TextStyle(
                    fontSize: r.sp(13),
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark)),
          ]),
          SizedBox(height: r.h(4)),
          Row(children: [
            Text('Phí vận chuyển',
                style: TextStyle(
                    fontSize: r.sp(13),
                    color: AppColors.textGrey,
                    fontWeight: FontWeight.w500)),
            const Spacer(),
            Text(_fmt(_shippingFee),
                style: TextStyle(
                    fontSize: r.sp(13),
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark)),
          ]),
          Padding(
            padding: EdgeInsets.symmetric(vertical: r.p(10)),
            child: const Divider(height: 1),
          ),
          Row(children: [
            Text('Tổng cộng',
                style: TextStyle(
                    fontSize: r.sp(15),
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark)),
            const Spacer(),
            Text(_fmt(total),
                style: TextStyle(
                    fontSize: r.sp(22),
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                    letterSpacing: -0.5)),
          ]),
          SizedBox(height: r.h(14)),
          GestureDetector(
            onTap: () => _goToPayment(items),
            child: Container(
              width: double.infinity,
              height: r.h(54),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius:
                BorderRadius.circular(AppColors.radiusMd),
                boxShadow:
                AppColors.coloredShadow(AppColors.primary),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.arrow_forward_rounded,
                      color: Colors.white, size: r.icon(20)),
                  SizedBox(width: r.w(8)),
                  Text('Tiếp tục thanh toán',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: r.sp(16),
                          fontWeight: FontWeight.w800)),
                ],
              ),
            ),
          ),
          SizedBox(height: r.h(8)),
        ]),
      ),
    );
  }
}
