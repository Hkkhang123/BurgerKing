import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:client/core/services/cart_controller.dart';
import 'package:client/core/services/auth_controller.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:webview_flutter/webview_flutter.dart';
import 'order_confirmation_screen.dart';
import 'package:intl/intl.dart';
import 'package:client/core/services/order_service.dart';

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
  final _phoneController = TextEditingController(text: '0123456789');
  final _receiverController = TextEditingController(text: 'Khách hàng');
  final _districtController = TextEditingController(text: 'Quận 1');
  bool _isLoading = false;
  late final WebViewController _webViewController;
  PaymentMethod _selectedMethod = PaymentMethod.cod;

  @override
  void initState() {
    super.initState();
    _webViewController =
        WebViewController()..setJavaScriptMode(JavaScriptMode.unrestricted);
  }

  @override
  void dispose() {
    _addressController.dispose();
    _cityController.dispose();
    _phoneController.dispose();
    _receiverController.dispose();
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
                      
  Future<void> _handleConfirmCheckout() async {
    setState(() {
      _isLoading = true;
    });
    final authController = Get.find<AuthController>();
    final token = authController.getToken();
    final cartController = Get.find<CartController>();
    final List<Map<String, dynamic>> checkoutItems =
        widget.cartProducts
            .map(
              (e) => {
                'productId': e['productId'] ?? e['_id'] ?? e['id'],
                'quantity': e['quantity'] ?? 1,
                'price': e['discountPrice'] ?? e['price'] ?? 0,
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
    final paymentMethodStr =
        _selectedMethod == PaymentMethod.momo ? 'momo' : 'cod';
    final result = await cartController.checkout(
      token,
      checkoutItem: checkoutItems,
      shippingAddress: shippingAddress,
      paymentMethod: paymentMethodStr,
      totalPrice: widget.totalPrice,
    );
    setState(() {
      _isLoading = false;
    });
    if (!mounted) return;
    if (result['success'] == true) {
      final id = result['data']['_id'];
      final orderCode =
          result['data']['orderCode'] ??
          id.substring(id.length - 6).toUpperCase();

      if (paymentMethodStr == 'cod') {
        // Với thanh toán khi nhận hàng, API tạo Order ngay lập tức
        // nên _id là orderId
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder:
                (_) => OrderConfirmationScreen(
                  orderId: id, // Đây là orderId thực
                  orderCode: orderCode,
                  totalAmount: widget.totalPrice,
                  paymentMethod: paymentMethodStr,
                  shippingAddress: {
                    'address': _addressController.text,
                    'city': _cityController.text,
                    'district': _districtController.text,
                  },
                  orderItems: widget.cartProducts,
                  isPaymentSuccess: false, // Chưa thanh toán
                ),
          ),
        );
      } else {
        // Thanh toán thường
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Đặt hàng thành công!')));
        Navigator.of(context).pop(true);
      }
    } else {
      String errorMsg =
          result['data']?['message'] ?? result['error'] ?? 'Lỗi khi thanh toán';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMsg)));
    }
  }

  // Dialog xác nhận thanh toán khi nhận hàng
  void _showPaymentConfirmationDialog(String orderCode) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text('Đặt hàng thành công!'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 64),
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
                      Text(
                        '• Bạn có thể theo dõi trạng thái trong "Đơn hàng của tôi"',
                      ),
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
      builder:
          (context) => AlertDialog(
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
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('🏷️ Mã đơn hàng: $orderCode'),
                        const SizedBox(height: 4),
                        Text(
                          '💰 Tổng tiền: ${widget.totalPrice.toStringAsFixed(0)} đ',
                        ),
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
                  const Text(
                    '📋 Sản phẩm:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  ...widget.cartProducts.map(
                    (e) => Container(
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
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  'Số lượng: ${e['quantity'] ?? 1}',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
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
          print('Parsed checkout data: $checkoutData');

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
                'phone': _phoneController.text,
                'receiver': _receiverController.text,
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
                  if (await canLaunchUrl(Uri.parse(payUrl))) {
                    await launchUrl(Uri.parse(payUrl));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Không thể mở trang thanh toán MoMo.'),
                      ),
                    );
                  }
                } else {
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

            child: Text(
              'Đặt hàng (${currencyFormat.format(finalPrice)} đ)',
              style: TextStyle(fontSize: 18, color: Colors.white),

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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text(
              'Xác nhận đơn hàng',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            elevation: 0,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
          ),
          backgroundColor: Colors.grey[100],
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sản phẩm
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.shopping_bag, color: Colors.orange[700]),
                            const SizedBox(width: 8),
                            const Text(
                              'Sản phẩm',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        ...widget.cartProducts
                            .map<Widget>(
                              (e) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                ),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child:
                                          e['image'] != null && e['image'] != ''
                                              ? Image.network(
                                                e['image'],
                                                width: 48,
                                                height: 48,
                                                fit: BoxFit.cover,
                                              )
                                              : Container(
                                                width: 48,
                                                height: 48,
                                                color: Colors.grey[300],
                                                child: Icon(
                                                  Icons.image,
                                                  color: Colors.grey[500],
                                                ),
                                              ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            e['name'] ?? '',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Số lượng: ${e['quantity'] ?? 1}',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '${e['price'] ?? 0} đ',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                        const Divider(height: 32),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Tổng tiền:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '${widget.totalPrice.toStringAsFixed(0)} đ',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.orange[700],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Địa chỉ giao hàng
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.location_on, color: Colors.red[400]),
                            const SizedBox(width: 8),
                            const Text(
                              'Địa chỉ giao hàng',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        _infoRow('Địa chỉ', _addressController.text),
                        _infoRow('Thành phố', _cityController.text),
                        _infoRow('Quận/Huyện', _districtController.text),
                        _infoRow('Số điện thoại', _phoneController.text),
                        _infoRow('Người nhận', _receiverController.text),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () {
                              final tempController = TextEditingController(
                                text: _addressController.text,
                              );
                              showDialog(
                                context: context,
                                builder:
                                    (context) => AlertDialog(
                                      title: const Text('Chỉnh sửa địa chỉ'),
                                      content: TextField(
                                        controller: tempController,
                                        decoration: const InputDecoration(
                                          labelText: 'Địa chỉ giao hàng',
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed:
                                              () => Navigator.of(context).pop(),
                                          child: const Text('Hủy'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            setState(() {
                                              _addressController.text =
                                                  tempController.text;
                                            });
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('Lưu'),
                                        ),
                                      ],
                                    ),
                              );
                            },
                            icon: const Icon(Icons.edit, size: 18),
                            label: const Text(
                              'Sửa',
                              style: TextStyle(fontSize: 14),
                            ),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.orange[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Phương thức thanh toán
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.payment, color: Colors.purple[400]),
                            const SizedBox(width: 8),
                            const Text(
                              'Phương thức thanh toán',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        RadioListTile<PaymentMethod>(
                          value: PaymentMethod.cod,
                          groupValue: _selectedMethod,
                          onChanged:
                              (value) =>
                                  setState(() => _selectedMethod = value!),
                          title: const Text('Thanh toán khi nhận hàng'),
                          secondary: Icon(Icons.money, color: Colors.green),
                        ),
                        RadioListTile<PaymentMethod>(
                          value: PaymentMethod.momo,
                          groupValue: _selectedMethod,
                          onChanged:
                              (value) =>
                                  setState(() => _selectedMethod = value!),
                          title: const Text('Thanh toán bằng MoMo'),
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
                const SizedBox(height: 32),
              ],
            ),
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
                onPressed: () async {
                  setState(() {
                    _isLoading = true;
                  });
                  if (_selectedMethod == PaymentMethod.momo) {
                    final authController = Get.find<AuthController>();
                    final token = authController.getToken();
                    final cartController = Get.find<CartController>();
                    final List<Map<String, dynamic>> checkoutItems =
                        widget.cartProducts
                            .map(
                              (e) => {
                                'productId':
                                    e['productId'] ?? e['_id'] ?? e['id'],
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
                    // 1. Gọi API tạo đơn hàng
                    final result = await cartController.checkout(
                      token,
                      checkoutItem: checkoutItems,
                      shippingAddress: shippingAddress,
                      paymentMethod: _selectedMethod.name,
                      totalPrice: widget.totalPrice,
                    );
                    setState(() {
                      _isLoading = false;
                    });
                    if (!mounted) return;
                    if (result['success'] == true) {
                      final checkoutId = result['data']['_id'];
                      final amount = result['data']['totalPrice'];
                      try {
                        final response = await http.post(
                          Uri.parse(
                            'https://burgerking-j92p.onrender.com/api/payment/momo/test',
                          ),
                          headers: {'Content-Type': 'application/json'},
                          body: json.encode({
                            'checkoutId': checkoutId,
                            'amount': amount.toString(),
                          }),
                        );
                        if (response.statusCode == 200) {
                          final data = json.decode(response.body);
                          final payUrl =
                              data['payUrl'] ??
                              data['deeplink'] ??
                              data['deeplinkWeb'] ??
                              '';
                          if (payUrl.isNotEmpty) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder:
                                    (_) => Scaffold(
                                      appBar: AppBar(
                                        title: const Text('Thanh toán MoMo'),
                                        leading: IconButton(
                                          icon: const Icon(Icons.close),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ),
                                      body: WebViewWidget(
                                        controller:
                                            WebViewController()
                                              ..setJavaScriptMode(
                                                JavaScriptMode.unrestricted,
                                              )
                                              ..setNavigationDelegate(
                                                NavigationDelegate(
                                                  onNavigationRequest: (
                                                    request,
                                                  ) {
                                                    // Nếu URL chứa kết quả thanh toán thành công
                                                    if (request.url.contains(
                                                          'success',
                                                        ) ||
                                                        request.url.contains(
                                                          'resultCode=0',
                                                        )) {
                                                      Navigator.of(
                                                        context,
                                                      ).pop();
                                                      _checkPaymentStatus(
                                                        checkoutId,
                                                      );
                                                      return NavigationDecision
                                                          .prevent;
                                                    }
                                                    return NavigationDecision
                                                        .navigate;
                                                  },
                                                ),
                                              )
                                              ..loadRequest(Uri.parse(payUrl)),
                                      ),
                                    ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Không lấy được link thanh toán MoMo!',
                                ),
                              ),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Lỗi: ${response.body}')),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Lỗi kết nối MoMo: $e')),
                        );
                      }
                    }
                  } else {
                    await _handleConfirmCheckout();
                  }
                },
                child: Text(
                  'Xác nhận đặt hàng (${widget.totalPrice.toStringAsFixed(0)} đ)',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

            ),
          ),
        ),
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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

          SizedBox(
            width: 110,
            child: Text(
              '$label:',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),

        ],
      ),
    );
  }
}
