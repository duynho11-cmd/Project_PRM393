import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../constants/app_colors.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();
  bool isLoading = false;

  bool isValidEmail(String email) {
    return RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$').hasMatch(email);
  }

  Future<void> sendResetEmail() async {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Vui lòng nhập email"),
          backgroundColor: AppColors.accentRed,
        ),
      );
      return;
    }

    if (!isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Email không hợp lệ"),
          backgroundColor: AppColors.accentRed,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    final error = await AuthService().resetPassword(email);

    if (!mounted) return;

    setState(() => isLoading = false);

    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Link đặt lại mật khẩu đã được gửi vào email"),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AppColors.accentRed,
        ),
      );
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Widget buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: AppColors.primaryGradient,
        boxShadow: AppColors.premiumShadow(
          color: AppColors.primary.withOpacity(0.2),
          blur: 24,
          offset: const Offset(0, 10),
        ),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              "Khôi phục\nmật khẩu",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                height: 1.3,
                letterSpacing: -0.5,
              ),
            ),
          ),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.lock_reset_rounded,
              color: AppColors.secondary,
              size: 40,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.12),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: AppColors.primary,
            size: 22,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "Nhập email đã đăng ký. LegoKing sẽ gửi link đặt lại mật khẩu vào hộp thư của bạn.",
              style: TextStyle(
                color: AppColors.textGrey,
                fontSize: 14,
                height: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildEmailInput() {
    return TextField(
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.done,
      onSubmitted: (_) => sendResetEmail(),
      decoration: InputDecoration(
        labelText: "Email",
        labelStyle: const TextStyle(color: AppColors.textGrey, fontSize: 15),
        hintText: "example@gmail.com",
        hintStyle: const TextStyle(color: AppColors.textLight, fontSize: 15),
        prefixIcon: const Icon(
          Icons.email_outlined,
          color: AppColors.textGrey,
          size: 22,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(
            color: AppColors.border,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  Widget buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: AppColors.primaryGradient,
        boxShadow: AppColors.premiumShadow(
          color: AppColors.primary.withOpacity(0.25),
          blur: 16,
          offset: const Offset(0, 6),
        ),
      ),
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : sendResetEmail,
        icon: isLoading
            ? const SizedBox()
            : const Icon(Icons.send_rounded, color: Colors.white),
        label: isLoading
            ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2.5,
          ),
        )
            : const Text(
          "Gửi link đặt lại mật khẩu",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  Widget buildBackLoginButton() {
    return TextButton.icon(
      onPressed: () {
        Navigator.pop(context);
      },
      icon: const Icon(
        Icons.arrow_back_rounded,
        size: 18,
      ),
      label: const Text(
        "Quay lại đăng nhập",
        style: TextStyle(
          fontWeight: FontWeight.w800,
        ),
      ),
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Quên mật khẩu",
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w900,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        centerTitle: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            buildHeader(),

            const SizedBox(height: 24),

            buildInfoCard(),

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: AppColors.border),
                boxShadow: AppColors.premiumShadow(),
              ),
              child: Column(
                children: [
                  buildEmailInput(),
                  const SizedBox(height: 20),
                  buildSubmitButton(),
                ],
              ),
            ),

            const SizedBox(height: 18),

            buildBackLoginButton(),
          ],
        ),
      ),
    );
  }
}