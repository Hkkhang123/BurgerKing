import 'package:client/core/services/auth_controller.dart';
import 'package:client/shared/themes/app_textstyle.dart';
import 'package:client/features/home/main_screen.dart';
import 'package:client/features/auth/signup_screen.dart';
import 'package:client/shared/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:client/core/utils/google_auth_service.dart';
import 'package:client/features/auth/otp_verify_screen.dart';

class SigninScreen extends StatelessWidget {
  SigninScreen({super.key});

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final AuthController authController = Get.find<AuthController>();
    
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Text(
                  'Chào mừng quay trở lại',
                  style: AppTextStyle.withColor(
                    AppTextStyle.h1,
                    Theme.of(context).textTheme.bodyLarge!.color!,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Đăng nhập để tiếp tục mua hàng',
                  style: AppTextStyle.withColor(
                    AppTextStyle.bodyLarge,
                    isDark ? Colors.grey[400]! : Colors.grey[600]!,
                  ),
                ),
                const SizedBox(height: 40),
                
                // Error message display
                Obx(() {
                  if (authController.errorMessage.isNotEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red[700],
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              authController.errorMessage,
                              style: TextStyle(
                                color: Colors.red[700],
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => authController.clearError(),
                            icon: Icon(
                              Icons.close,
                              color: Colors.red[700],
                              size: 18,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),
                
                //email text field
                CustomTextfield(
                  label: 'Email',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập email';
                    }
                    if (!GetUtils.isEmail(value)) {
                      return 'Vui lòng nhập email hợp lệ';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                //password text field
                CustomTextfield(
                  label: 'Password',
                  prefixIcon: Icons.lock_outlined,
                  keyboardType: TextInputType.visiblePassword,
                  controller: _passwordController,
                  isPassword: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập mật khẩu';
                    }
                    if (value.length < 6) {
                      return 'Mật khẩu phải có ít nhất 6 ký tự';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => _showForgotPasswordDialog(context),
                    child: Text(
                      'Quên mật khẩu?',
                      style: AppTextStyle.withColor(
                        AppTextStyle.buttonMedium,
                        Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Obx(() => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: authController.isLoading ? null : _handleSignIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: authController.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Đăng nhập',
                            style: AppTextStyle.withColor(
                              AppTextStyle.buttonMedium,
                              Colors.white,
                            ),
                          ),
                  ),
                )),
                const SizedBox(height: 16),
                // Nút đăng nhập Google
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.login, color: Colors.red), // Hoặc dùng Asset Google logo nếu có
                    label: Text('Đăng nhập bằng Google', style: TextStyle(color: Colors.black)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    onPressed: () => _handleGoogleSignIn(context),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Chưa có tài khoản?',
                      style: AppTextStyle.withColor(
                        AppTextStyle.bodyMedium,
                        isDark ? Colors.grey[400]! : Colors.grey[600]!,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Get.to(() => SignupScreen()),
                      child: Text(
                        'Đăng ký',
                        style: AppTextStyle.withColor(
                          AppTextStyle.buttonMedium,
                          Theme.of(context).primaryColor,
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
    );
  }

  void _handleSignIn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final AuthController authController = Get.find<AuthController>();
    
    // Clear any previous error messages
    authController.clearError();
    
    // Kiểm tra kết nối server trước
    final isConnected = await authController.testConnection();
    if (!isConnected) {
      authController.setErrorMessage('Không thể kết nối đến server.');
      return;
    }
    
    final success = await authController.loginWithApi(
      _emailController.text.trim(),
      _passwordController.text,
    );
    
    if (success) {
      // Delay 2 giây để hiển thị thông báo thành công trước khi chuyển màn hình
      await Future.delayed(const Duration(seconds: 2));
      Get.offAll(() => const MainScreen());
    }
  }

  Future<void> _handleGoogleSignIn(BuildContext context) async {
    final result = await GoogleAuthService.signInWithGoogleAndSave();
    if (result['success'] == true) {
      Get.snackbar(
        'Thành công',
        'Đăng nhập Google thành công!',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      
      await Future.delayed(const Duration(milliseconds: 500));
      Get.offAll(() => const MainScreen());
    } else {
      Get.snackbar(
        'Lỗi',
        result['message'] ?? 'Đăng nhập Google thất bại',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _showForgotPasswordDialog(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final AuthController authController = Get.find<AuthController>();
    final ThemeData theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 8,
          backgroundColor: isDark ? Colors.grey[900] : Colors.white,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.email_outlined, size: 48, color: theme.primaryColor),
                  const SizedBox(height: 12),
                  Text('Quên mật khẩu', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Nhập email để nhận mã xác thực OTP đặt lại mật khẩu.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: isDark ? Colors.grey[300] : Colors.grey[700], fontSize: 15)),
                  const SizedBox(height: 18),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.alternate_email),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('Hủy', style: TextStyle(color: theme.hintColor)),
                      ),
                      const SizedBox(width: 12),
                      Obx(() => ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          elevation: 4,
                        ),
                        onPressed: authController.isLoading
                            ? null
                            : () async {
                                final email = emailController.text.trim();
                                if (!GetUtils.isEmail(email)) {
                                  Get.snackbar('Lỗi', 'Vui lòng nhập email hợp lệ', backgroundColor: Colors.red, colorText: Colors.white);
                                  return;
                                }
                                final success = await authController.forgotPassword(email);
                                if (success) {
                                  Navigator.of(context).pop();
                                  Get.to(() => OtpVerifyScreen(email: email));
                                }
                              },
                        child: authController.isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('Gửi mã', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      )),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
