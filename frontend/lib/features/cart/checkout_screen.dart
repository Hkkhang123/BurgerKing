import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';
import 'package:client/core/services/auth_controller.dart';
import 'package:client/core/services/cart_controller.dart';
import 'order_confirmation_screen.dart';
import 'package:intl/intl.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert'; // Added for json.decode
import 'package:http/http.dart' as http; // Added for http

enum PaymentMethod { cod, momo }

class CheckoutScreen extends StatefulWidget {
  final List<dynamic> cartProducts;
  final double totalPrice;
  final String? promoCode;
  final String? discountType;
  final num? discountValue;

  const CheckoutScreen({
    Key? key,
    required this.cartProducts,
    required this.totalPrice,
    this.promoCode,
    this.discountType,
    this.discountValue,
  }) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _addressController = TextEditingController(
    text: '123 Đường ABC, Quận 1, TP.HCM',
  );
  final _cityController = TextEditingController(text: 'Hồ Chí Minh');
  final _districtController = TextEditingController(text: 'Quận 1');
  PaymentMethod _selectedMethod = PaymentMethod.cod;
  bool _isLoading = false; // Added for loading state

  @override
  void dispose() {
    _addressController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final currencyFormat = NumberFormat("#,##0", "vi_VN");
    double discountAmount = 0;
    if (widget.discountType == 'percent') {
      discountAmount = (widget.discountValue ?? 0) / 100 * widget.totalPrice;
    } else if (widget.discountType == 'fixed') {
      discountAmount = (widget.discountValue ?? 0).toDouble();
    }
    final double finalPrice = widget.totalPrice - discountAmount;

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout'), centerTitle: true),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              color: Colors.white,
              child: Column(
                children:
                    widget.cartProducts
                        .map<Widget>(
                          (e) => ListTile(
                            leading:
                                e['image'] != null && e['image'] != ''
                                    ? Image.network(
                                      e['image'],
                                      width: screenWidth * 0.1,
                                      height: screenWidth * 0.1,
                                      fit: BoxFit.cover,
                                    )
                                    : Icon(Icons.image),
                            title: Text(e['name'] ?? ''),
                            subtitle: Text('Số lượng: ${e['quantity'] ?? 1}'),
                            trailing: Text('${e['price'] ?? 0} đ'),
                          ),
                        )
                        .toList(),
              ),
            ),
            SizedBox(height: screenWidth * 0.04),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              color: Colors.white,
              child: ListTile(
                leading: Icon(Icons.location_on, color: Colors.red),
                title: Text(
                  'Địa chỉ giao hàng',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  _addressController.text.isNotEmpty
                      ? _addressController.text
                      : 'Chưa có địa chỉ',
                ),
                trailing: IconButton(
                  icon: Icon(Icons.edit, color: Colors.orange),
                  onPressed: () {
                    final tempController = TextEditingController(
                      text: _addressController.text,
                    );
                    showDialog(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            title: Text('Chỉnh sửa địa chỉ'),
                            content: TextField(
                              controller: tempController,
                              decoration: InputDecoration(
                                labelText: 'Địa chỉ giao hàng',
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text('Hủy'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _addressController.text =
                                        tempController.text;
                                  });
                                  Navigator.of(context).pop();
                                },
                                child: Text('Lưu'),
                              ),
                            ],
                          ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: screenWidth * 0.04),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: screenWidth * 0.02),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.04,
                        vertical: screenWidth * 0.02,
                      ),
                      child: Text(
                        'Phương thức thanh toán',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    RadioListTile<PaymentMethod>(
                      value: PaymentMethod.cod,
                      groupValue: _selectedMethod,
                      onChanged:
                          (value) => setState(() => _selectedMethod = value!),
                      title: Text('Thanh toán khi nhận hàng'),
                      secondary: Icon(Icons.money, color: Colors.green),
                    ),
                    RadioListTile<PaymentMethod>(
                      value: PaymentMethod.momo,
                      groupValue: _selectedMethod,
                      onChanged:
                          (value) => setState(() => _selectedMethod = value!),
                      title: Text('Thanh toán bằng MoMo'),
                      secondary: SizedBox(
                        width: 32,
                        height: 32,
                        child: Image.asset('assets/images/momo_logo.png'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: screenWidth * 0.04),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: Column(
                  children: [
                    if (widget.promoCode != null)
                      _summaryRow(
                        'Mã: ${widget.promoCode} (${widget.discountType == 'percent' ? '-${widget.discountValue}%' : '-${widget.discountValue}đ'})',
                        '',
                      ),
                    if (discountAmount > 0)
                      _summaryRow(
                        'Bạn đã tiết kiệm',
                        '${currencyFormat.format(discountAmount)} đ',
                      ),
                    _summaryRow(
                      'Tổng gốc',
                      '${currencyFormat.format(widget.totalPrice)} đ',
                    ),
                    Divider(),
                    _summaryRow(
                      'Tổng thanh toán',
                      '${currencyFormat.format(finalPrice)} đ',
                      isTotal: true,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: screenWidth * 0.06),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(
          screenWidth * 0.04,
          0,
          screenWidth * 0.04,
          screenWidth * 0.06,
        ),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              final authController = Get.find<AuthController>();
              final cartController = Get.find<CartController>();
              final token = authController.getToken();
              final checkoutItems =
                  widget.cartProducts
                      .map(
                        (e) => {
                          'productId': e['productId'] ?? e['_id'] ?? e['id'],
                          'quantity': e['quantity'] ?? 1,
                          'price': e['price'] ?? 0,
                          'name': e['name'] ?? '',
                          'image': e['image'] ?? '',
                        },
                      )
                      .toList();
              final shippingAddress = {
                'address': _addressController.text,
                'city': _cityController.text,
                'district': _districtController.text,
              };

              final result = await cartController.checkout(
                token,
                checkoutItem: checkoutItems,
                shippingAddress: shippingAddress,
                paymentMethod:
                    _selectedMethod == PaymentMethod.momo ? 'momo' : 'cod',
                totalPrice: finalPrice,
              );

              if (_selectedMethod == PaymentMethod.momo) {
                if (result['success'] == true &&
                    result['data'] != null &&
                    result['data']['payUrl'] != null) {
                  final payUrl = result['data']['payUrl'];
                  final checkoutId = result['data']['_id'];
                  final webViewController = WebViewController()
                    ..setJavaScriptMode(JavaScriptMode.unrestricted)
                    ..setNavigationDelegate(
                      NavigationDelegate(
                        onNavigationRequest: (request) {
                          print('WebView điều hướng tới: ${request.url}');
                          // Nếu là redirectUrl hoặc có resultCode=0 thì đóng WebView và polling
                          if (request.url.startsWith('https://google.com') || request.url.contains('resultCode=0')) {
                            Navigator.of(context).pop();
                            _checkPaymentStatus(checkoutId);
                            return NavigationDecision.prevent;
                          }
                          return NavigationDecision.navigate;
                        },
                      ),
                    )
                    ..loadRequest(Uri.parse(payUrl));
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => Scaffold(
                        appBar: AppBar(
                          title: const Text('Thanh toán MoMo'),
                          // Không có nút đóng
                        ),
                        body: WebViewWidget(controller: webViewController),
                      ),
                    ),
                  );
                } else {
                  print('Lỗi khi tạo thanh toán MoMo, result: ' + (result['data']?.toString() ?? 'null'));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        result['data']?['message'] ??
                            'Lỗi khi tạo thanh toán MoMo',
                      ),
                    ),
                  );
                }
              } else {
                if (result['success'] == true) {
                  final id = result['data']['_id'];
                  final orderCode =
                      result['data']['orderCode'] ??
                      id.substring(id.length - 6).toUpperCase();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder:
                          (_) => OrderConfirmationScreen(
                            orderId: id,
                            orderCode: orderCode,
                            totalAmount: finalPrice,
                            paymentMethod: 'cod',
                            shippingAddress: shippingAddress,
                            orderItems: widget.cartProducts,
                            isPaymentSuccess: false,
                          ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        result['data']?['message'] ?? 'Lỗi khi đặt hàng',
                      ),
                    ),
                  );
                }
              }
            },
            child: Text(
              'Đặt hàng (${currencyFormat.format(finalPrice)} đ)',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.orange : Colors.black,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.orange : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  // Hàm kiểm tra trạng thái thanh toán
  Future<void> _checkPaymentStatus(String checkoutId) async {
    setState(() {
      _isLoading = true;
    });

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
          Uri.parse(
            'https://burgerking-j92p.onrender.com/api/checkout/$checkoutId',
          ),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        print('API Response Status: ${response.statusCode}');
        print('API Response Body: ${response.body}');

        if (response.statusCode == 200) {
          final checkoutData = json.decode(response.body);
          print('Parsed checkout data: ${checkoutData}');

          final paymentStatus = checkoutData['paymentStatus'];
          final isPaid = checkoutData['isPaid'] ?? false;
          final isFinalized = checkoutData['isFinalized'] ?? false;

          print(
            'Payment Status: $paymentStatus, isPaid: $isPaid, isFinalized: $isFinalized',
          );

          // Kiểm tra nếu đã finalize thì cũng coi như thành công
          if (paymentStatus == 'Đã thanh toán' ||
              isPaid == true ||
              isFinalized == true) {
            setState(() {
              _isLoading = false;
            });
            // Nếu đã finalize thì chuyển luôn, nếu chưa thì gọi finalizeCheckout
            if (isFinalized == true) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => OrderConfirmationScreen(
                    checkoutId: checkoutId,
                    orderCode: checkoutData['orderCode'] ?? checkoutId.substring(checkoutId.length - 6).toUpperCase(),
                    totalAmount: widget.totalPrice,
                    paymentMethod: _selectedMethod.name,
                    shippingAddress: {
                      'address': _addressController.text,
                      'city': _cityController.text,
                      'district': _districtController.text,
                    },
                    orderItems: widget.cartProducts,
                    isPaymentSuccess: true,
                  ),
                ),
              );
              return;
            } else if (isPaid == true && isFinalized == false) {
              print('Gọi finalizeCheckout cho $checkoutId');
              final authController = Get.find<AuthController>();
              final token = authController.getToken();
              final finalizeResponse = await http.post(
                Uri.parse('https://burgerking-j92p.onrender.com/api/checkout/$checkoutId/finalize'),
                headers: {
                  'Authorization': 'Bearer $token',
                  'Content-Type': 'application/json',
                },
              );
              print('Finalize response status: ${finalizeResponse.statusCode}');
              print('Finalize response body: ${finalizeResponse.body}');
              if (finalizeResponse.statusCode == 200) {
                final orderData = json.decode(finalizeResponse.body);
                print('Finalize thành công, orderData: ${orderData.toString()}');
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => OrderConfirmationScreen(
                      orderId: orderData['_id'],
                      orderCode: orderData['orderCode'] ?? orderData['_id'].substring(orderData['_id'].length - 6).toUpperCase(),
                      totalAmount: orderData['totalPrice']?.toDouble() ?? widget.totalPrice,
                      paymentMethod: orderData['paymentMethod'] ?? _selectedMethod.name,
                      shippingAddress: orderData['shippingAddress'] ?? {
                        'address': _addressController.text,
                        'city': _cityController.text,
                        'district': _districtController.text,
                      },
                      orderItems: orderData['orderItems'] ?? widget.cartProducts,
                      isPaymentSuccess: orderData['isPaid'] ?? true,
                    ),
                  ),
                );
                return;
              } else {
                print('Finalize lỗi: ${finalizeResponse.body}');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Lỗi khi finalize đơn hàng: ${finalizeResponse.body}')),
                );
                return;
              }
            }
            // Chuyển đến trang xác nhận đơn hàng với checkoutId
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder:
                    (_) => OrderConfirmationScreen(
                      checkoutId: checkoutId,
                      orderCode:
                          checkoutData['orderCode'] ??
                          checkoutId
                              .substring(checkoutId.length - 6)
                              .toUpperCase(),
                      totalAmount: widget.totalPrice,
                      paymentMethod: _selectedMethod.name,
                      shippingAddress: {
                        'address': _addressController.text,
                        'city': _cityController.text,
                        'district': _districtController.text,
                      },
                      orderItems: widget.cartProducts,
                      isPaymentSuccess: true,
                    ),
              ),
            );
            return; // Thoát khỏi polling
          } else if (paymentStatus == 'Thanh toán thất bại') {
            setState(() {
              _isLoading = false;
            });
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
              Uri.parse(
                'https://burgerking-j92p.onrender.com/api/order/my-order',
              ),
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

                setState(() {
                  _isLoading = false;
                });

                // Chuyển đến trang xác nhận đơn hàng với orderId thực
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder:
                        (_) => OrderConfirmationScreen(
                          orderId: latestOrder['_id'],
                          orderCode:
                              latestOrder['orderCode'] ??
                              latestOrder['_id']
                                  .substring(latestOrder['_id'].length - 6)
                                  .toUpperCase(),
                          totalAmount:
                              latestOrder['totalPrice']?.toDouble() ??
                              widget.totalPrice,
                          paymentMethod:
                              latestOrder['paymentMethod'] ??
                              _selectedMethod.name,
                          shippingAddress:
                              latestOrder['shippingAddress'] ??
                              {
                                'address': _addressController.text,
                                'city': _cityController.text,
                                'district': _districtController.text,
                              },
                          orderItems:
                              latestOrder['orderItems'] ?? widget.cartProducts,
                          isPaymentSuccess: latestOrder['isPaid'] ?? true,
                        ),
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
    print(
      'Polling timeout after 30 seconds, trying to check MoMo payment status directly...',
    );
    try {
      final authController = Get.find<AuthController>();
      final token = authController.getToken();

      // Gọi API để kiểm tra trạng thái thanh toán từ MoMo
      final momoStatusResponse = await http.post(
        Uri.parse(
          'https://burgerking-j92p.onrender.com/api/payment/momo/status',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'checkoutId': checkoutId}),
      );

      if (momoStatusResponse.statusCode == 200) {
        final momoStatusData = json.decode(momoStatusResponse.body);
        print('MoMo status response: $momoStatusData');

        if (momoStatusData['success'] == true &&
            momoStatusData['isPaid'] == true) {
          setState(() {
            _isLoading = false;
          });
          // Gọi finalizeCheckout
          final authController = Get.find<AuthController>();
          final token = authController.getToken();
          final finalizeResponse = await http.post(
            Uri.parse('https://burgerking-j92p.onrender.com/api/checkout/$checkoutId/finalize'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          );
          print('Finalize response status (timeout): ${finalizeResponse.statusCode}');
          print('Finalize response body (timeout): ${finalizeResponse.body}');
          if (finalizeResponse.statusCode == 200) {
            final orderData = json.decode(finalizeResponse.body);
            print('Finalize thành công (timeout), orderData: ${orderData.toString()}');
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => OrderConfirmationScreen(
                  orderId: orderData['_id'],
                  orderCode: orderData['orderCode'] ?? orderData['_id'].substring(orderData['_id'].length - 6).toUpperCase(),
                  totalAmount: orderData['totalPrice']?.toDouble() ?? widget.totalPrice,
                  paymentMethod: orderData['paymentMethod'] ?? _selectedMethod.name,
                  shippingAddress: orderData['shippingAddress'] ?? {
                    'address': _addressController.text,
                    'city': _cityController.text,
                    'district': _districtController.text,
                  },
                  orderItems: orderData['orderItems'] ?? widget.cartProducts,
                  isPaymentSuccess: orderData['isPaid'] ?? true,
                ),
              ),
            );
            return;
          } else {
            print('Finalize lỗi (timeout): ${finalizeResponse.body}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Lỗi khi finalize đơn hàng: ${finalizeResponse.body}')),
            );
            return;
          }
        }
      }
    } catch (e) {
      print('Error checking MoMo status: $e');
    }

    // Hết thời gian polling
    setState(() {
      _isLoading = false;
    });

    // Hiển thị dialog với thông tin chi tiết
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Thông báo'),
            content: const Text(
              'Không thể xác nhận trạng thái thanh toán sau 30 giây.\n\n'
              'Có thể:\n'
              '• Thanh toán đang được xử lý\n'
              '• Có vấn đề với kết nối mạng\n'
              '• MoMo chưa gửi thông báo xác nhận\n\n'
              'Bạn có thể:\n'
              '• Kiểm tra lại sau vài phút\n'
              '• Liên hệ hỗ trợ nếu đã thanh toán thành công',
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
}