import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:client/core/services/auth_controller.dart';
import 'package:client/core/services/cart_controller.dart';
import 'order_confirmation_screen.dart';
import 'package:intl/intl.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert'; // Added for json.decode
import 'package:http/http.dart' as http; // Added for http
import 'package:flutter/material.dart';
import 'package:client/features/cart/address_selector.dart';
import 'package:client/core/services/shipping_service.dart';
import 'package:client/core/utils/api_service.dart';

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
  final TextEditingController _phoneController = TextEditingController();
  int shippingFee = 0;
  double discountAmount = 0.0;
  double finalPrice = 0.0;
  int? selectedDistrictId;
  String? selectedWardCode;
  PaymentMethod _selectedMethod = PaymentMethod.cod;
  bool _isLoading = false; // Added for loading state
  Future<void> _getShippingFee() async {
    if (selectedDistrictId == null || selectedWardCode == null) {
      print("Chưa chọn đủ thông tin địa chỉ để tính phí ship");
      return;
    }

    try {
      print("=== Bắt đầu tính phí vận chuyển ===");
      print("selectedDistrictId: $selectedDistrictId");
      print("selectedWardCode: $selectedWardCode");

      // Lấy service_id từ GHN
      final serviceId = await ShippingService.getAvailableServiceId(
        fromDistrict: 1442, // Quận của shop - Quận 1
        toDistrict: selectedDistrictId!,
      );

      if (serviceId == null) {
        print("GiaoHangNhanh không hỗ trợ giao hàng tại địa điểm này");
        setState(() {
          shippingFee = 0;
          finalPrice =
              widget.totalPrice - discountAmount; // Không cộng phí ship
        });
        return;
      }

      print("Service ID lấy được: $serviceId");

      // Tính phí ship
      final fee = await ShippingService.calculateShippingFee(
        fromDistrict: 1542,
        toDistrict: selectedDistrictId!,
        toWard: selectedWardCode!,
        weight: 1000,
        serviceId: serviceId,
      );

      print("Phí ship nhận được: $fee");

      setState(() {
        shippingFee = fee;
        finalPrice = widget.totalPrice - discountAmount + shippingFee;
      });

      print("=== Kết thúc tính phí vận chuyển ===");
    } catch (e) {
      print("Lỗi tính phí vận chuyển: $e");
      setState(() {
        shippingFee = 0;
      });
    }
  }

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

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        centerTitle: true,
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
      ),
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
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
              color: isDark ? Colors.grey[800] : Colors.white,
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
                                    : Icon(
                                      Icons.image,
                                      color:
                                          isDark ? Colors.white : Colors.grey,
                                    ),
                            title: Text(
                              e['name'] ?? '',
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                            subtitle: Text(
                              'Số lượng: ${e['quantity'] ?? 1}',
                              style: TextStyle(
                                color:
                                    isDark
                                        ? Colors.grey[300]
                                        : Colors.grey[600],
                              ),
                            ),
                            trailing: Text(
                              '${e['price'] ?? 0} đ',
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        )
                        .toList(),
              ),
            ),
            SizedBox(height: screenWidth * 0.04),
            //Card địa chỉ
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              color: isDark ? Colors.grey[800] : Colors.white,
              child: ListTile(
                leading: Icon(Icons.location_on, color: Colors.red),
                title: Text(
                  'Địa chỉ giao hàng',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                subtitle: Text(
                  _addressController.text.isNotEmpty
                      ? _addressController.text
                      : 'Chưa có địa chỉ',
                  style: TextStyle(
                    color: isDark ? Colors.grey[300] : Colors.grey[600],
                  ),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.edit, color: Theme.of(context).primaryColor),
                  onPressed: () async {
                    await _showSelectAddressDialog(context);
                  },
                ),
              ),
            ),

            SizedBox(height: screenWidth * 0.04),
            //Card số điện thoại
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              color: isDark ? Colors.grey[800] : Colors.white,
              child: ListTile(
                leading: Icon(Icons.phone, color: Colors.green),
                title: Text(
                  'Số điện thoại',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                subtitle: Text(
                  _phoneController.text.isNotEmpty
                      ? _phoneController.text
                      : 'Chưa có số điện thoại',
                  style: TextStyle(
                    color: isDark ? Colors.grey[300] : Colors.grey[600],
                  ),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.edit, color: Theme.of(context).primaryColor),
                  onPressed: () {
                    final tempPhoneController = TextEditingController(
                      text: _phoneController.text,
                    );
                    showDialog(
                      context: context,
                      builder:
                          (context) => AlertDialog(
                            backgroundColor:
                                isDark ? Colors.grey[800] : Colors.white,
                            title: Text(
                              'Chỉnh sửa số điện thoại',
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                            content: TextField(
                              controller: tempPhoneController,
                              keyboardType: TextInputType.phone,
                              maxLength: 11, // Giới hạn tối đa 11 ký tự
                              decoration: const InputDecoration(
                                counterText: '', // Ẩn bộ đếm ký tự
                                labelText: 'Số điện thoại giao hàng',
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter
                                    .digitsOnly, // Chỉ nhập số
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text(
                                  'Hủy',
                                  style: TextStyle(
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  String phone =
                                      tempPhoneController.text.trim();
                                  // Kiểm tra số điện thoại 10-11 số
                                  if (RegExp(
                                    r'^[0-9]{10,11}$',
                                  ).hasMatch(phone)) {
                                    setState(() {
                                      _phoneController.text = phone;
                                    });
                                    Navigator.of(context).pop();
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Số điện thoại phải là 10 hoặc 11 số!',
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: Text(
                                  'Lưu',
                                  style: TextStyle(
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                ),
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
              color: isDark ? Colors.grey[800] : Colors.white,
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
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                    RadioListTile<PaymentMethod>(
                      value: PaymentMethod.cod,
                      groupValue: _selectedMethod,
                      onChanged:
                          (value) => setState(() => _selectedMethod = value!),
                      title: Text(
                        'Thanh toán khi nhận hàng',
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      secondary: Icon(Icons.money, color: Colors.green),
                    ),
                    RadioListTile<PaymentMethod>(
                      value: PaymentMethod.momo,
                      groupValue: _selectedMethod,
                      onChanged:
                          (value) => setState(() => _selectedMethod = value!),
                      title: Text(
                        'Thanh toán bằng MoMo',
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
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
              color: isDark ? Colors.grey[800] : Colors.white,
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
                    _summaryRow(
                      'Phí vận chuyển',
                      '${currencyFormat.format(shippingFee)} đ',
                    ),
                    Divider(
                      color: isDark ? Colors.grey[600] : Colors.grey[300],
                    ),
                    _summaryRow(
                      'Tổng thanh toán',
                      '${currencyFormat.format(finalPrice + shippingFee)} đ',
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
              backgroundColor: Theme.of(context).primaryColor,
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
                    _selectedMethod == PaymentMethod.momo
                        ? 'momo'
                        : 'Thanh toán khi nhận hàng',
                totalPrice: finalPrice,
              );

              if (_selectedMethod == PaymentMethod.momo) {
                if (result['success'] == true &&
                    result['data'] != null &&
                    result['data']['payUrl'] != null) {
                  final payUrl = result['data']['payUrl'];
                  final checkoutId = result['data']['_id'];
                  final webViewController =
                      WebViewController()
                        ..setJavaScriptMode(JavaScriptMode.unrestricted)
                        ..setNavigationDelegate(
                          NavigationDelegate(
                            onNavigationRequest: (request) {
                              print('WebView điều hướng tới: ${request.url}');
                              // Nếu là redirectUrl hoặc có resultCode=0 thì đóng WebView và polling
                              if (request.url.startsWith(
                                    'https://google.com',
                                  ) ||
                                  request.url.contains('resultCode=0')) {
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
                      builder:
                          (_) => Scaffold(
                            appBar: AppBar(
                              title: const Text('Thanh toán MoMo'),
                              // Không có nút đóng
                            ),
                            body: WebViewWidget(controller: webViewController),
                          ),
                    ),
                  );
                } else {
                  print(
                    'Lỗi khi tạo thanh toán MoMo, result: ' +
                        (result['data']?.toString() ?? 'null'),
                  );
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
                  final id = result['data']?['_id'];
                  if (id == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Lỗi: Không nhận được ID đơn hàng'),
                      ),
                    );
                    return;
                  }
                  final orderCode =
                      result['data']?['orderCode'] ??
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
              'Đặt hàng (${currencyFormat.format(finalPrice + shippingFee)} đ)',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isTotal = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color:
                  isTotal
                      ? Theme.of(context).primaryColor
                      : (isDark ? Colors.white : Colors.black),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color:
                  isTotal
                      ? Theme.of(context).primaryColor
                      : (isDark ? Colors.white : Colors.black),
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
    const maxAttempts = 2; // 30 giây / 5 giây = 6 lần

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
                        phone:
                            _phoneController
                                .text, // Truyền số điện thoại từ controller
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
                Uri.parse(
                  'https://burgerking-j92p.onrender.com/api/checkout/$checkoutId/finalize',
                ),
                headers: {
                  'Authorization': 'Bearer $token',
                  'Content-Type': 'application/json',
                },
              );
              print('Finalize response status: ${finalizeResponse.statusCode}');
              print('Finalize response body: ${finalizeResponse.body}');
              if (finalizeResponse.statusCode == 200) {
                final orderData = json.decode(finalizeResponse.body);
                print(
                  'Finalize thành công, orderData: ${orderData.toString()}',
                );
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder:
                        (_) => OrderConfirmationScreen(
                          orderId: orderData['_id'],
                          orderCode:
                              orderData['orderCode'] ??
                              orderData['_id']
                                  .substring(orderData['_id'].length - 6)
                                  .toUpperCase(),
                          totalAmount:
                              orderData['totalPrice']?.toDouble() ??
                              widget.totalPrice,
                          paymentMethod:
                              orderData['paymentMethod'] ??
                              _selectedMethod.name,
                          shippingAddress:
                              orderData['shippingAddress'] ??
                              {
                                'address': _addressController.text,
                                'city': _cityController.text,
                                'district': _districtController.text,
                              },
                          orderItems:
                              orderData['orderItems'] ?? widget.cartProducts,
                          isPaymentSuccess: orderData['isPaid'] ?? true,
                        ),
                  ),
                );
                return;
              } else {
                print('Finalize lỗi: ${finalizeResponse.body}');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Lỗi khi finalize đơn hàng: ${finalizeResponse.body}',
                    ),
                  ),
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
                                'phone': _phoneController.text.trim(),
                                'address': _addressController.text,
                                'city': _cityController.text,
                                'district': _districtController.text,
                              },
                          orderItems:
                              latestOrder['orderItems'] ?? widget.cartProducts,
                          isPaymentSuccess: latestOrder['isPaid'] ?? true,

                          // Thêm dữ liệu từ checkout/cart
                          cartData: {
                            'phone': _phoneController.text.trim(),
                            'address': _addressController.text,
                            'district': _districtController.text,
                            'city': _cityController.text,
                          },
                          shippingFee: shippingFee,
                          totalPrice: widget.totalPrice,
                          finalPrice: finalPrice,
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
            Uri.parse(
              'https://burgerking-j92p.onrender.com/api/checkout/$checkoutId/finalize',
            ),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          );
          print(
            'Finalize response status (timeout): ${finalizeResponse.statusCode}',
          );
          print('Finalize response body (timeout): ${finalizeResponse.body}');
          if (finalizeResponse.statusCode == 200) {
            final orderData = json.decode(finalizeResponse.body);
            print(
              'Finalize thành công (timeout), orderData: ${orderData.toString()}',
            );
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder:
                    (_) => OrderConfirmationScreen(
                      orderId: orderData['_id'],
                      orderCode:
                          orderData['orderCode'] ??
                          orderData['_id']
                              .substring(orderData['_id'].length - 6)
                              .toUpperCase(),
                      totalAmount:
                          orderData['totalPrice']?.toDouble() ??
                          widget.totalPrice,
                      paymentMethod:
                          orderData['paymentMethod'] ?? _selectedMethod.name,
                      shippingAddress:
                          orderData['shippingAddress'] ??
                          {
                            'address': _addressController.text,
                            'city': _cityController.text,
                            'district': _districtController.text,
                          },
                      orderItems:
                          orderData['orderItems'] ?? widget.cartProducts,
                      isPaymentSuccess: orderData['isPaid'] ?? true,
                    ),
              ),
            );
            return;
          } else {
            print('Finalize lỗi (timeout): ${finalizeResponse.body}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Lỗi khi finalize đơn hàng: ${finalizeResponse.body}',
                ),
              ),
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

  Future<void> _showSelectAddressDialog(BuildContext context) async {
    final authController = Get.find<AuthController>();
    final token = authController.getToken();
    List<dynamic> addresses = [];
    bool isLoading = true;
    String? error;
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            if (isLoading) {
              ApiService.getAddresses(token!)
                  .then((res) {
                    setState(() {
                      addresses = res;
                      isLoading = false;
                    });
                  })
                  .catchError((e) {
                    setState(() {
                      error = e.toString();
                      isLoading = false;
                    });
                  });
            }
            return AlertDialog(
              title: const Text('Chọn địa chỉ giao hàng'),
              content:
                  isLoading
                      ? const SizedBox(
                        height: 100,
                        child: Center(child: CircularProgressIndicator()),
                      )
                      : error != null
                      ? Text(error!)
                      : addresses.isEmpty
                      ? const Text('Bạn chưa có địa chỉ nào')
                      : SizedBox(
                        width: 350,
                        height: 300,
                        child: ListView.builder(
                          itemCount: addresses.length,
                          itemBuilder: (context, i) {
                            final addr = addresses[i];
                            return Card(
                              color:
                                  addr['isDefault'] == true
                                      ? Colors.orange[50]
                                      : null,
                              child: ListTile(
                                title: Text(
                                  '${addr['name']} - ${addr['phone']}',
                                ),
                                subtitle: Text(
                                  '${addr['street']}, ${addr['ward']}, ${addr['district']}, ${addr['city']}' +
                                      (addr['isDefault'] == true
                                          ? ' (Mặc định)'
                                          : ''),
                                ),
                                onTap: () {
                                  Navigator.of(context).pop(addr);
                                },
                              ),
                            );
                          },
                        ),
                      ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Đóng'),
                ),
              ],
            );
          },
        );
      },
    ).then((selectedAddr) {
      if (selectedAddr != null) {
        setState(() {
          _addressController.text =
              '${selectedAddr['street'] ?? ''}, ${selectedAddr['ward'] ?? ''}, ${selectedAddr['district'] ?? ''}, ${selectedAddr['city'] ?? ''}';
          _cityController.text = selectedAddr['city'] ?? '';
          _districtController.text = selectedAddr['district'] ?? '';
          _phoneController.text = selectedAddr['phone'] ?? '';
        });
        // Nếu cần tính lại phí ship, có thể gọi _getShippingFee() ở đây
      }
    });
  }
}
