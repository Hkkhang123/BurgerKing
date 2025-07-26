import 'package:client/core/services/auth_controller.dart';
import 'package:client/shared/themes/app_textstyle.dart';
import 'package:client/features/home/main_screen.dart';
import 'package:client/features/auth/signup_screen.dart';
import 'package:client/shared/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:client/core/utils/google_auth_service.dart';
import 'package:client/features/auth/otp_verify_screen.dart';
import 'package:client/features/auth/login_otp_screen.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
                  if (authController.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (authController.errorMessage.isNotEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        authController.errorMessage,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                        textAlign: TextAlign.center,
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
                // Login buttons
                Column(
                  children: [
                    // Đăng nhập bằng password
                    Obx(
                      () => SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              authController.isLoading ? null : _handleSignIn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child:
                              authController.isLoading
                                  ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
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
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Đăng nhập bằng OTP
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed:
                            authController.isLoading
                                ? null
                                : _handleLoginWithOtp,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        child: Text(
                          'Đăng nhập bằng OTP',
                          style: AppTextStyle.withColor(
                            AppTextStyle.buttonMedium,
                            Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Social login buttons
                Center(
                  child: Column(
                    children: [
                      Text(
                        'Hoặc đăng nhập với',
                        style: AppTextStyle.withColor(
                          AppTextStyle.bodyMedium,
                          isDark ? Colors.grey[400]! : Colors.grey[600]!,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _SocialIconButton(
                            icon: Icons.facebook,
                            color: Colors.blue[800]!,
                            onTap: () {
                              Get.snackbar(
                                'Thông báo',
                                'Tính năng đăng nhập Facebook đang được cập nhật. Vui lòng sử dụng email/password hoặc Google.',
                                backgroundColor: Colors.orange,
                                colorText: Colors.white,
                                duration: const Duration(seconds: 3),
                              );
                            },
                          ),
                          const SizedBox(width: 18),
                          _SocialIconButton(
                            icon: Icons.g_mobiledata,
                            color: Colors.red,
                            onTap: () => _handleGoogleSignIn(context),
                          ),
                          const SizedBox(width: 18),
                          _SocialIconButton(
                            icon: Icons.music_note,
                            color: Colors.black,
                            onTap: () {
                              // TODO: TikTok login
                            },
                          ),
                        ],
                      ),
                    ],
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

  void _handleLoginWithOtp() async {
    if (_emailController.text.trim().isEmpty) {
      Get.snackbar(
        'Lỗi',
        'Vui lòng nhập email',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (!GetUtils.isEmail(_emailController.text.trim())) {
      Get.snackbar(
        'Lỗi',
        'Vui lòng nhập email hợp lệ',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final AuthController authController = Get.find<AuthController>();
    authController.clearError();

    final success = await authController.sendLoginOtp(
      _emailController.text.trim(),
    );

    if (success) {
      Get.to(() => LoginOtpScreen(email: _emailController.text.trim()));
    }
  }

  Future<void> _handleGoogleSignIn(BuildContext context) async {
    final result = await GoogleAuthService.signInWithGoogleAndSave();
    print('Google login result: $result');
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 8,
          backgroundColor: isDark ? Colors.grey[900] : Colors.white,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.email_outlined,
                    size: 48,
                    color: theme.primaryColor,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Quên mật khẩu',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Nhập email để nhận mã xác thực OTP đặt lại mật khẩu.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.alternate_email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'Hủy',
                          style: TextStyle(color: theme.hintColor),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Obx(
                        () => ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 14,
                            ),
                            elevation: 4,
                          ),
                          onPressed:
                              authController.isLoading
                                  ? null
                                  : () async {
                                    final email = emailController.text.trim();
                                    if (!GetUtils.isEmail(email)) {
                                      Get.snackbar(
                                        'Lỗi',
                                        'Vui lòng nhập email hợp lệ',
                                        backgroundColor: Colors.red,
                                        colorText: Colors.white,
                                      );
                                      return;
                                    }
                                    final success = await authController
                                        .forgotPassword(email);
                                    if (success) {
                                      Navigator.of(context).pop();
                                      Get.to(
                                        () => OtpVerifyScreen(email: email),
                                      );
                                    }
                                  },
                          child:
                              authController.isLoading
                                  ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                  : const Text(
                                    'Gửi mã',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                        ),
                      ),
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

// Thêm widget nút mạng xã hội
class _SocialIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _SocialIconButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }
}

// Thay thế hàm _handleFacebookSignIn
Future<void> _handleFacebookSignIn(BuildContext context) async {
  try {
    final AuthController authController = Get.find<AuthController>();
    print('Bắt đầu đăng nhập Facebook...');

    // Kiểm tra xem Facebook Auth có sẵn sàng không
    if (!await FacebookAuth.instance.isWebSdkInitialized) {
      print('Facebook Web SDK chưa được khởi tạo');
      Get.snackbar(
        'Lỗi',
        'Facebook đăng nhập chưa được cấu hình. Vui lòng thử lại sau.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final result = await FacebookAuth.instance.login(
      permissions: ['email', 'public_profile'],
    );
    print('Facebook login result: $result');

    if (result.status == LoginStatus.success) {
      final accessToken = result.accessToken!.token;
      print('Facebook access token: $accessToken');

      // Gọi backend API
      try {
        final response = await http.post(
          Uri.parse('https://burgerking-j92p.onrender.com/api/auth/facebook'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'access_token': accessToken}),
        );
        print('Backend response: ${response.statusCode} ${response.body}');

        if (response.statusCode == 200) {
          await authController.loginWithFacebook(
            onSuccess: () {
              Get.offAll(() => const MainScreen());
            },
          );
        } else {
          Get.snackbar(
            'Lỗi',
            'Không thể xác thực với Facebook. Vui lòng thử lại.',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } catch (e) {
        print('Backend API error: $e');
        Get.snackbar(
          'Lỗi',
          'Không thể kết nối đến server. Vui lòng thử lại.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } else if (result.status == LoginStatus.cancelled) {
      print('Facebook login cancelled by user');
    } else {
      print('Facebook login failed: ${result.status}');
      Get.snackbar(
        'Lỗi',
        'Đăng nhập Facebook thất bại. Vui lòng thử lại.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  } catch (e) {
    print('Facebook login error: $e');
    Get.snackbar(
      'Lỗi',
      'Có lỗi xảy ra khi đăng nhập Facebook. Vui lòng thử lại.',
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
}
