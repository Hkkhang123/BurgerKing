import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'reset_password_screen.dart';
import 'dart:async';

class OtpVerifyScreen extends StatefulWidget {
  final String email;
  const OtpVerifyScreen({Key? key, required this.email}) : super(key: key);

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  final TextEditingController _otpController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;
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
      setState(() { _errorMessage = 'Vui lòng nhập đủ 6 số OTP'; });
      return;
    }
    setState(() { _isLoading = true; _errorMessage = null; });
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() { _isLoading = false; });
    Get.to(() => ResetPasswordScreen(email: widget.email, otp: _otpController.text.trim()));
  }

  void _handleResend() {
    // TODO: Gọi API gửi lại OTP ở đây nếu cần
    _otpController.clear();
    _startTimer();
    setState(() { _errorMessage = null; });
    Get.snackbar('Thành công', 'Đã gửi lại mã OTP!', backgroundColor: Colors.green, colorText: Colors.white);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            color: theme.cardColor,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Mã xác nhận', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.primaryColor)),
                    const SizedBox(height: 12),
                    Text('Nhập mã xác nhận được gửi đến Email của bạn!',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(color: theme.hintColor)),
                    const SizedBox(height: 28),
                    PinCodeTextField(
                      appContext: context,
                      length: 6,
                      controller: _otpController,
                      autoFocus: true,
                      animationType: AnimationType.fade,
                      pinTheme: PinTheme(
                        shape: PinCodeFieldShape.box,
                        borderRadius: BorderRadius.circular(8),
                        fieldHeight: 50,
                        fieldWidth: 45,
                        activeColor: theme.primaryColor,
                        selectedColor: theme.primaryColor.withAlpha(200),
                        inactiveColor: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                        activeFillColor: theme.scaffoldBackgroundColor,
                        inactiveFillColor: theme.scaffoldBackgroundColor,
                        selectedFillColor: theme.scaffoldBackgroundColor,
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {},
                      enableActiveFill: true,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _seconds > 0 ? '00:${_seconds.toString().padLeft(2, '0')}' : '',
                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 8),
                      Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: _isLoading ? null : _handleVerifyOtp,
                        child: _isLoading
                            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : Text('TIẾP TỤC', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimary)),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Bạn chưa nhận được mã? ', style: TextStyle(color: theme.hintColor)),
                        GestureDetector(
                          onTap: _canResend ? _handleResend : null,
                          child: Text('Gửi lại', style: TextStyle(color: _canResend ? Colors.red : theme.disabledColor, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
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