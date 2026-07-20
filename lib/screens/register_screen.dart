import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../constants/app_colors.dart';
import '../utils/app_responsive.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _fullNameCtrl     = TextEditingController();
  final _emailCtrl        = TextEditingController();
  final _passCtrl         = TextEditingController();
  final _confirmPassCtrl  = TextEditingController();

  bool _obscurePass    = true;
  bool _obscureConfirm = true;
  bool _isLoading      = false;

  late final AnimationController _fadeCtrl;
  late final Animation<double>   _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 500),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _fullNameCtrl.dispose(); _emailCtrl.dispose();
    _passCtrl.dispose(); _confirmPassCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  bool _isValidEmail(String e) =>
      RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$').hasMatch(e);

  Future<void> _register() async {
    final name    = _fullNameCtrl.text.trim();
    final email   = _emailCtrl.text.trim();
    final pass    = _passCtrl.text.trim();
    final confirm = _confirmPassCtrl.text.trim();

    if (name.isEmpty || email.isEmpty || pass.isEmpty || confirm.isEmpty) {
      _showSnack('Vui lòng nhập đầy đủ thông tin', isError: true); return;
    }
    if (!_isValidEmail(email)) {
      _showSnack('Email không hợp lệ', isError: true); return;
    }
    if (pass.length < 6) {
      _showSnack('Mật khẩu phải có ít nhất 6 ký tự', isError: true); return;
    }
    if (pass != confirm) {
      _showSnack('Mật khẩu xác nhận không khớp', isError: true); return;
    }

    setState(() => _isLoading = true);
    final error = await AuthService()
        .register(fullName: name, email: email, password: pass);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error == null) {
      _showSnack('Đăng ký thành công!');
      Navigator.pop(context);
    } else {
      _showSnack(error, isError: true);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? AppColors.accentRed : AppColors.success,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final r = AppResponsive(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Header banner ──────────────────────────────────────
          Positioned(
            top: 0, left: 0, right: 0,
            height: r.h(200),
            child: Container(
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(r.r(36)),
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: -r.h(30), right: -r.w(20),
                    child: Container(
                      width: r.w(140), height: r.w(140),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.07),
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: r.fromLTRB(24, 8, 16, 0),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: r.w(40), height: r.w(40),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                borderRadius:
                                BorderRadius.circular(AppColors.radiusSm),
                              ),
                              child: Icon(Icons.arrow_back_rounded,
                                  color: Colors.white, size: r.icon(20)),
                            ),
                          ),
                          SizedBox(width: r.w(16)),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Tạo tài khoản',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: r.sp(24),
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.4,
                                    )),
                                SizedBox(height: r.h(2)),
                                Text('Tham gia cộng đồng LegoKing',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: r.sp(13),
                                    )),
                              ],
                            ),
                          ),
                          Container(
                            width: r.w(56), height: r.w(56),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius:
                              BorderRadius.circular(AppColors.radiusMd),
                              border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.2)),
                            ),
                            child: Icon(Icons.person_add_rounded,
                                color: AppColors.secondary, size: r.icon(28)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Form ────────────────────────────────────────────────
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  top:    r.h(160),
                  left:   r.p(20),
                  right:  r.p(20),
                  bottom: MediaQuery.of(context).viewInsets.bottom + r.h(24),
                ),
                child: Column(
                  children: [
                    // Info banner
                    Container(
                      padding: r.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.06),
                        borderRadius:
                        BorderRadius.circular(AppColors.radiusLg),
                        border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.14)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.verified_user_outlined,
                              color: AppColors.primary, size: r.icon(20)),
                          SizedBox(width: r.w(12)),
                          Expanded(
                            child: Text(
                              'Theo dõi đơn hàng, lưu giỏ hàng và '
                                  'nhận ưu đãi độc quyền từ LegoKing.',
                              style: TextStyle(
                                color: AppColors.textMedium,
                                fontSize: r.sp(13),
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: r.h(16)),

                    // Form card
                    Container(
                      padding: r.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                        BorderRadius.circular(AppColors.radiusXxl),
                        boxShadow: AppColors.floatingShadow(),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLabel(r, 'Họ và tên'),
                          _buildField(r,
                              controller: _fullNameCtrl,
                              hint: 'Nguyễn Văn A',
                              icon: Icons.person_outline_rounded),
                          SizedBox(height: r.h(16)),
                          _buildLabel(r, 'Email'),
                          _buildField(r,
                              controller: _emailCtrl,
                              hint: 'email@example.com',
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress),
                          SizedBox(height: r.h(16)),
                          _buildLabel(r, 'Mật khẩu'),
                          _buildField(r,
                              controller: _passCtrl,
                              hint: 'Tối thiểu 6 ký tự',
                              icon: Icons.lock_outline_rounded,
                              obscure: _obscurePass,
                              suffix: _eyeBtn(r,
                                  visible: _obscurePass,
                                  onTap: () => setState(
                                          () => _obscurePass = !_obscurePass))),
                          SizedBox(height: r.h(16)),
                          _buildLabel(r, 'Xác nhận mật khẩu'),
                          _buildField(r,
                              controller: _confirmPassCtrl,
                              hint: 'Nhập lại mật khẩu',
                              icon: Icons.lock_reset_rounded,
                              obscure: _obscureConfirm,
                              textInputAction: TextInputAction.done,
                              suffix: _eyeBtn(r,
                                  visible: _obscureConfirm,
                                  onTap: () => setState(
                                          () => _obscureConfirm =
                                      !_obscureConfirm))),
                          SizedBox(height: r.h(24)),
                          _buildRegisterBtn(r),
                        ],
                      ),
                    ),

                    SizedBox(height: r.h(20)),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Đã có tài khoản?',
                            style: TextStyle(
                                color: AppColors.textGrey,
                                fontSize: r.sp(14))),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            padding:
                            EdgeInsets.symmetric(horizontal: r.p(6)),
                          ),
                          child: Text('Đăng nhập ngay',
                              style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: r.sp(14))),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  Widget _buildLabel(AppResponsive r, String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: r.h(8)),
      child: Text(label,
          style: TextStyle(
            fontSize: r.sp(13),
            fontWeight: FontWeight.w700,
            color: AppColors.textMedium,
            letterSpacing: 0.2,
          )),
    );
  }

  Widget _buildField(
      AppResponsive r, {
        required TextEditingController controller,
        required String hint,
        required IconData icon,
        bool obscure = false,
        Widget? suffix,
        TextInputType keyboardType = TextInputType.text,
        TextInputAction textInputAction = TextInputAction.next,
      }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      style: TextStyle(
        fontSize: r.sp(15),
        fontWeight: FontWeight.w500,
        color: AppColors.textDark,
      ),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.textGrey, size: r.icon(20)),
        suffixIcon: suffix,
      ),
    );
  }

  Widget _eyeBtn(AppResponsive r,
      {required bool visible, required VoidCallback onTap}) {
    return IconButton(
      icon: Icon(
        visible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        color: AppColors.textGrey,
        size: r.icon(20),
      ),
      onPressed: onTap,
    );
  }

  Widget _buildRegisterBtn(AppResponsive r) {
    return GestureDetector(
      onTap: _isLoading ? null : _register,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        height: r.h(56),
        decoration: BoxDecoration(
          gradient:     _isLoading ? null : AppColors.primaryGradient,
          color:        _isLoading ? AppColors.border : null,
          borderRadius: BorderRadius.circular(AppColors.radiusLg),
          boxShadow:    _isLoading
              ? null
              : AppColors.coloredShadow(AppColors.primary),
        ),
        child: Center(
          child: _isLoading
              ? SizedBox(
            width:  r.w(22),
            height: r.w(22),
            child: const CircularProgressIndicator(
                color: Colors.white, strokeWidth: 2.5),
          )
              : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_rounded,
                  color: Colors.white, size: r.icon(20)),
              SizedBox(width: r.w(8)),
              Text('Tạo tài khoản',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: r.sp(16),
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
