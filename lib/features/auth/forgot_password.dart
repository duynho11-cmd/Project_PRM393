import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'reset_success.dart';
import 'package:firebase_auth/firebase_auth.dart';
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _authService = AuthService();
  final _emailController = TextEditingController();

  bool _isLoading = false;

  Future<void> _sendReset() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập email.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.resetPassword(email);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const ResetSuccessScreen(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String message = 'Gửi yêu cầu thất bại.';

      if (e.code == 'invalid-email') {
        message = 'Email không hợp lệ.';
      } else if (e.code == 'user-not-found') {
        message = 'Email này chưa được đăng ký.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            _header("Quên mật khẩu"),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  children: [
                    const SizedBox(height: 55),
                    Container(
                      width: 92,
                      height: 92,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE5E7EB),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.shield_outlined, size: 44),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      "Đừng lo lắng!",
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Nhập email gắn với tài khoản LegoKing của bạn để nhận hướng dẫn khôi phục.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Color(0xFF6B7280), height: 1.5),
                    ),
                    const SizedBox(height: 36),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Địa chỉ Email", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: "example@email.com",
                        prefixIcon: const Icon(Icons.email_outlined),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22),
                          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      "* Chúng tôi sẽ gửi một liên kết bảo mật đến email này để bạn đặt lại mật khẩu mới.",
                      style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _sendReset,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF111111),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text("Gửi yêu cầu  →", style: TextStyle(fontWeight: FontWeight.w900)),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text.rich(
                        TextSpan(
                          text: "Bạn nhớ mật khẩu? ",
                          children: [
                            TextSpan(
                              text: "Quay lại đăng nhập",
                              style: TextStyle(fontWeight: FontWeight.w900),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(String title) {
    return Container(
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          ),
          const Spacer(),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          const Spacer(),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}