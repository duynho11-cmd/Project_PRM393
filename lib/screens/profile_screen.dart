import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color primaryBlue = Color(0xFF4A90E2);
  static const Color darkBlue = Color(0xFF0B4DBA);
  static const Color primaryYellow = Color(0xFFFFD93D);
  static const Color bgColor = Color(0xFFF8FAFC);
  static const Color textDark = Color(0xFF111827);
  static const Color textGrey = Color(0xFF64748B);

  String fullName = 'Khách hàng';
  String email = '';
  String role = 'customer';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      setState(() => isLoading = false);
      return;
    }

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (!mounted) return;

    setState(() {
      fullName = doc.data()?['fullName'] ?? user.displayName ?? 'Khách hàng';
      email = user.email ?? '';
      role = doc.data()?['role'] ?? 'customer';
      isLoading = false;
    });
  }

  Future<void> logout() async {
    await AuthService().logout();

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
          (route) => false,
    );
  }

  Future<void> changePassword() async {
    if (email.isEmpty) return;

    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Link đổi mật khẩu đã được gửi vào email"),
      ),
    );
  }

  String getRoleText(String role) {
    switch (role) {
      case 'seller':
        return 'Nhà bán hàng';
      case 'admin':
        return 'Quản trị viên';
      case 'customer':
        return 'Khách hàng';
      default:
        return role;
    }
  }

  Widget buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            darkBlue,
            primaryBlue,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: darkBlue.withOpacity(0.18),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: Colors.white.withOpacity(0.35),
                width: 1.5,
              ),
            ),
            child: const Icon(
              Icons.person_rounded,
              size: 58,
              color: primaryYellow,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            fullName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            email,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14.5,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: primaryYellow,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              getRoleText(role),
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w900,
                fontSize: 12.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMenuSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: textDark,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget menuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color color = darkBlue,
    String? subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: textDark,
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: subtitle == null
            ? null
            : Text(
          subtitle,
          style: const TextStyle(
            color: textGrey,
            fontSize: 12.5,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: textGrey,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget buildLoading() {
    return const Center(
      child: CircularProgressIndicator(color: darkBlue),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text(
          "Cá nhân",
          style: TextStyle(
            color: textDark,
            fontWeight: FontWeight.w800,
          ),
        ),
        backgroundColor: bgColor,
        foregroundColor: textDark,
        elevation: 0,
        centerTitle: false,
      ),
      body: isLoading
          ? buildLoading()
          : RefreshIndicator(
        color: darkBlue,
        onRefresh: loadUser,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            buildProfileHeader(),

            const SizedBox(height: 26),

            buildMenuSection(
              title: "Tài khoản",
              children: [
                menuItem(
                  icon: Icons.edit_outlined,
                  title: "Chỉnh sửa hồ sơ",
                  subtitle: "Cập nhật tên và thông tin cá nhân",
                  onTap: () async {
                    final updated = await Navigator.pushNamed(
                      context,
                      '/edit-profile',
                    );

                    if (updated == true) {
                      loadUser();
                    }
                  },
                ),
                menuItem(
                  icon: Icons.lock_outline_rounded,
                  title: "Đổi mật khẩu",
                  subtitle: "Gửi link đổi mật khẩu qua email",
                  onTap: changePassword,
                ),
                menuItem(
                  icon: Icons.location_on_outlined,
                  title: "Địa chỉ của tôi",
                  subtitle: "Quản lý địa chỉ nhận hàng",
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Sẽ làm màn My Addresses sau"),
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 14),

            buildMenuSection(
              title: "Mua hàng",
              children: [
                menuItem(
                  icon: Icons.receipt_long_rounded,
                  title: "Đơn hàng của tôi",
                  subtitle: "Theo dõi trạng thái đơn hàng",
                  onTap: () {
                    Navigator.pushNamed(context, '/orders');
                  },
                ),
              ],
            ),

            if (role == 'seller') ...[
              const SizedBox(height: 14),
              buildMenuSection(
                title: "Nhà bán hàng",
                children: [
                  menuItem(
                    icon: Icons.storefront_rounded,
                    title: "Quản lý đơn hàng",
                    subtitle: "Xác nhận và theo dõi đơn hàng",
                    onTap: () {
                      Navigator.pushNamed(context, '/seller-orders');
                    },
                  ),
                  menuItem(
                    icon: Icons.inventory_2_outlined,
                    title: "Quản lý sản phẩm",
                    subtitle: "Thêm, sửa và kiểm tra kho sản phẩm",
                    onTap: () {
                      Navigator.pushNamed(context, '/seller-products');
                    },
                  ),
                ],
              ),
            ],

            const SizedBox(height: 14),

            buildMenuSection(
              title: "Hệ thống",
              children: [
                menuItem(
                  icon: Icons.logout_rounded,
                  title: "Đăng xuất",
                  subtitle: "Thoát khỏi tài khoản hiện tại",
                  color: Colors.red,
                  onTap: logout,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}