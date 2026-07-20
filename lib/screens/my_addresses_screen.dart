import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../models/address_model.dart';
import '../services/address_service.dart';
import '../utils/app_responsive.dart';
import 'add_edit_address_screen.dart';

class MyAddressesScreen extends StatelessWidget {
  final bool selectionMode;
  const MyAddressesScreen({super.key, this.selectionMode = false});

  @override
  Widget build(BuildContext context) {
    final r   = AppResponsive(context);
    final svc = AddressService();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(selectionMode ? 'Chọn địa chỉ' : 'Địa chỉ của tôi'),
        actions: [
          TextButton.icon(
            onPressed: () => _openAddEdit(context, null),
            icon: Icon(Icons.add_rounded, size: r.icon(18)),
            label: Text('Thêm',
                style: TextStyle(
                    fontWeight: FontWeight.w700, fontSize: r.sp(14))),
            style: TextButton.styleFrom(
                foregroundColor: AppColors.primary),
          ),
        ],
      ),
      body: StreamBuilder<List<AddressModel>>(
        stream: svc.watchAddresses(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(
                    color: AppColors.primary));
          }
          final list = snap.data ?? [];
          if (list.isEmpty) return _buildEmpty(context, r);

          return ListView.separated(
            padding: r.fromLTRB(20, 12, 20, 100),
            itemCount: list.length,
            separatorBuilder: (_, __) => SizedBox(height: r.h(12)),
            itemBuilder: (_, i) => _AddressCard(
              r: r,
              address: list[i],
              selectionMode: selectionMode,
              onSelect: selectionMode
                  ? () => Navigator.pop(context, list[i])
                  : null,
              onEdit:       () => _openAddEdit(context, list[i]),
              onDelete:     () => _confirmDelete(context, r, list[i]),
              onSetDefault: () => _setDefault(context, list[i]),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddEdit(context, null),
        backgroundColor: AppColors.primary,
        elevation: 0,
        icon: Icon(Icons.add_location_alt_rounded,
            color: Colors.white, size: r.icon(22)),
        label: Text('Thêm địa chỉ',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: r.sp(14))),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context, AppResponsive r) {
    return Center(
      child: Padding(
        padding: r.symH(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: r.w(100), height: r.w(100),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppColors.radiusXl),
              ),
              child: Icon(Icons.location_on_outlined,
                  size: r.icon(52), color: AppColors.success),
            ),
            SizedBox(height: r.h(20)),
            Text('Chưa có địa chỉ nào',
                style: TextStyle(
                    fontSize: r.sp(20),
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark,
                    letterSpacing: -0.3)),
            SizedBox(height: r.h(8)),
            Text('Thêm địa chỉ nhận hàng để\nthanh toán nhanh hơn.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: r.sp(14),
                    color: AppColors.textGrey,
                    height: 1.6)),
            SizedBox(height: r.h(28)),
            GestureDetector(
              onTap: () => _openAddEdit(context, null),
              child: Container(
                padding: r.sym(28, 14),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(AppColors.radiusLg),
                  boxShadow: AppColors.coloredShadow(AppColors.primary),
                ),
                child: Text('Thêm địa chỉ đầu tiên',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: r.sp(15))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openAddEdit(BuildContext context, AddressModel? address) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => AddEditAddressScreen(address: address)),
    );
  }

  Future<void> _setDefault(
      BuildContext context, AddressModel address) async {
    if (address.isDefault) return;
    final err = await AddressService().setDefault(address.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content:
      Text(err ?? 'Đã đặt làm địa chỉ mặc định'),
      backgroundColor:
      err == null ? AppColors.success : AppColors.accentRed,
    ));
  }

  Future<void> _confirmDelete(
      BuildContext context, AppResponsive r, AddressModel address) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppColors.radiusXl)),
        title: Text('Xoá địa chỉ',
            style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: r.sp(18),
                color: AppColors.textDark)),
        content: Text(
            'Bạn có chắc muốn xoá địa chỉ "${address.label}" không?',
            style: TextStyle(
                color: AppColors.textGrey,
                fontSize: r.sp(14),
                height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Huỷ',
                style: TextStyle(
                    color: AppColors.textGrey, fontSize: r.sp(14))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Xoá',
                style: TextStyle(
                    color: AppColors.accentRed,
                    fontWeight: FontWeight.w700,
                    fontSize: r.sp(14))),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final err = await AddressService().deleteAddress(address.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(err ?? 'Đã xoá địa chỉ'),
      backgroundColor:
      err == null ? AppColors.success : AppColors.accentRed,
    ));
  }
}

// ─── Address Card ─────────────────────────────────────────────────────────────
class _AddressCard extends StatelessWidget {
  final AppResponsive  r;
  final AddressModel   address;
  final bool           selectionMode;
  final VoidCallback?  onSelect;
  final VoidCallback   onEdit;
  final VoidCallback   onDelete;
  final VoidCallback   onSetDefault;

  const _AddressCard({
    required this.r,
    required this.address,
    required this.selectionMode,
    required this.onEdit,
    required this.onDelete,
    required this.onSetDefault,
    this.onSelect,
  });

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
    final isDefault = address.isDefault;

    return GestureDetector(
      onTap: selectionMode ? onSelect : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppColors.radiusXl),
          border: Border.all(
            color: isDefault
                ? AppColors.primary.withValues(alpha: 0.5)
                : AppColors.border,
            width: isDefault ? 1.5 : 1,
          ),
          boxShadow: isDefault
              ? AppColors.coloredShadow(
              AppColors.primary.withValues(alpha: 0.35))
              : AppColors.softShadow(),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: r.fromLTRB(16, 14, 12, 0),
              child: Row(children: [
                Container(
                  width: r.w(38), height: r.w(38),
                  decoration: BoxDecoration(
                    color: isDefault
                        ? AppColors.primary.withValues(alpha: 0.10)
                        : AppColors.surfaceVariant,
                    borderRadius:
                    BorderRadius.circular(AppColors.radiusSm),
                  ),
                  child: Icon(_labelIcon(address.label),
                      size: r.icon(20),
                      color: isDefault
                          ? AppColors.primary
                          : AppColors.textGrey),
                ),
                SizedBox(width: r.w(10)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Text(address.label,
                            style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: r.sp(15),
                                color: AppColors.textDark)),
                        if (isDefault) ...[
                          SizedBox(width: r.w(8)),
                          Container(
                            padding: r.sym(8, 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius:
                              BorderRadius.circular(r.r(20)),
                            ),
                            child: Text('Mặc định',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: r.sp(10),
                                    fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ]),
                      Text(address.fullName,
                          style: TextStyle(
                              fontSize: r.sp(12),
                              color: AppColors.textGrey)),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert_rounded,
                      color: AppColors.textGrey, size: r.icon(20)),
                  shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(AppColors.radiusMd)),
                  elevation: 3,
                  onSelected: (val) {
                    if (val == 'edit')    onEdit();
                    if (val == 'delete')  onDelete();
                    if (val == 'default') onSetDefault();
                  },
                  itemBuilder: (_) => [
                    if (!isDefault)
                      PopupMenuItem(
                        value: 'default',
                        child: Row(children: [
                          Icon(Icons.check_circle_outline_rounded,
                              size: r.icon(18), color: AppColors.success),
                          SizedBox(width: r.w(10)),
                          Text('Đặt làm mặc định',
                              style: TextStyle(fontSize: r.sp(14))),
                        ]),
                      ),
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(children: [
                        Icon(Icons.edit_outlined,
                            size: r.icon(18), color: AppColors.primary),
                        SizedBox(width: r.w(10)),
                        Text('Chỉnh sửa',
                            style: TextStyle(fontSize: r.sp(14))),
                      ]),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(children: [
                        Icon(Icons.delete_outline_rounded,
                            size: r.icon(18), color: AppColors.accentRed),
                        SizedBox(width: r.w(10)),
                        Text('Xoá',
                            style: TextStyle(
                                fontSize: r.sp(14),
                                color: AppColors.accentRed)),
                      ]),
                    ),
                  ],
                ),
              ]),
            ),

            Padding(
              padding: r.sym(16, 10),
              child: const Divider(height: 1),
            ),

            // Address info
            Padding(
              padding: r.fromLTRB(16, 0, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoRow(r, Icons.phone_outlined, address.phone),
                  SizedBox(height: r.h(6)),
                  _infoRow(r, Icons.location_on_outlined,
                      address.fullAddress),
                ],
              ),
            ),

            // Action row
            if (selectionMode || !address.isDefault)
              Padding(
                padding: r.fromLTRB(12, 0, 12, 12),
                child: Row(children: [
                  if (!address.isDefault)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onSetDefault,
                        icon: Icon(
                            Icons.check_circle_outline_rounded,
                            size: r.icon(16)),
                        label: Text('Đặt mặc định',
                            style: TextStyle(fontSize: r.sp(13))),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.success,
                          side: BorderSide(
                              color: AppColors.success
                                  .withValues(alpha: 0.4)),
                          padding: EdgeInsets.symmetric(vertical: r.p(10)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  AppColors.radiusMd)),
                        ),
                      ),
                    ),
                  if (!address.isDefault && selectionMode)
                    SizedBox(width: r.w(10)),
                  if (selectionMode)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onSelect,
                        icon: Icon(Icons.check_rounded,
                            size: r.icon(16), color: Colors.white),
                        label: Text('Dùng địa chỉ này',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: r.sp(13))),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(vertical: r.p(10)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  AppColors.radiusMd)),
                        ),
                      ),
                    ),
                ]),
              ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(AppResponsive r, IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: r.icon(15), color: AppColors.textLight),
        SizedBox(width: r.w(7)),
        Expanded(
          child: Text(text,
              style: TextStyle(
                  fontSize: r.sp(13),
                  color: AppColors.textMedium,
                  height: 1.45)),
        ),
      ],
    );
  }
}
