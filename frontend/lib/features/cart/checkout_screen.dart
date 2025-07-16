import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';
import 'package:client/core/services/auth_controller.dart';
import 'package:client/core/services/cart_controller.dart';
import 'order_confirmation_screen.dart';
import 'package:intl/intl.dart';

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
  final _postalCodeController = TextEditingController(text: '700000');
  PaymentMethod _selectedMethod = PaymentMethod.cod;

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
}