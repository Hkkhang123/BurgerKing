import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';
import 'package:client/core/services/auth_controller.dart';
import 'package:client/core/services/cart_controller.dart';
import 'order_confirmation_screen.dart';

enum PaymentMethod { cod, momo }

class CheckoutScreen extends StatefulWidget {
  final List<dynamic> cartProducts;
  final double totalPrice;

  const CheckoutScreen({
    Key? key,
    required this.cartProducts,
    required this.totalPrice,
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
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _addressController.dispose();
    _cityController.dispose();
    _phoneController.dispose();
    _receiverController.dispose();
    super.dispose();
  }

  // Hàm kiểm tra trạng thái thanh toán
  // Hàm này không được sử dụng

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Danh sách sản phẩm
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 2,
              color: Colors.white,
              child: Column(
                children: widget.cartProducts.map<Widget>((e) => ListTile(
                  leading: e['image'] != null && e['image'] != ''
                      ? Image.network(e['image'], width: 40, height: 40, fit: BoxFit.cover)
                      : Icon(Icons.image),
                  title: Text(e['name'] ?? ''),
                  subtitle: Text('Số lượng: ${e['quantity'] ?? 1}'),
                  trailing: Text('${e['price'] ?? 0} đ'),
                )).toList(),
              ),
            ),
            const SizedBox(height: 16),
            // Địa chỉ giao hàng
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 2,
              color: Colors.white,
              child: ListTile(
                leading: Icon(Icons.location_on, color: Colors.red),
                title: Text('Địa chỉ giao hàng', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(_addressController.text.isNotEmpty ? _addressController.text : 'Chưa có địa chỉ'),
                trailing: IconButton(
                  icon: Icon(Icons.edit, color: Colors.orange),
                  onPressed: () {
                    final tempController = TextEditingController(text: _addressController.text);
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Chỉnh sửa địa chỉ'),
                        content: TextField(
                          controller: tempController,
                          decoration: InputDecoration(labelText: 'Địa chỉ giao hàng'),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text('Hủy'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _addressController.text = tempController.text;
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
            const SizedBox(height: 16),
            // Phương thức thanh toán
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 2,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text('Phương thức thanh toán', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    RadioListTile<PaymentMethod>(
                      value: PaymentMethod.cod,
                      groupValue: _selectedMethod,
                      onChanged: (value) => setState(() => _selectedMethod = value!),
                      title: Text('Thanh toán khi nhận hàng'),
                      secondary: Icon(Icons.money, color: Colors.green),
                    ),
                    RadioListTile<PaymentMethod>(
                      value: PaymentMethod.momo,
                      groupValue: _selectedMethod,
                      onChanged: (value) => setState(() => _selectedMethod = value!),
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
            const SizedBox(height: 16),
            // Tóm tắt đơn hàng (chỉ còn Total)
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 2,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Bỏ Subtotal
                    // Divider(),
                    _summaryRow('Total', '${widget.totalPrice.toStringAsFixed(0)} đ', isTotal: true),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Nút đặt hàng xuống dưới cùng
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              final authController = Get.find<AuthController>();
              final cartController = Get.find<CartController>();
              final token = authController.getToken();
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
                'phone': _phoneController.text,
                'receiver': _receiverController.text,
              };
              if (_selectedMethod == PaymentMethod.momo) {
                final result = await cartController.checkout(
                  token,
                  checkoutItem: checkoutItems,
                  shippingAddress: shippingAddress,
                  paymentMethod: 'momo',
                  totalPrice: widget.totalPrice,
                );
                if (result['success'] == true && result['data'] != null && result['data']['payUrl'] != null) {
                  final payUrl = result['data']['payUrl'];
                  if (await canLaunchUrl(Uri.parse(payUrl))) {
                    await launchUrl(Uri.parse(payUrl));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Không thể mở trang thanh toán MoMo.')));
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['data']?['message'] ?? 'Lỗi khi tạo thanh toán MoMo')));
                }
              } else {
                final result = await cartController.checkout(
                  token,
                  checkoutItem: checkoutItems,
                  shippingAddress: shippingAddress,
                  paymentMethod: 'cod',
                  totalPrice: widget.totalPrice,
                );
                if (result['success'] == true) {
                  final id = result['data']['_id'];
                  final orderCode = result['data']['orderCode'] ?? id.substring(id.length - 6).toUpperCase();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => OrderConfirmationScreen(
                        orderId: id,
                        orderCode: orderCode,
                        totalAmount: widget.totalPrice,
                        paymentMethod: 'cod',
                        shippingAddress: shippingAddress,
                        orderItems: widget.cartProducts,
                        isPaymentSuccess: false,
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['data']?['message'] ?? 'Lỗi khi đặt hàng')));
                }
              }
            },
            child: Text('Đặt hàng (${widget.totalPrice.toStringAsFixed(0)} đ)', style: TextStyle(fontSize: 18, color: Colors.white)),
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
          Text(label, style: TextStyle(fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, color: isTotal ? Colors.orange : Colors.black)),
          Text(value, style: TextStyle(fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, color: isTotal ? Colors.orange : Colors.black)),
        ],
      ),
    );
  }
}
