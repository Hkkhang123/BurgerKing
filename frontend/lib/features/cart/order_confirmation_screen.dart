import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:client/features/order/my_order_screen.dart';
import 'package:client/features/home/main_screen.dart';
import 'package:client/core/services/navigation_controller.dart';
import 'package:client/core/services/order_service.dart';
import 'package:client/core/services/auth_controller.dart';

class OrderConfirmationScreen extends StatefulWidget {
  final String? orderId;
  final String? checkoutId;
  final String? orderCode;
  final double? totalAmount;
  final String? paymentMethod;
  final Map<String, dynamic>? shippingAddress;
  final List<dynamic>? orderItems;
  final bool? isPaymentSuccess;

  // Constructor cho dữ liệu có sẵn (từ checkout)
  const OrderConfirmationScreen({
    Key? key,
    this.orderId,
    this.checkoutId,
    this.orderCode,
    this.totalAmount,
    this.paymentMethod,
    this.shippingAddress,
    this.orderItems,
    this.isPaymentSuccess = true,
  }) : super(key: key);

  // Constructor factory để load từ database
  factory OrderConfirmationScreen.fromOrderId(String orderId) {
    return OrderConfirmationScreen(orderId: orderId);
  }

  factory OrderConfirmationScreen.fromCheckoutId(String checkoutId) {
    return OrderConfirmationScreen(checkoutId: checkoutId);
  }

  @override
  State<OrderConfirmationScreen> createState() => _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _checkmarkController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Dữ liệu từ database
  Map<String, dynamic>? _orderData;
  bool _isLoading = true;
  String? _errorMessage;

  // Dữ liệu hiển thị
  String get orderId => _orderData?['_id'] ?? widget.orderId ?? '';
  String get orderCode => _orderData?['orderCode'] ?? widget.orderCode ?? '';
  double get totalAmount => _orderData?['totalPrice']?.toDouble() ?? widget.totalAmount ?? 0.0;
  String get paymentMethod => _orderData?['paymentMethod'] ?? widget.paymentMethod ?? '';
  Map<String, dynamic> get shippingAddress => _orderData?['shippingAddress'] ?? widget.shippingAddress ?? {};
  List<dynamic> get orderItems => _orderData?['orderItems'] ?? widget.orderItems ?? [];
  bool get isPaymentSuccess => _orderData?['isPaid'] ?? widget.isPaymentSuccess ?? false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _checkmarkController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _animationController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      _checkmarkController.forward();
    });

    // Load dữ liệu từ database nếu cần
    _loadOrderData();
  }

  Future<void> _loadOrderData() async {
    if (widget.orderId != null || widget.checkoutId != null) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final authController = Get.find<AuthController>();
        final token = authController.getToken();
        
        if (token == null) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Vui lòng đăng nhập để xem thông tin đơn hàng';
          });
          return;
        }

        Map<String, dynamic>? result;
        
        if (widget.orderId != null) {
          // Thử lấy order trước
          result = await OrderService.getOrderById(token, widget.orderId!);
          
          if (result?['success'] == true) {
            setState(() {
              _orderData = result!['data'];
              _isLoading = false;
            });
            return;
          }
        }
        
        // Nếu không có orderId hoặc không tìm thấy order, thử lấy checkout
        if (widget.checkoutId != null) {
          result = await OrderService.getCheckoutById(token, widget.checkoutId!);
          
          if (result?['success'] == true) {
            setState(() {
              _orderData = result!['data'];
              _isLoading = false;
            });
            return;
          }
        }

        // Nếu cả hai đều thất bại
        setState(() {
          _isLoading = false;
          _errorMessage = result?['data']?['message'] ?? 'Không thể tải thông tin đơn hàng';
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Lỗi kết nối: $e';
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _checkmarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Đang tải thông tin đơn hàng...'),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          title: const Text('Lỗi'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.back(),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red[400],
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadOrderData,
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Header với animation
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.green[400]!,
                    Colors.green[600]!,
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    children: [
                      // Icon thành công với animation
                      ScaleTransition(
                        scale: Tween<double>(
                          begin: 0.0,
                          end: 1.0,
                        ).animate(CurvedAnimation(
                          parent: _checkmarkController,
                          curve: Curves.elasticOut,
                        )),
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Đặt hàng thành công!',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isPaymentSuccess 
                            ? 'Thanh toán đã hoàn tất'
                            : 'Đơn hàng đã được tạo',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Nội dung chính
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Thông tin đơn hàng
                      _buildOrderInfoCard(),
                      const SizedBox(height: 20),

                      // Thông tin giao hàng
                      _buildShippingInfoCard(),
                      const SizedBox(height: 20),

                      // Danh sách sản phẩm
                      _buildOrderItemsCard(),
                      const SizedBox(height: 20),

                      // Thông tin thanh toán
                      _buildPaymentInfoCard(),
                      const SizedBox(height: 30),

                      // Nút hành động
                      _buildActionButtons(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.receipt_long,
                  color: Colors.blue[600],
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Thông tin đơn hàng',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Mã đơn hàng', orderCode, isHighlighted: true),
          _buildInfoRow('Ngày đặt', _getCurrentDate()),
          _buildInfoRow('Trạng thái', 'Đã xác nhận', statusColor: Colors.green),
        ],
      ),
    );
  }

  Widget _buildShippingInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.location_on,
                  color: Colors.green[600],
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Địa chỉ giao hàng',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Người nhận', shippingAddress['receiver'] ?? ''),
          _buildInfoRow('Số điện thoại', shippingAddress['phone'] ?? ''),
          _buildInfoRow('Địa chỉ', shippingAddress['address'] ?? ''),
          _buildInfoRow('Quận/Huyện', shippingAddress['district'] ?? ''),
          _buildInfoRow('Thành phố', shippingAddress['city'] ?? ''),
        ],
      ),
    );
  }

  Widget _buildOrderItemsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.shopping_bag,
                  color: Colors.orange[600],
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Sản phẩm đã đặt',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...orderItems.map((item) => _buildOrderItem(item)).toList(),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tổng tiền:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
                              Text(
                  '${totalAmount.toStringAsFixed(0)} đ',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[600],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.payment,
                  color: Colors.purple[600],
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Thông tin thanh toán',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Phương thức', paymentMethod),
          _buildInfoRow('Trạng thái', 
            isPaymentSuccess ? 'Đã thanh toán' : 'Chờ thanh toán',
            statusColor: isPaymentSuccess ? Colors.green : Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          if (item['image'] != null && item['image'] != '')
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                item['image'],
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.image, color: Colors.grey),
                  );
                },
              ),
            )
          else
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.image, color: Colors.grey),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'] ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Số lượng: ${item['quantity'] ?? 1}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${_formatPrice(item['price'])} đ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isHighlighted = false, Color? statusColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
                color: statusColor ?? (isHighlighted ? Colors.blue[600] : Colors.black87),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              // Chuyển đến trang đơn hàng của tôi
              Get.to(() => MyOrderScreen());
            },
            icon: const Icon(Icons.list_alt),
            label: const Text(
              'Xem đơn hàng của tôi',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              // Quay về trang chủ và chuyển đến tab Account
              final navigationController = Get.find<NavigationController>();
              navigationController.changeIndex(3); // Index 3 là tab Account
              Get.offAll(() => const MainScreen());
            },
            icon: const Icon(Icons.home),
            label: const Text(
              'Về trang chủ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey[700],
              side: BorderSide(color: Colors.grey[400]!),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
  }

  String _formatPrice(dynamic price) {
    if (price == null) return '0';
    
    // Nếu là String, chuyển thành số
    if (price is String) {
      try {
        final numValue = double.parse(price);
        return numValue.toStringAsFixed(0);
      } catch (e) {
        return '0';
      }
    }
    
    // Nếu là số
    if (price is num) {
      return price.toStringAsFixed(0);
    }
    
    return '0';
  }
} 