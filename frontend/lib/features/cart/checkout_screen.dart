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
import 'order_confirmation_screen.dart';
import 'package:client/core/services/notification_controller.dart';

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
      final id = result['data']['_id'];
      final orderCode = result['data']['orderCode'] ?? id.substring(id.length - 6).toUpperCase();
      
      if (_paymentMethod == 'Thanh toán khi nhận hàng') {
        // Với thanh toán khi nhận hàng, API tạo Order ngay lập tức
        // nên _id là orderId
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => OrderConfirmationScreen(
              orderId: id, // Đây là orderId thực
              orderCode: orderCode,
              totalAmount: widget.totalPrice,
              paymentMethod: _paymentMethod,
              shippingAddress: {
                'address': _addressController.text,
                'city': _cityController.text,
                'district': _districtController.text,
                'postalCode': _postalCodeController.text,
                'phone': _phoneController.text,
                'receiver': _receiverController.text,
              },
              orderItems: widget.cartProducts,
              isPaymentSuccess: false, // Chưa thanh toán
            ),
          ),
        );
        // Cập nhật notification sau khi đặt hàng thành công
        final notificationController = Get.find<NotificationController>();
        await notificationController.fetchNotifications();
      } else {
        // Thanh toán thường
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đặt hàng thành công!')),
        );
        Navigator.of(context).pop(true);
      }
    } else {
      String errorMsg = result['data']?['message'] ?? result['error'] ?? 'Lỗi khi thanh toán';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg)),
      );
    }
  }

  // Dialog xác nhận thanh toán khi nhận hàng
  void _showPaymentConfirmationDialog(String orderCode) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Đặt hàng thành công!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              'Đơn hàng của bạn đã được tạo thành công!\n\n'
              'Thông tin đơn hàng:',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🏷️ Mã đơn hàng:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    orderCode,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '💰 Số tiền: ${widget.totalPrice.toStringAsFixed(0)} đ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ℹ️ Lưu ý:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text('• Thanh toán khi nhận hàng'),
                  Text('• Admin sẽ xác nhận thanh toán sau'),
                  Text('• Bạn có thể theo dõi trạng thái trong "Đơn hàng của tôi"'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(true);
            },
            child: const Text('Đóng'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showOrderDetails(orderCode);
            },
            child: const Text('Xem chi tiết'),
          ),
        ],
      ),
    );
  }

  // Hiển thị chi tiết đơn hàng
  void _showOrderDetails(String orderCode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chi tiết đơn hàng'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '📦 Thông tin giao hàng',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                                         Text('🏷️ Mã đơn hàng: $orderCode'),
                    const SizedBox(height: 4),
                    Text('💰 Tổng tiền: ${widget.totalPrice.toStringAsFixed(0)} đ'),
                    const SizedBox(height: 4),
                    Text('📍 Địa chỉ: ${_addressController.text}'),
                    const SizedBox(height: 4),
                    Text('📞 SĐT: ${_phoneController.text}'),
                    const SizedBox(height: 4),
                    Text('👤 Người nhận: ${_receiverController.text}'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text('📋 Sản phẩm:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              ...widget.cartProducts.map((e) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    if (e['image'] != null && e['image'] != '')
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.network(
                          e['image'],
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                        ),
                      ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            e['name'] ?? '',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            'Số lượng: ${e['quantity'] ?? 1}',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${e['price'] ?? 0} đ',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              )),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ℹ️ Lưu ý khi nhận hàng:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text('• Kiểm tra sản phẩm trước khi thanh toán'),
                    Text('• Chuẩn bị đủ tiền mặt hoặc thẻ'),
                    Text('• Giữ mã xác nhận để đối chiếu'),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(true);
            },
            child: const Text('Hoàn tất'),
          ),
        ],
      ),
    );
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
            
            // Chuyển đến trang xác nhận đơn hàng với checkoutId
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => OrderConfirmationScreen(
                  checkoutId: checkoutId,
                  orderCode: checkoutData['orderCode'] ?? checkoutId.substring(checkoutId.length - 6).toUpperCase(),
                  totalAmount: widget.totalPrice,
                  paymentMethod: _paymentMethod,
                  shippingAddress: {
                    'address': _addressController.text,
                    'city': _cityController.text,
                    'district': _districtController.text,
                    'postalCode': _postalCodeController.text,
                    'phone': _phoneController.text,
                    'receiver': _receiverController.text,
                  },
                  orderItems: widget.cartProducts,
                  isPaymentSuccess: true,
                ),
              ),
            );
            // Cập nhật notification sau khi thanh toán thành công
            final notificationController = Get.find<NotificationController>();
            await notificationController.fetchNotifications();
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
                
                // Chuyển đến trang xác nhận đơn hàng với orderId thực
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => OrderConfirmationScreen(
                      orderId: latestOrder['_id'],
                      orderCode: latestOrder['orderCode'] ?? latestOrder['_id'].substring(latestOrder['_id'].length - 6).toUpperCase(),
                      totalAmount: latestOrder['totalPrice']?.toDouble() ?? widget.totalPrice,
                      paymentMethod: latestOrder['paymentMethod'] ?? _paymentMethod,
                      shippingAddress: latestOrder['shippingAddress'] ?? {
                        'address': _addressController.text,
                        'city': _cityController.text,
                        'district': _districtController.text,
                        'postalCode': _postalCodeController.text,
                        'phone': _phoneController.text,
                        'receiver': _receiverController.text,
                      },
                      orderItems: latestOrder['orderItems'] ?? widget.cartProducts,
                      isPaymentSuccess: latestOrder['isPaid'] ?? true,
                    ),
                  ),
                );
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
          
          // Chuyển đến trang xác nhận đơn hàng với checkoutId
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => OrderConfirmationScreen(
                checkoutId: checkoutId,
                orderCode: checkoutId.substring(checkoutId.length - 6).toUpperCase(),
                totalAmount: widget.totalPrice,
                paymentMethod: _paymentMethod,
                shippingAddress: {
                  'address': _addressController.text,
                  'city': _cityController.text,
                  'district': _districtController.text,
                  'postalCode': _postalCodeController.text,
                  'phone': _phoneController.text,
                  'receiver': _receiverController.text,
                },
                orderItems: widget.cartProducts,
                isPaymentSuccess: true,
              ),
            ),
          );
          // Cập nhật notification sau khi thanh toán thành công
          final notificationController = Get.find<NotificationController>();
          await notificationController.fetchNotifications();
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