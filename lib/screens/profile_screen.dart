import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../services/auth_service.dart';
import '../utils/app_responsive.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _fullName  = 'Khách hàng';
  String _email     = '';
  String _role      = 'customer';
  bool   _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) { setState(() => _isLoading = false); return; }
    final doc = await FirebaseFirestore.instance
        .collection('users').doc(user.uid).get();
    if (!mounted) return;
    setState(() {
      _fullName = doc.data()?['fullName'] ?? user.displayName ?? 'Khách hàng';
      _email    = user.email ?? '';
      _role     = doc.data()?['role'] ?? 'customer';
      _isLoading = false;
    });
  }

  Future<void> _logout() async {
    await AuthService().logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }

  Future<void> _changePassword() async {
    if (_email.isEmpty) return;
    await FirebaseAuth.instance.sendPasswordResetEmail(email: _email);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Link đổi mật khẩu đã được gửi vào email'),
      backgroundColor: AppColors.success,
    ));
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'seller': return 'Nhà bán hàng';
      case 'admin':  return 'Quản trị viên';
      default:       return 'Khách hàng';
    }
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'seller': return AppColors.secondary;
      case 'admin':  return AppColors.accentRed;
      default:       return AppColors.primary;
    }
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Cá nhân'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, size: r.icon(22)),
            color: AppColors.textGrey,
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
          child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _loadUser,
        child: ListView(
          padding: r.fromLTRB(20, 8, 20, 32),
          children: [
            _buildHeader(r),
            SizedBox(height: r.h(24)),

            _buildSection(r, 'Tài khoản', [
              _menuItem(r,
                icon: Icons.edit_outlined,
                iconBg: AppColors.primary,
                title: 'Chỉnh sửa hồ sơ',
                subtitle: 'Cập nhật tên và thông tin cá nhân',
                onTap: () async {
                  final updated = await Navigator.pushNamed(
                      context, '/edit-profile');
                  if (updated == true) _loadUser();
                },
              ),
              _menuItem(r,
                icon: Icons.lock_outline_rounded,
                iconBg: const Color(0xFF8B5CF6),
                title: 'Đổi mật khẩu',
                subtitle: 'Gửi link đổi mật khẩu qua email',
                onTap: _changePassword,
              ),
              _menuItem(r,
                icon: Icons.location_on_outlined,
                iconBg: AppColors.success,
                title: 'Địa chỉ của tôi',
                subtitle: 'Quản lý địa chỉ nhận hàng',
                onTap: () =>
                    Navigator.pushNamed(context, '/my-addresses'),
              ),
            ]),

            SizedBox(height: r.h(16)),
            _buildSection(r, 'Mua hàng', [
              _menuItem(r,
                icon: Icons.receipt_long_rounded,
                iconBg: AppColors.secondary,
                title: 'Đơn hàng của tôi',
                subtitle: 'Theo dõi trạng thái đơn hàng',
                onTap: () => Navigator.pushNamed(context, '/orders'),
              ),
            ]),

            if (_role == 'seller') ...[
              SizedBox(height: r.h(16)),
              _buildSection(r, 'Nhà bán hàng', [
                _menuItem(r,
                  icon: Icons.storefront_rounded,
                  iconBg: const Color(0xFFFB7185),
                  title: 'Quản lý đơn hàng',
                  subtitle: 'Xác nhận và theo dõi đơn hàng',
                  onTap: () =>
                      Navigator.pushNamed(context, '/seller-orders'),
                ),
                _menuItem(r,
                  icon: Icons.inventory_2_outlined,
                  iconBg: AppColors.primary,
                  title: 'Quản lý sản phẩm',
                  subtitle: 'Thêm, sửa và kiểm tra kho',
                  onTap: () =>
                      Navigator.pushNamed(context, '/seller-products'),
                ),
              ]),
            ],

            SizedBox(height: r.h(16)),
            // Logout
            GestureDetector(
              onTap: _logout,
              child: Container(
                padding: r.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.circular(AppColors.radiusXl),
                  border: Border.all(
                      color: AppColors.accentRed
                          .withValues(alpha: 0.2)),
                  boxShadow: AppColors.softShadow(),
                ),
                child: Row(children: [
                  Container(
                    width: r.w(40), height: r.w(40),
                    decoration: BoxDecoration(
                      color: AppColors.accentRed
                          .withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(
                          AppColors.radiusMd),
                    ),
                    child: Icon(Icons.logout_rounded,
                        color: AppColors.accentRed,
                        size: r.icon(20)),
                  ),
                  SizedBox(width: r.w(14)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Đăng xuất',
                            style: TextStyle(
                                color: AppColors.accentRed,
                                fontWeight: FontWeight.w800,
                                fontSize: r.sp(15))),
                        Text('Thoát khỏi tài khoản hiện tại',
                            style: TextStyle(
                                color: AppColors.textGrey,
                                fontSize: r.sp(12))),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded,
                      color: AppColors.accentRed,
                      size: r.icon(20)),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppResponsive r) {
    final roleColor = _roleColor(_role);
    return Container(
      padding: r.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppColors.radiusXxl),
        boxShadow: AppColors.coloredShadow(AppColors.primary),
      ),
      child: Row(children: [
        // Avatar
        Container(
          width: r.w(72), height: r.w(72),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(AppColors.radiusLg),
            border: Border.all(
                color: Colors.white.withValues(alpha: 0.35), width: 2),
          ),
          child: Center(
            child: Text(_initials(_fullName),
                style: TextStyle(
                    color: Colors.white,
                    fontSize: r.sp(24),
                    fontWeight: FontWeight.w900)),
          ),
        ),
        SizedBox(width: r.w(16)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_fullName,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: r.sp(18),
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.3)),
              SizedBox(height: r.h(4)),
              Text(_email,
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: r.sp(12),
                      fontWeight: FontWeight.w400),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
              SizedBox(height: r.h(10)),
              Container(
                padding: r.sym(10, 4),
                decoration: BoxDecoration(
                  color: roleColor,
                  borderRadius: BorderRadius.circular(r.r(20)),
                ),
                child: Text(_roleLabel(_role),
                    style: TextStyle(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w800,
                        fontSize: r.sp(11))),
              ),
            ],
          ),
        ),
        // Edit shortcut
        GestureDetector(
          onTap: () async {
            final updated =
            await Navigator.pushNamed(context, '/edit-profile');
            if (updated == true) _loadUser();
          },
          child: Container(
            width: r.w(36), height: r.w(36),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(AppColors.radiusSm),
            ),
            child: Icon(Icons.edit_outlined,
                color: Colors.white, size: r.icon(18)),
          ),
        ),
      ]),
    );
  }

  Widget _buildSection(
      AppResponsive r, String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: r.p(4), bottom: r.p(10)),
          child: Text(title.toUpperCase(),
              style: TextStyle(
                  fontSize: r.sp(11),
                  fontWeight: FontWeight.w800,
                  color: AppColors.textLight,
                  letterSpacing: 1.2)),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppColors.radiusXl),
            border: Border.all(color: AppColors.border),
            boxShadow: AppColors.softShadow(),
          ),
          child: Column(
            children: items.asMap().entries.map((e) {
              final isLast = e.key == items.length - 1;
              return Column(children: [
                e.value,
                if (!isLast)
                  const Divider(height: 1, indent: 20, endIndent: 20),
              ]);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _menuItem(
      AppResponsive r, {
        required IconData icon,
        required Color iconBg,
        required String title,
        required String subtitle,
        required VoidCallback onTap,
      }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppColors.radiusXl),
      child: Padding(
        padding: r.sym(16, 12),
        child: Row(children: [
          Container(
            width: r.w(40), height: r.w(40),
            decoration: BoxDecoration(
              color: iconBg.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppColors.radiusMd),
            ),
            child:
            Icon(icon, color: iconBg, size: r.icon(20)),
          ),
          SizedBox(width: r.w(14)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w700,
                        fontSize: r.sp(14))),
                SizedBox(height: r.h(2)),
                Text(subtitle,
                    style: TextStyle(
                        color: AppColors.textGrey,
                        fontSize: r.sp(12))),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded,
              color: AppColors.textLight, size: r.icon(20)),
        ]),
      ),
    );
  }
}
