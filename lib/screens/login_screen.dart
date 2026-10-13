// ============================================================
// سهلات المالك – شاشة تسجيل الدخول (Flutter)
// Mirrors: LoginScreen.tsx
// ============================================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sahalat_owner/services/api.dart';
import '../design_tokens.dart';
import '../l10n/strings_ar.dart';
import 'package:flutter/foundation.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController(text: 'owner@sahalat.sa');
  final _passwordController = TextEditingController();
  bool _showPassword = false;
  bool _twoFA = false;
  bool _otpSent = false;
  bool _loading = false;
  String _error = '';

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() { _error = ArStrings.enterCredentials; });
      return;
    }
    setState(() { _loading = true; _error = ''; });
    try {
      // final result = await MockApiService.instance.login(_emailController.text, _passwordController.text);
      final result = await API().login(_emailController.text, _passwordController.text);
      if (result['success'] == true && mounted) {
        context.go('/dashboard');
      } else {
        setState(() { _error = ArStrings.invalidCredentials; });
      }
    } catch (e) {
      if (kDebugMode) print(e);
      if (!mounted) return;
      setState(() { _error = ArStrings.invalidCredentials; });
    } finally {
      if (mounted) setState(() { _loading = false; });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AppGradients.dark),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  const SizedBox(height: 48),
                  // Logo
                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      gradient: AppGradients.primary,
                      borderRadius: BorderRadius.circular(AppRadius.xxl),
                      boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.5), blurRadius: 32, offset: const Offset(0, 8))],
                    ),
                    child: const Icon(Icons.shield_outlined, size: 40, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  const Text(ArStrings.appTitle, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white, fontFamily: 'Cairo', letterSpacing: -0.5)),
                  const SizedBox(height: 4),
                  Text(ArStrings.appSubtitle, style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.5), fontFamily: 'Cairo')),
                  const SizedBox(height: 32),

                  // Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(AppRadius.xxl),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _otpSent ? ArStrings.enterOtp : ArStrings.signIn,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white, fontFamily: 'Cairo'),
                        ),
                        const SizedBox(height: 20),

                        if (!_otpSent) ...[
                          // Email
                          _buildLabel(ArStrings.emailPhone),
                          const SizedBox(height: 6),
                          _buildInput(
                            controller: _emailController,
                            icon: Icons.email_outlined,
                            hint: 'owner@sahalat.sa',
                          ),
                          const SizedBox(height: 16),

                          // Password
                          _buildLabel(ArStrings.password),
                          const SizedBox(height: 6),
                          _buildInput(
                            controller: _passwordController,
                            icon: Icons.lock_outlined,
                            hint: '••••••••',
                            obscure: !_showPassword,
                            suffix: IconButton(
                              icon: Icon(
                                _showPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                color: Colors.white.withOpacity(0.4), size: 18,
                              ),
                              onPressed: () => setState(() => _showPassword = !_showPassword),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // 2FA Toggle
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              border: Border.all(color: Colors.white.withOpacity(0.08)),
                            ),
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () => setState(() => _twoFA = !_twoFA),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: 44, height: 24,
                                    decoration: BoxDecoration(
                                      color: _twoFA ? AppColors.primary : Colors.white.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: AnimatedAlign(
                                      duration: const Duration(milliseconds: 200),
                                      alignment: _twoFA ? Alignment.centerRight : Alignment.centerLeft,
                                      child: Container(
                                        width: 18, height: 18,
                                        margin: const EdgeInsets.all(3),
                                        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 4)]),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                                  const Text(ArStrings.twoFactorAuth, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white, fontFamily: 'Cairo')),
                                  Text(ArStrings.otpViaSms, style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.4), fontFamily: 'Cairo')),
                                ])),
                                Icon(Icons.fingerprint, size: 18, color: _twoFA ? const Color(0xFF818CF8) : Colors.white.withOpacity(0.3)),
                              ],
                            ),
                          ),
                        ] else ...[
                          Text(
                            'تم إرسال OTP إلى ${_emailController.text}. أدخل الرمز المكوّن من 6 أرقام أدناه.',
                            style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.6), fontFamily: 'Cairo'),
                            textAlign: TextAlign.right,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(6, (i) => Container(
                              width: 44, height: 52,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(AppRadius.md),
                                border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
                              ),
                              child: const Center(child: Text('', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white))),
                            )),
                          ),
                          const SizedBox(height: 12),
                          Center(
                            child: TextButton(
                              onPressed: () => setState(() => _otpSent = false),
                              child: const Text(ArStrings.resendOtp, style: TextStyle(fontSize: 12, color: Color(0xFF818CF8), fontFamily: 'Cairo')),
                            ),
                          ),
                        ],

                        if (_error.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.danger.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              border: Border.all(color: AppColors.danger.withOpacity(0.3)),
                            ),
                            child: Text(_error, style: const TextStyle(fontSize: 13, color: Color(0xFFFCA5A5), fontFamily: 'Cairo'), textAlign: TextAlign.right),
                          ),
                        ],

                        const SizedBox(height: 16),

                        // Login button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                            ),
                            child: _loading
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : Text(
                                  _otpSent ? ArStrings.verifySignIn : ArStrings.signIn,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white, fontFamily: 'Cairo'),
                                ),
                          ),
                        ),

                        const SizedBox(height: 12),
                        Center(
                          child: TextButton(
                            onPressed: () => context.go('/dashboard'),
                            child: Text(ArStrings.demoSkip, style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.4), fontFamily: 'Cairo')),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  Text('${ArStrings.appTitle} · ${ArStrings.version} · ${ArStrings.secureConnection}',
                    style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.25), fontFamily: 'Cairo'),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.5), letterSpacing: 0.5, fontFamily: 'Cairo'));
  }

  Widget _buildInput({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    bool obscure = false,
    Widget? suffix,
  }) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          if (suffix != null) suffix,
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscure,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 14, color: Colors.white, fontFamily: 'Cairo'),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontFamily: 'Cairo'),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Icon(icon, size: 16, color: Colors.white.withOpacity(0.4)),
          const SizedBox(width: 16),
        ],
      ),
    );
  }
}
