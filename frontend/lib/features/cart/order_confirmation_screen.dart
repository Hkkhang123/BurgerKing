import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:client/features/order/my_order_screen.dart';
import 'package:client/features/home/main_screen.dart';
import 'package:client/core/services/navigation_controller.dart';
import 'package:client/core/services/order_service.dart';
import 'package:client/core/services/auth_controller.dart';
import 'package:intl/intl.dart';

class OrderConfirmationScreen extends StatefulWidget {
  final String? orderId;
  final String? checkoutId;
  final String? orderCode;
  final double? totalAmount;
  final String? paymentMethod;
  final Map<String, dynamic>? shippingAddress;
  final List<dynamic>? orderItems;
  final bool? isPaymentSuccess;
  final Map<String, dynamic>? cartData;
  final int? shippingFee;
  final double? totalPrice;
  final double? finalPrice;
  final String? phone;
  // Constructor cho dữ liệu có sẵn (từ checkout)
  const OrderConfirmationScreen({
    super.key,
    this.orderId,
    this.checkoutId,
    this.orderCode,
    this.totalAmount,
    this.paymentMethod,
    this.shippingAddress,
    this.orderItems,
    this.cartData,
    this.shippingFee,
    this.totalPrice,
    this.finalPrice,
    this.isPaymentSuccess = true,
    this.phone,
  });

  // Constructor factory để load từ database
  factory OrderConfirmationScreen.fromOrderId(String orderId) {
    return OrderConfirmationScreen(orderId: orderId);
  }

  factory OrderConfirmationScreen.fromCheckoutId(String checkoutId) {
    return OrderConfirmationScreen(checkoutId: checkoutId);
  }

  @override
  State<OrderConfirmationScreen> createState() =>
      _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _checkmarkController;

  final currencyFormatter = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: 'đ',
    decimalDigits: 0,
  );

  // Dùng để format tổng tiền:

  // Dữ liệu từ database
  Map<String, dynamic>? _orderData;
  bool _isLoading = true;
  String? _errorMessage;

  // Dữ liệu hiển thị
  String get orderId => _orderData?['_id'] ?? widget.orderId ?? '';
  String get orderCode => _orderData?['orderCode'] ?? widget.orderCode ?? '';
  double get totalAmount =>
      _orderData?['totalPrice']?.toDouble() ?? widget.totalAmount ?? 0.0;
  String get paymentMethod =>
      _orderData?['paymentMethod'] ?? widget.paymentMethod ?? '';
  Map<String, dynamic> get shippingAddress =>
      _orderData?['shippingAddress'] ?? widget.shippingAddress ?? {};
  List<dynamic> get orderItems =>
      _orderData?['orderItems'] ?? widget.orderItems ?? [];
  bool get isPaymentSuccess =>
      _orderData?['isPaid'] ?? widget.isPaymentSuccess ?? false;

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

          if (result['success'] == true) {
            setState(() {
              _orderData = result!['data'];
              _isLoading = false;
            });
            return;
          }
        }

        // Nếu không có orderId hoặc không tìm thấy order, thử lấy checkout
        if (widget.checkoutId != null) {
          result = await OrderService.getCheckoutById(
            token,
            widget.checkoutId!,
          );

          if (result['success'] == true) {
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
          _errorMessage =
              result?['data']?['message'] ?? 'Không thể tải thông tin đơn hàng';
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
              Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
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
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
          child: Column(
            children: [
              // Box chính chiếm toàn chiều ngang
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(
                    0,
                  ), // hoặc giữ radius nếu thích bo góc
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Check icon
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Thanh toán đã hoàn tất',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Cảm ơn đã thanh toán',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),

              // Các phần dưới cũng chiếm full width
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  children: [
                    _buildOrderInfoCard(), // nên có width: double.infinity
                    const SizedBox(height: 16),
                    _buildShippingInfoCard(context),
                    const SizedBox(height: 16),
                    _buildOrderItemsCard(context),
                    const SizedBox(height: 16),
                    _buildPaymentInfoCard(context),
                    const SizedBox(height: 24),
                    _buildActionButtons(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Nội dung chính có thể scroll
  }

  Widget _buildOrderInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông tin đơn hàng',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildFlexibleInfoRow('Mã đơn hàng', orderCode),
          _buildFlexibleInfoRow('Ngày đặt', _getCurrentDate()),
        ],
      ),
    );
  }

  Widget _buildShippingInfoCard(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final data = widget.cartData ?? widget.shippingAddress ?? {};

    return Container(
      width: screenWidth,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông tin giao hàng',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 0, 0, 0),
            ),
          ),
          const SizedBox(height: 12),
          if (data['receiver'] != null)
            _buildFlexibleInfoRow('Người nhận', data['receiver']),
          _buildFlexibleInfoRow(
            'Số điện thoại',
            data['phone'] ?? 'Chưa có số điện thoại',
          ),
          _buildFlexibleInfoRow('Địa chỉ', data['address'] ?? ''),
        ],
      ),
    );
  }

  Widget _buildFlexibleInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 0, 45, 113),
              ),
              softWrap: true,
              maxLines: 3, // tự động xuống dòng, tối đa 3 dòng
              overflow: TextOverflow.ellipsis, // Thêm "..." nếu text quá dài
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItemsCard(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sản phẩm đã đặt',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 0, 0, 0),
            ),
          ),
          const SizedBox(height: 12),

          // Danh sách sản phẩm
          ...orderItems.map((item) => _buildOrderItem(item)),

          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tổng tiền:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                currencyFormatter.format(totalAmount), // ✅ Đúng,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 0, 45, 113),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInfoCard(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông tin thanh toán',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 0, 0, 0), // tím đậm
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Phương thức', paymentMethod),
          _buildInfoRow(
            'Trạng thái',
            isPaymentSuccess ? 'Đã thanh toán' : 'Chờ thanh toán',
            statusColor:
                isPaymentSuccess
                    ? Color.fromARGB(255, 0, 45, 113)
                    : Colors.orange,
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
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            currencyFormatter.format(item['price']),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Color.fromARGB(255, 0, 45, 113),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? statusColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color.fromARGB(255, 0, 0, 0), // label cũng xanh dương đậm
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color:
                  statusColor ??
                  Color.fromARGB(
                    255,
                    0,
                    45,
                    113,
                  ), // value cũng xanh dương trừ khi có màu riêng
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
              backgroundColor: Color.fromRGBO(255, 124, 31, 1),
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
