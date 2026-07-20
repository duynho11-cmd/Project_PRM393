import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../models/address_model.dart';
import '../services/address_service.dart';
import '../utils/app_responsive.dart';

class AddEditAddressScreen extends StatefulWidget {
  final AddressModel? address;
  const AddEditAddressScreen({super.key, this.address});

  @override
  State<AddEditAddressScreen> createState() =>
      _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends State<AddEditAddressScreen> {
  final _formKey       = GlobalKey<FormState>();
  late final TextEditingController _fullNameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _streetCtrl;
  late final TextEditingController _wardCtrl;
  late final TextEditingController _districtCtrl;
  late final TextEditingController _provinceCtrl;

  String _selectedLabel = 'Nhà riêng';
  bool   _isDefault     = false;
  bool   _isSaving      = false;

  bool get _isEditing => widget.address != null;
  static const _labels = ['Nhà riêng', 'Công ty', 'Văn phòng', 'Nhà kho'];

  @override
  void initState() {
    super.initState();
    final a = widget.address;
    _fullNameCtrl  = TextEditingController(text: a?.fullName  ?? '');
    _phoneCtrl     = TextEditingController(text: a?.phone     ?? '');
    _streetCtrl    = TextEditingController(text: a?.street    ?? '');
    _wardCtrl      = TextEditingController(text: a?.ward      ?? '');
    _districtCtrl  = TextEditingController(text: a?.district  ?? '');
    _provinceCtrl  = TextEditingController(text: a?.province  ?? '');
    _selectedLabel = a?.label     ?? 'Nhà riêng';
    _isDefault     = a?.isDefault ?? false;
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose(); _phoneCtrl.dispose();
    _streetCtrl.dispose();  _wardCtrl.dispose();
    _districtCtrl.dispose(); _provinceCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final address = AddressModel(
      id:        widget.address?.id ?? '',
      label:     _selectedLabel,
      fullName:  _fullNameCtrl.text.trim(),
      phone:     _phoneCtrl.text.trim(),
      street:    _streetCtrl.text.trim(),
      ward:      _wardCtrl.text.trim(),
      district:  _districtCtrl.text.trim(),
      province:  _provinceCtrl.text.trim(),
      isDefault: _isDefault,
      createdAt: widget.address?.createdAt ?? DateTime.now(),
    );

    final svc = AddressService();
    final err = _isEditing
        ? await svc.updateAddress(address)
        : await svc.addAddress(address);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (err == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            _isEditing ? 'Đã cập nhật địa chỉ' : 'Đã thêm địa chỉ mới'),
        backgroundColor: AppColors.success,
      ));
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(err),
        backgroundColor: AppColors.accentRed,
      ));
    }
  }

  IconData _labelIcon(String label) {
    switch (label.toLowerCase()) {
      case 'công ty':
      case 'văn phòng': return Icons.business_outlined;
      case 'nhà kho':   return Icons.warehouse_outlined;
      default:          return Icons.home_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEditing ? 'Chỉnh sửa địa chỉ' : 'Thêm địa chỉ mới'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: r.fromLTRB(20, 8, 20, 120),
          children: [
            // ── Label chips ──────────────────────────────────────
            _sectionTitle(r, 'Loại địa chỉ'),
            SizedBox(height: r.h(10)),
            Wrap(
              spacing: r.w(10),
              runSpacing: r.h(10),
              children: _labels.map((l) {
                final selected = _selectedLabel == l;
                return GestureDetector(
                  onTap: () => setState(() => _selectedLabel = l),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: r.sym(16, 10),
                    decoration: BoxDecoration(
                      color:  selected ? AppColors.primary : Colors.white,
                      borderRadius:
                      BorderRadius.circular(AppColors.radiusMd),
                      border: Border.all(
                          color: selected
                              ? AppColors.primary
                              : AppColors.border),
                      boxShadow: selected
                          ? AppColors.coloredShadow(AppColors.primary)
                          : AppColors.softShadow(),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_labelIcon(l),
                            size: r.icon(16),
                            color: selected
                                ? Colors.white
                                : AppColors.textGrey),
                        SizedBox(width: r.w(6)),
                        Text(l,
                            style: TextStyle(
                                fontSize: r.sp(14),
                                fontWeight: FontWeight.w600,
                                color: selected
                                    ? Colors.white
                                    : AppColors.textMedium)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            SizedBox(height: r.h(24)),

            // ── Recipient ────────────────────────────────────────
            _sectionTitle(r, 'Thông tin người nhận'),
            SizedBox(height: r.h(12)),
            _card(r, children: [
              _field(r,
                  controller: _fullNameCtrl,
                  label: 'Họ và tên', hint: 'Nguyễn Văn A',
                  icon: Icons.person_outline_rounded,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Vui lòng nhập họ tên' : null),
              SizedBox(height: r.h(16)),
              _field(r,
                  controller: _phoneCtrl,
                  label: 'Số điện thoại', hint: '0912 345 678',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty)
                      return 'Vui lòng nhập số điện thoại';
                    if (!RegExp(r'^[0-9]{9,11}$')
                        .hasMatch(v.trim().replaceAll(' ', '')))
                      return 'Số điện thoại không hợp lệ';
                    return null;
                  }),
            ]),

            SizedBox(height: r.h(20)),

            // ── Address detail ───────────────────────────────────
            _sectionTitle(r, 'Chi tiết địa chỉ'),
            SizedBox(height: r.h(12)),
            _card(r, children: [
              _field(r,
                  controller: _streetCtrl,
                  label: 'Số nhà, tên đường', hint: '123 Nguyễn Trãi',
                  icon: Icons.home_outlined,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Vui lòng nhập số nhà / đường' : null),
              SizedBox(height: r.h(16)),
              _field(r,
                  controller: _wardCtrl,
                  label: 'Phường / Xã', hint: 'Phường Bến Thành',
                  icon: Icons.location_city_outlined,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Vui lòng nhập phường/xã' : null),
              SizedBox(height: r.h(16)),
              _field(r,
                  controller: _districtCtrl,
                  label: 'Quận / Huyện', hint: 'Quận 1',
                  icon: Icons.map_outlined,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Vui lòng nhập quận/huyện' : null),
              SizedBox(height: r.h(16)),
              _field(r,
                  controller: _provinceCtrl,
                  label: 'Tỉnh / Thành phố', hint: 'TP. Hồ Chí Minh',
                  icon: Icons.location_on_outlined,
                  textInputAction: TextInputAction.done,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Vui lòng nhập tỉnh/thành phố' : null),
            ]),

            SizedBox(height: r.h(20)),

            // ── Default toggle ───────────────────────────────────
            GestureDetector(
              onTap: () => setState(() => _isDefault = !_isDefault),
              child: Container(
                padding: r.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.circular(AppColors.radiusXl),
                  border: Border.all(
                      color: _isDefault
                          ? AppColors.primary.withValues(alpha: 0.4)
                          : AppColors.border),
                  boxShadow: AppColors.softShadow(),
                ),
                child: Row(children: [
                  Container(
                    width: r.w(40), height: r.w(40),
                    decoration: BoxDecoration(
                      color: _isDefault
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : AppColors.surfaceVariant,
                      borderRadius:
                      BorderRadius.circular(AppColors.radiusMd),
                    ),
                    child: Icon(Icons.check_circle_rounded,
                        color: _isDefault
                            ? AppColors.primary
                            : AppColors.textLight,
                        size: r.icon(22)),
                  ),
                  SizedBox(width: r.w(14)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Đặt làm địa chỉ mặc định',
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: r.sp(14),
                                color: AppColors.textDark)),
                        SizedBox(height: r.h(2)),
                        Text('Tự động điền khi thanh toán',
                            style: TextStyle(
                                fontSize: r.sp(12),
                                color: AppColors.textGrey)),
                      ],
                    ),
                  ),
                  Switch.adaptive(
                    value: _isDefault,
                    activeThumbColor: Colors.white,
                    activeTrackColor: AppColors.primary,
                    onChanged: (v) => setState(() => _isDefault = v),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),

      // ── Save button ──────────────────────────────────────────────
      bottomNavigationBar: Container(
        padding: r.fromLTRB(20, 12, 20, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: AppColors.floatingShadow(),
        ),
        child: SafeArea(
          child: GestureDetector(
            onTap: _isSaving ? null : _save,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              height: r.h(54),
              decoration: BoxDecoration(
                gradient: _isSaving ? null : AppColors.primaryGradient,
                color:    _isSaving ? AppColors.border : null,
                borderRadius:
                BorderRadius.circular(AppColors.radiusMd),
                boxShadow: _isSaving
                    ? null
                    : AppColors.coloredShadow(AppColors.primary),
              ),
              child: Center(
                child: _isSaving
                    ? SizedBox(
                    width:  r.w(22), height: r.w(22),
                    child: const CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.5))
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                        _isEditing
                            ? Icons.save_rounded
                            : Icons.add_location_alt_rounded,
                        color: Colors.white, size: r.icon(20)),
                    SizedBox(width: r.w(8)),
                    Text(
                        _isEditing ? 'Lưu thay đổi' : 'Thêm địa chỉ',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: r.sp(16),
                            fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(AppResponsive r, String title) {
    return Text(title.toUpperCase(),
        style: TextStyle(
            fontSize: r.sp(11),
            fontWeight: FontWeight.w800,
            color: AppColors.textLight,
            letterSpacing: 1.2));
  }

  Widget _card(AppResponsive r, {required List<Widget> children}) {
    return Container(
      padding: r.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppColors.radiusXl),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.softShadow(),
      ),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children),
    );
  }

  Widget _field(
      AppResponsive r, {
        required TextEditingController controller,
        required String label,
        required String hint,
        required IconData icon,
        String? Function(String?)? validator,
        TextInputType keyboardType = TextInputType.text,
        TextInputAction textInputAction = TextInputAction.next,
      }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      style: TextStyle(
          fontSize: r.sp(15),
          fontWeight: FontWeight.w500,
          color: AppColors.textDark),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon:
        Icon(icon, size: r.icon(20), color: AppColors.textGrey),
      ),
    );
  }
}
