import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:client/core/services/auth_controller.dart';
import 'signin_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String otp;
  const ResetPasswordScreen({Key? key, required this.email, required this.otp}) : super(key: key);

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthController _authController = Get.find<AuthController>();

  void _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;
    final password = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();
    if (password != confirm) {
      Get.snackbar('Lỗi', 'Mật khẩu xác nhận không khớp', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }
    final success = await _authController.resetPassword(widget.email, password, widget.otp);
    if (success) {
      Get.snackbar('Thành công', 'Đổi mật khẩu thành công! Hãy đăng nhập lại.', backgroundColor: Colors.green, colorText: Colors.white);
      await Future.delayed(const Duration(seconds: 1));
      Get.offAll(() => SigninScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: const Text('Đổi mật khẩu mới')),
      body: Center(
        child: SingleChildScrollView(
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock_reset, size: 48, color: Theme.of(context).primaryColor),
                    const SizedBox(height: 12),
                    Text('Đổi mật khẩu mới', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Đặt lại mật khẩu cho email:', style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], fontSize: 15)),
                    Flexible(
                      child: Text(widget.email, style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).primaryColor), maxLines: 2, overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Mật khẩu mới',
                        prefixIcon: Icon(Icons.lock_outline),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Vui lòng nhập mật khẩu mới';
                        if (value.length < 6) return 'Mật khẩu phải có ít nhất 6 ký tự';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Xác nhận mật khẩu mới',
                        prefixIcon: Icon(Icons.lock_outline),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Vui lòng xác nhận mật khẩu mới';
                        if (value != _passwordController.text) return 'Mật khẩu xác nhận không khớp';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    Obx(() => SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          minimumSize: const Size(120, 44),
                          elevation: 2,
                        ),
                        onPressed: _authController.isLoading ? null : _handleResetPassword,
                        child: _authController.isLoading
                            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('Đổi mật khẩu', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                      ),
                    )),
                    Obx(() {
                      if (_authController.errorMessage.isNotEmpty) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            _authController.errorMessage,
                            style: const TextStyle(color: Colors.red),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 