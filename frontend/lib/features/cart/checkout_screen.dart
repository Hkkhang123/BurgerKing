import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:client/core/services/cart_controller.dart';
import 'package:client/core/services/auth_controller.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class CheckoutScreen extends StatefulWidget {
  final List<dynamic> cartProducts;
  final double totalPrice;

  const CheckoutScreen({Key? key, required this.cartProducts, required this.totalPrice}) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _addressController = TextEditingController(text: '123 Đường ABC, Quận 1, TP.HCM');
  final _cityController = TextEditingController(text: 'Hồ Chí Minh');
  final _phoneController = TextEditingController(text: '0123456789');
  final _receiverController = TextEditingController(text: 'Khách hàng');
  final _districtController = TextEditingController(text: 'Quận 1');
  final _postalCodeController = TextEditingController(text: '700000');
  String _paymentMethod = 'Thanh toán khi nhận hàng';
  bool _isLoading = false;
  late final WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted);
  }

  @override
  void dispose() {
    _addressController.dispose();
    _cityController.dispose();
    _phoneController.dispose();
    _receiverController.dispose();
    super.dispose();
  }

  Future<void> _handleConfirmCheckout() async {
    setState(() { _isLoading = true; });
    final authController = Get.find<AuthController>();
    final token = authController.getToken();
    final cartController = Get.find<CartController>();
    final List<Map<String, dynamic>> checkoutItems = widget.cartProducts.map((e) => {
      'productId': e['productId'] ?? e['_id'] ?? e['id'],
      'quantity': e['quantity'] ?? 1,
      'price': e['price'] ?? 0,
      'name': e['name'] ?? '',
      'image': e['image'] ?? '',
    }).toList();
    final shippingAddress = {
      'address': _addressController.text,
      'city': _cityController.text,
      'district': _districtController.text,
      'postalCode': _postalCodeController.text,
      'phone': _phoneController.text,
      'receiver': _receiverController.text,
    };
    final result = await cartController.checkout(
      token,
      checkoutItem: checkoutItems,
      shippingAddress: shippingAddress,
      paymentMethod: _paymentMethod,
      totalPrice: widget.totalPrice,
    );
    setState(() { _isLoading = false; });
    if (!mounted) return;
    if (result['success'] == true) {
      final checkoutId = result['data']['_id'];
      if (_paymentMethod == 'Thanh toán Momo') {
        // Gọi API backend để lấy payUrl của Momo
        print('Bắt đầu gọi API thanh toán MoMo với checkoutId: ' + checkoutId);
        final response = await http.post(
          Uri.parse('https://burgerking-j92p.onrender.com/api/payment/momo'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'checkoutId': checkoutId,
            'redirectUrl': 'https://momo.vn/return',
            'ipnUrl': 'https://webhook.site/your-test-url',
          }),
        );
        print('Request gửi đi: ' + jsonEncode({
          'checkoutId': checkoutId,
          'redirectUrl': 'https://momo.vn/return',
          'ipnUrl': 'https://webhook.site/your-test-url',
        }));
        print('Status code trả về từ backend: ' + response.statusCode.toString());
        if (response.statusCode == 200) {
          print('Momo response: ' + response.body);
          final payUrl = jsonDecode(response.body)['payUrl'];
          if (payUrl != null) {
            print('payUrl nhận được: ' + payUrl);
            final uri = Uri.parse(payUrl);
            bool launched = false;
            if (await canLaunchUrl(uri)) {
              // Thử mở bằng externalApplication trước
              launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
              print('launchUrl externalApplication: $launched');
              if (!launched) {
                // Nếu không được, thử platformDefault
                launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
                print('launchUrl platformDefault: $launched');
              }
            }
            if (launched) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Vui lòng kiểm tra trạng thái đơn hàng sau khi thanh toán!')),
              );
              Navigator.of(context).pop(true);
              return;
            } else {
              print('Không mở được link thanh toán MoMo!');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Không mở được link thanh toán MoMo!')),
              );
            }
          } else {
            print('Không nhận được payUrl từ response MoMo!');
          }
        } else {
          print('Momo error: ' + response.body);
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không lấy được link thanh toán Momo!')),
        );
        return;
      }
      if (_paymentMethod == 'Thanh toán PayPal') {
        // Gọi API backend để lấy payUrl của PayPal
        print('Bắt đầu gọi API thanh toán PayPal với tổng tiền: ' + widget.totalPrice.toString());
        final response = await http.post(
          Uri.parse('https://burgerking-j92p.onrender.com/api/payment/paypal'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'amount': widget.totalPrice.toStringAsFixed(2),
            'currency': 'USD',
            'returnUrl': 'https://your-app.com/paypal/return',
            'cancelUrl': 'https://your-app.com/paypal/cancel',
          }),
        );
        print('Status code trả về từ backend PayPal: ' + response.statusCode.toString());
        if (response.statusCode == 200) {
          final payUrl = jsonDecode(response.body)['payUrl'];
          if (payUrl != null) {
            print('payUrl PayPal nhận được: ' + payUrl);
            final uri = Uri.parse(payUrl);
            bool launched = false;
            if (await canLaunchUrl(uri)) {
              launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
              print('launchUrl externalApplication: $launched');
              if (!launched) {
                launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
                print('launchUrl platformDefault: $launched');
              }
            }
            if (launched) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Vui lòng kiểm tra trạng thái đơn hàng sau khi thanh toán PayPal!')),
              );
              Navigator.of(context).pop(true);
              return;
            } else {
              print('Không mở được link thanh toán PayPal!');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Không mở được link thanh toán PayPal!')),
              );
            }
          } else {
            print('Không nhận được payUrl từ response PayPal!');
          }
        } else {
          print('PayPal error: ' + response.body);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Không lấy được link thanh toán PayPal!')),
          );
        }
        return;
      }
      // Thanh toán thường
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đặt hàng thành công!')),
      );
      Navigator.of(context).pop(true); // Trả về true để CartScreen reload lại
    } else {
      String errorMsg = result['data']?['message'] ?? result['error'] ?? 'Lỗi khi thanh toán';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Xác nhận đơn hàng')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Sản phẩm:', style: TextStyle(fontWeight: FontWeight.bold)),
                  ...widget.cartProducts.map((e) => ListTile(
                        leading: e['image'] != null && e['image'] != ''
                            ? Image.network(e['image'], width: 40, height: 40, fit: BoxFit.cover)
                            : const Icon(Icons.image),
                        title: Text(e['name'] ?? ''),
                        subtitle: Text('Số lượng: ${e['quantity'] ?? 1}'),
                        trailing: Text('${e['price'] ?? 0} đ'),
                      )),
                  const SizedBox(height: 16),
                  Text('Tổng tiền: ${widget.totalPrice.toStringAsFixed(0)} đ', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const Divider(height: 32),
                  const Text('Địa chỉ giao hàng:', style: TextStyle(fontWeight: FontWeight.bold)),
                  TextField(
                    controller: _addressController,
                    decoration: const InputDecoration(labelText: 'Địa chỉ'),
                  ),
                  TextField(
                    controller: _cityController,
                    decoration: const InputDecoration(labelText: 'Thành phố'),
                  ),
                  TextField(
                    controller: _districtController,
                    decoration: const InputDecoration(labelText: 'Quận/Huyện'),
                  ),
                  TextField(
                    controller: _postalCodeController,
                    decoration: const InputDecoration(labelText: 'Mã bưu điện'),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: _phoneController,
                    decoration: const InputDecoration(labelText: 'Số điện thoại'),
                    keyboardType: TextInputType.phone,
                  ),
                  TextField(
                    controller: _receiverController,
                    decoration: const InputDecoration(labelText: 'Người nhận'),
                  ),
                  const SizedBox(height: 16),
                  const Text('Phương thức thanh toán:', style: TextStyle(fontWeight: FontWeight.bold)),
                  DropdownButton<String>(
                    value: _paymentMethod,
                    items: const [
                      DropdownMenuItem(value: 'Thanh toán khi nhận hàng', child: Text('Thanh toán khi nhận hàng')),
                      DropdownMenuItem(value: 'Chuyển khoản ngân hàng', child: Text('Chuyển khoản ngân hàng')),
                      DropdownMenuItem(value: 'Thanh toán Momo', child: Text('Thanh toán Momo')),
                      DropdownMenuItem(value: 'Thanh toán PayPal', child: Text('Thanh toán PayPal')),
                    ],
                    onChanged: (value) {
                      if (value != null) setState(() => _paymentMethod = value);
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _handleConfirmCheckout,
                      child: const Text('Xác nhận đặt hàng'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
} 