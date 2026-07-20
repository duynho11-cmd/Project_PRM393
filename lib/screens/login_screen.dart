import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../constants/app_colors.dart';
import '../utils/app_responsive.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _obscure   = true;
  bool _isLoading = false;

  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _fadeAnim  = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailCtrl.text.trim();
    final pass  = _passCtrl.text.trim();
    if (email.isEmpty || pass.isEmpty) {
      _showSnack('Vui lòng nhập email và mật khẩu', isError: true);
      return;
    }
    setState(() => _isLoading = true);
    final error = await AuthService().login(email: email, password: pass);
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (error == null) {
      Navigator.pushReplacementNamed(context, '/home');
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
    final r    = AppResponsive(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Top gradient header ──────────────────────────────
          Positioned(
            top: 0, left: 0, right: 0,
            height: size.height * 0.38,
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(40),
                ),
              ),
              child: Stack(
                children: [
                  // Decorative circles
                  Positioned(
                    top: -r.h(40), right: -r.w(30),
                    child: Container(
                      width: r.w(180), height: r.w(180),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: r.h(20), left: -r.w(50),
                    child: Container(
                      width: r.w(140), height: r.w(140),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.06),
                      ),
                    ),
                  ),
                  // Logo + title
                  SafeArea(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: r.h(8)),
                          Hero(
                            tag: 'logo',
                            child: Container(
                              width: r.w(88), height: r.w(88),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(r.r(26)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.15),
                                    blurRadius: r.h(24),
                                    offset: Offset(0, r.h(10)),
                                  ),
                                ],
                              ),
                              padding: r.all(10),
                              child: Image.asset(
                                'assets/images/logo.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          SizedBox(height: r.h(16)),
                          Text(
                            'LegoKing',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: r.sp(28),
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            ),
                          ),
                          SizedBox(height: r.h(4)),
                          Text(
                            'Đăng nhập để tiếp tục',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.75),
                              fontSize: r.sp(14),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Scrollable form ──────────────────────────────────
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + r.h(24),
              ),
              child: Column(
                children: [
                  SizedBox(height: size.height * 0.38 - r.h(20)),

                  FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: Padding(
                        padding: r.symH(20),
                        child: Column(
                          children: [
                            // Form card
                            Container(
                              padding: r.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(
                                    AppColors.radiusXxl),
                                boxShadow: AppColors.floatingShadow(),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Chào mừng trở lại 👋',
                                    style: TextStyle(
                                      fontSize: r.sp(22),
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.textDark,
                                      letterSpacing: -0.4,
                                    ),
                                  ),
                                  SizedBox(height: r.h(4)),
                                  Text(
                                    'Nhập thông tin để đăng nhập',
                                    style: TextStyle(
                                      fontSize: r.sp(14),
                                      color: AppColors.textGrey,
                                    ),
                                  ),
                                  SizedBox(height: r.h(24)),

                                  _buildField(
                                    r: r,
                                    controller: _emailCtrl,
                                    hint: 'Email của bạn',
                                    icon: Icons.email_outlined,
                                    keyboardType: TextInputType.emailAddress,
                                  ),
                                  SizedBox(height: r.h(14)),

                                  _buildField(
                                    r: r,
                                    controller: _passCtrl,
                                    hint: 'Mật khẩu',
                                    icon: Icons.lock_outline_rounded,
                                    obscure: _obscure,
                                    suffix: IconButton(
                                      icon: Icon(
                                        _obscure
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: AppColors.textGrey,
                                        size: r.icon(20),
                                      ),
                                      onPressed: () =>
                                          setState(() => _obscure = !_obscure),
                                    ),
                                  ),

                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () => Navigator.pushNamed(
                                          context, '/forgot-password'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: AppColors.primary,
                                        padding: EdgeInsets.symmetric(
                                          vertical: r.p(4),
                                        ),
                                      ),
                                      child: Text(
                                        'Quên mật khẩu?',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: r.sp(13),
                                        ),
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: r.h(8)),

                                  _GradientButton(
                                    r: r,
                                    onTap: _isLoading ? null : _login,
                                    child: _isLoading
                                        ? SizedBox(
                                      width:  r.w(22),
                                      height: r.w(22),
                                      child: const CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                        : Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Đăng nhập',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: r.sp(16),
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 0.3,
                                          ),
                                        ),
                                        SizedBox(width: r.w(8)),
                                        Icon(
                                          Icons.arrow_forward_rounded,
                                          color: Colors.white,
                                          size: r.icon(18),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: r.h(20)),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Chưa có tài khoản?',
                                  style: TextStyle(
                                    color: AppColors.textGrey,
                                    fontSize: r.sp(14),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const RegisterScreen(),
                                    ),
                                  ),
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.primary,
                                    padding:
                                    EdgeInsets.symmetric(horizontal: r.p(6)),
                                  ),
                                  child: Text(
                                    'Đăng ký ngay',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: r.sp(14),
                                    ),
                                  ),
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required AppResponsive r,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
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
}

// ─── Reusable gradient button ─────────────────────────────────────────────────
class _GradientButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final AppResponsive r;

  const _GradientButton({
    required this.child,
    required this.r,
    this.onTap,
  });

  @override
  State<_GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<_GradientButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.96,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.r;
    return GestureDetector(
      onTapDown:  widget.onTap != null ? (_) => _ctrl.reverse() : null,
      onTapUp:    widget.onTap != null
          ? (_) { _ctrl.forward(); widget.onTap!(); }
          : null,
      onTapCancel: () => _ctrl.forward(),
      child: ScaleTransition(
        scale: _ctrl,
        child: Container(
          width: double.infinity,
          height: r.h(56),
          decoration: BoxDecoration(
            gradient: widget.onTap != null ? AppColors.primaryGradient : null,
            color:    widget.onTap == null ? AppColors.border : null,
            borderRadius: BorderRadius.circular(AppColors.radiusLg),
            boxShadow: widget.onTap != null
                ? AppColors.coloredShadow(AppColors.primary)
                : null,
          ),
          child: Center(child: widget.child),
        ),
      ),
    );
  }
}
