import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:client/core/services/auth_controller.dart';
import 'package:client/features/home/main_screen.dart';
import 'dart:async';

class SignupOtpScreen extends StatefulWidget {
  final String name;
  final String email;
  final String password;

  const SignupOtpScreen({
    Key? key,
    required this.name,
    required this.email,
    required this.password,
  }) : super(key: key);

  @override
  State<SignupOtpScreen> createState() => _SignupOtpScreenState();
}

class _SignupOtpScreenState extends State<SignupOtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthController authController = Get.find<AuthController>();
  int _seconds = 60;
  late final Timer _timer;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _seconds = 60;
    _canResend = false;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_seconds > 0) {
        setState(() {
          _seconds--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        _timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _handleVerifyOtp() async {
    if (_otpController.text.length != 6) {
      Get.snackbar(
        'Lỗi',
        'Vui lòng nhập đủ 6 số OTP',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final success = await authController.registerWithOtp(
      widget.email,
      _otpController.text.trim(),
    );

    if (success) {
      // Delay để hiển thị thông báo thành công
      await Future.delayed(const Duration(seconds: 2));
      Get.offAll(() => const MainScreen());
    }
  }

  void _handleResend() async {
    final success = await authController.sendSignupOtp(
      widget.email,
      widget.name,
      widget.password,
    );
    if (success) {
      _otpController.clear();
      _startTimer();
      Get.snackbar(
        'Thành công',
        'Đã gửi lại mã OTP!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Xác thực đăng ký',
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            color: isDark ? Colors.grey[800] : Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.verified_user,
                      size: 64,
                      color: theme.primaryColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Xác thực đăng ký',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Nhập mã xác nhận được gửi đến\n${widget.email}',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: isDark ? Colors.grey[300] : Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // OTP Input Field
                    PinCodeTextField(
                      appContext: context,
                      length: 6,
                      controller: _otpController,
                      onChanged: (value) {},
                      onCompleted: (value) {
                        _handleVerifyOtp();
                      },
                      pinTheme: PinTheme(
                        shape: PinCodeFieldShape.box,
                        borderRadius: BorderRadius.circular(8),
                        fieldHeight: 50,
                        fieldWidth: 45,
                        activeFillColor:
                            isDark ? Colors.grey[700] : Colors.grey[100],
                        activeColor: theme.primaryColor,
                        selectedColor: theme.primaryColor,
                        inactiveColor:
                            isDark ? Colors.grey[600] : Colors.grey[300],
                      ),
                      keyboardType: TextInputType.number,
                      enableActiveFill: true,
                    ),

                    const SizedBox(height: 24),

                    // Verify Button
                    Obx(
                      () => SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              authController.isLoading
                                  ? null
                                  : _handleVerifyOtp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.primaryColor,
                            foregroundColor: Colors.white,
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
                                  : const Text(
                                    'Hoàn tất đăng ký',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Resend OTP
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Chưa nhận được mã? ',
                          style: TextStyle(
                            color: isDark ? Colors.grey[300] : Colors.grey[600],
                          ),
                        ),
                        if (_canResend)
                          TextButton(
                            onPressed: _handleResend,
                            child: Text(
                              'Gửi lại',
                              style: TextStyle(
                                color: theme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        else
                          Text(
                            'Gửi lại sau $_seconds giây',
                            style: TextStyle(
                              color:
                                  isDark ? Colors.grey[400] : Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Error message
                    Obx(() {
                      if (authController.errorMessage.isNotEmpty) {
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red[200]!),
                          ),
                          child: Text(
                            authController.errorMessage,
                            style: TextStyle(
                              color: Colors.red[700],
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
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
