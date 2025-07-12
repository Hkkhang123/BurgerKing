import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:client/core/services/cart_controller.dart';
import 'package:client/core/services/auth_controller.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:webview_flutter/webview_flutter.dart';

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

  // Hàm kiểm tra trạng thái thanh toán
  Future<void> _checkPaymentStatus(String checkoutId) async {
    setState(() { _isLoading = true; });
    
    // Hiển thị thông báo đang kiểm tra
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đang kiểm tra trạng thái thanh toán...'),
        backgroundColor: Colors.blue,
        duration: Duration(seconds: 2),
      ),
    );
    
    // Polling: kiểm tra trạng thái mỗi 5 giây, tối đa 30 giây
    int attempts = 0;
    const maxAttempts = 6; // 30 giây / 5 giây = 6 lần
    
    while (attempts < maxAttempts) {
      try {
        final authController = Get.find<AuthController>();
        final token = authController.getToken();
        
        // Gọi API để lấy thông tin checkout
        final response = await http.get(
          Uri.parse('https://burgerking-j92p.onrender.com/api/checkout/$checkoutId'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );
        
        print('API Response Status: ${response.statusCode}');
        print('API Response Body: ${response.body}');
        
        if (response.statusCode == 200) {
          final checkoutData = json.decode(response.body);
          print('Parsed checkout data: $checkoutData');
          
          final paymentStatus = checkoutData['paymentStatus'];
          final isPaid = checkoutData['isPaid'] ?? false;
          final isFinalized = checkoutData['isFinalized'] ?? false;
          
          print('Payment Status: $paymentStatus, isPaid: $isPaid, isFinalized: $isFinalized');
          
          // Kiểm tra nếu đã finalize thì cũng coi như thành công
          if (paymentStatus == 'Đã thanh toán' || isPaid == true || isFinalized == true) {
            setState(() { _isLoading = false; });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Thanh toán MoMo thành công! Đơn hàng đã được xử lý.'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop(true); // Trả về true để CartScreen reload lại
            return; // Thoát khỏi polling
          } else if (paymentStatus == 'Thanh toán thất bại') {
            setState(() { _isLoading = false; });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Thanh toán MoMo thất bại. Vui lòng thử lại.'),
                backgroundColor: Colors.red,
              ),
            );
            return; // Thoát khỏi polling
          } else {
            // Vẫn đang xử lý, tiếp tục polling
            print('Payment status: $paymentStatus, attempt: ${attempts + 1}');
          }
        } else if (response.statusCode == 404) {
          // Nếu không tìm thấy checkout, có thể đã được finalize thành order
          print('Checkout not found, checking if order exists...');
          try {
            final orderResponse = await http.get(
              Uri.parse('https://burgerking-j92p.onrender.com/api/order/my-order'),
              headers: {
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json',
              },
            );
            
            if (orderResponse.statusCode == 200) {
              final orders = json.decode(orderResponse.body);
              print('Orders found: $orders');
              
              // Kiểm tra xem có order nào được tạo gần đây không
              if (orders is List && orders.isNotEmpty) {
                final latestOrder = orders.first;
                print('Latest order: $latestOrder');
                
                setState(() { _isLoading = false; });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Thanh toán MoMo thành công! Đơn hàng đã được xử lý.'),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.of(context).pop(true);
                return;
              }
            }
          } catch (orderError) {
            print('Error checking orders: $orderError');
          }
        } else {
          print('API error: ${response.statusCode} - ${response.body}');
        }
      } catch (e) {
        print('Network error: $e');
      }
      
      attempts++;
      if (attempts < maxAttempts) {
        // Chờ 5 giây trước khi kiểm tra lại
        await Future.delayed(const Duration(seconds: 5));
      }
    }
    
    // Hết thời gian polling, thử kiểm tra trạng thái từ MoMo API
    print('Polling timeout after 30 seconds, trying to check MoMo payment status directly...');
    try {
      final authController = Get.find<AuthController>();
      final token = authController.getToken();
      
      // Gọi API để kiểm tra trạng thái thanh toán từ MoMo
      final momoStatusResponse = await http.post(
        Uri.parse('https://burgerking-j92p.onrender.com/api/payment/momo/status'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'checkoutId': checkoutId}),
      );
      
      if (momoStatusResponse.statusCode == 200) {
        final momoStatusData = json.decode(momoStatusResponse.body);
        print('MoMo status response: $momoStatusData');
        
        if (momoStatusData['success'] == true && momoStatusData['isPaid'] == true) {
          setState(() { _isLoading = false; });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Thanh toán MoMo thành công! ${momoStatusData['message']}'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 4),
            ),
          );
          Navigator.of(context).pop(true);
          return;
        }
      }
    } catch (e) {
      print('Error checking MoMo status: $e');
    }
    
    // Hết thời gian polling
    setState(() { _isLoading = false; });
    
    // Hiển thị dialog với thông tin chi tiết
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thông báo'),
        content: const Text(
          'Không thể xác nhận trạng thái thanh toán sau 30 giây.\n\n'
          'Có thể:\n'
          '• Thanh toán đang được xử lý\n'
          '• Có vấn đề với kết nối mạng\n'
          '• MoMo chưa gửi thông báo xác nhận\n\n'
          'Bạn có thể:\n'
          '• Kiểm tra lại sau vài phút\n'
          '• Liên hệ hỗ trợ nếu đã thanh toán thành công'
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Thử kiểm tra lại một lần nữa
              _checkPaymentStatus(checkoutId);
            },
            child: const Text('Kiểm tra lại'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
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
                      DropdownMenuItem(value: 'Thanh toán MoMo', child: Text('Thanh toán MoMo')),
                    ],
                    onChanged: (value) {
                      if (value != null) setState(() => _paymentMethod = value);
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_paymentMethod == 'Thanh toán MoMo') {
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
                          // 1. Gọi API tạo đơn hàng
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
                            final amount = result['data']['totalPrice'];
                            setState(() { _isLoading = true; });
                            try {
                              final response = await http.post(
                                Uri.parse('https://burgerking-j92p.onrender.com/api/payment/momo/test'),
                                headers: {'Content-Type': 'application/json'},
                                body: json.encode({'checkoutId': checkoutId, 'amount': amount.toString()}),
                              );
                              setState(() { _isLoading = false; });
                              if (response.statusCode == 200) {
                                final data = json.decode(response.body);
                                final payUrl = data['payUrl'] ?? data['deeplink'] ?? data['deeplinkWeb'] ?? '';
                                if (payUrl.isNotEmpty) {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (_) => Scaffold(
                                      appBar: AppBar(
                                        title: const Text('Thanh toán MoMo'),
                                        leading: IconButton(
                                          icon: const Icon(Icons.close),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            // Hiển thị dialog xác nhận
                                            showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: const Text('Xác nhận'),
                                                content: const Text('Bạn có muốn kiểm tra trạng thái thanh toán không?'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context).pop();
                                                      _checkPaymentStatus(checkoutId);
                                                    },
                                                    child: const Text('Có'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context).pop();
                                                    },
                                                    child: const Text('Không'),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      body: WebViewWidget(
                                        controller: WebViewController()
                                          ..setJavaScriptMode(JavaScriptMode.unrestricted)
                                          ..loadRequest(Uri.parse(payUrl))
                                          ..setNavigationDelegate(NavigationDelegate(
                                            onNavigationRequest: (request) {
                                              print('WebView navigation to: ${request.url}');
                                              // Nếu URL chứa redirectUrl hoặc kết quả thanh toán
                                              if (request.url.contains('webhook.site') || 
                                                  request.url.contains('success') ||
                                                  request.url.contains('cancel') ||
                                                  request.url.contains('resultCode=0')) {
                                                Navigator.of(context).pop();
                                                // Kiểm tra trạng thái đơn hàng
                                                _checkPaymentStatus(checkoutId);
                                                return NavigationDecision.prevent;
                                              }
                                              return NavigationDecision.navigate;
                                            },
                                            onPageFinished: (url) {
                                              print('WebView page finished loading: $url');
                                              // Nếu trang đã load xong và có vẻ là trang kết quả
                                              if (url.contains('webhook.site') || 
                                                  url.contains('success') ||
                                                  url.contains('cancel')) {
                                                // Chờ 2 giây rồi kiểm tra trạng thái
                                                Future.delayed(const Duration(seconds: 2), () {
                                                  if (mounted) {
                                                    Navigator.of(context).pop();
                                                    _checkPaymentStatus(checkoutId);
                                                  }
                                                });
                                              }
                                            },
                                          )),
                                      ),
                                    ),
                                  ));
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Không lấy được link thanh toán MoMo!')),
                                  );
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Lỗi: ${response.body}')),
                                );
                              }
                            } catch (e) {
                              setState(() { _isLoading = false; });
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Lỗi kết nối MoMo: $e')),
                              );
                            }
                          } else {
                            String errorMsg = result['data']?['message'] ?? result['error'] ?? 'Lỗi khi tạo đơn hàng';
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(errorMsg)),
                            );
                          }
                        } else {
                          await _handleConfirmCheckout();
                        }
                      },
                      child: const Text('Xác nhận đặt hàng'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
} 