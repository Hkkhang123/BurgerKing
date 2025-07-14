import 'package:client/shared/themes/app_textstyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:client/core/services/order_service.dart';
import 'package:client/core/services/auth_controller.dart';

class MyOrderScreen extends StatefulWidget {
  const MyOrderScreen({super.key});

  @override
  State<MyOrderScreen> createState() => _MyOrderScreenState();
}

class _MyOrderScreenState extends State<MyOrderScreen> {
  List<dynamic> processingOrders = [];
  List<dynamic> completedOrders = [];
  List<dynamic> cancelledOrders = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final authController = Get.find<AuthController>();
      final token = authController.getToken();
      
      if (token == null) {
        setState(() {
          isLoading = false;
          errorMessage = 'Vui lòng đăng nhập để xem đơn hàng';
        });
        return;
      }

      // Lấy tất cả đơn hàng
      final result = await OrderService.getMyOrders(token);
      
      if (result['success']) {
        final allOrders = result['data'] as List<dynamic>;
        
        // Phân loại đơn hàng theo trạng thái
        setState(() {
          processingOrders = allOrders.where((order) {
            final status = order['status']?.toString().toLowerCase() ?? '';
            return status.contains('xử lý') || status.contains('chờ') || status.contains('processing');
          }).toList();
          
          completedOrders = allOrders.where((order) {
            final status = order['status']?.toString().toLowerCase() ?? '';
            return status.contains('hoàn thành') || status.contains('completed') || status.contains('delivered');
          }).toList();
          
          cancelledOrders = allOrders.where((order) {
            final status = order['status']?.toString().toLowerCase() ?? '';
            return status.contains('hủy') || status.contains('cancelled') || status.contains('canceled');
          }).toList();
          
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = result['data']?['message'] ?? 'Không thể tải đơn hàng';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Lỗi kết nối: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark; 
    return DefaultTabController(length: 3, child: Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: () => Get.back(), icon: Icon(
          Icons.arrow_back_ios,
          color: isDark ? Colors.white : Colors.black
        )),
        title: Text(
          'Đơn hàng của tôi',
          style: AppTextStyle.withColor(
            AppTextStyle.h3,
            isDark ? Colors.white : Colors.black
          ),
        ),

        bottom: TabBar(
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: isDark ? Colors.grey[400] : Colors.grey[600],
          indicatorColor: Theme.of(context).primaryColor,
          tabs: const [
            Tab(text: 'Đang xử lý'),
            Tab(text: 'Đã hoàn thành'),
            Tab(text: 'Đã hủy'),
          ],
        )
      ),
             body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? _buildErrorWidget()
              : TabBarView(children: [
                  _buildOrderList(processingOrders, 'Đang xử lý'),
                  _buildOrderList(completedOrders, 'Đã hoàn thành'),
                  _buildOrderList(cancelledOrders, 'Đã hủy'),
                ]),
    ));
  }

   Widget _buildErrorWidget() {
    return Center(
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
            errorMessage!,
            style: AppTextStyle.withColor(
              AppTextStyle.h2,
              Theme.of(context).textTheme.bodyLarge!.color!,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadOrders,
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderList(List<dynamic> orders, String status) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Chưa có đơn hàng $status',
              style: AppTextStyle.withColor(
                AppTextStyle.h2,
                Theme.of(context).textTheme.bodyLarge!.color!,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Các đơn hàng $status sẽ hiển thị ở đây.',
              style: AppTextStyle.withColor(
                AppTextStyle.bodyMedium,
                Colors.grey[600]!,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOrders,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return _buildOrderCard(order);
        },
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final orderCode = order['orderCode'] ?? 'N/A';
    final totalPrice = order['totalPrice']?.toString() ?? '0';
    final status = order['status'] ?? 'Không xác định';
    final createdAt = order['createdAt'] != null 
        ? DateTime.parse(order['createdAt']).toString().substring(0, 16)
        : 'N/A';
    final orderItems = order['orderItems'] as List<dynamic>? ?? [];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Mã: $orderCode',
                  style: AppTextStyle.withColor(
                    AppTextStyle.h3,
                    Theme.of(context).primaryColor,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Ngày tạo: $createdAt',
              style: AppTextStyle.withColor(
                AppTextStyle.bodySmall,
                Colors.grey[600]!,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tổng tiền: ${totalPrice} đ',
              style: AppTextStyle.withColor(
                AppTextStyle.h3,
                Theme.of(context).textTheme.bodyLarge!.color!,
              ),
            ),
            if (orderItems.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Sản phẩm:',
                style: AppTextStyle.withColor(
                  AppTextStyle.bodyMedium,
                  Theme.of(context).textTheme.bodyLarge!.color!,
                ),
              ),
              const SizedBox(height: 4),
              ...orderItems.take(3).map((item) => Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 2),
                child: Text(
                  '• ${item['name'] ?? 'N/A'} (x${item['quantity'] ?? 1})',
                  style: AppTextStyle.withColor(
                    AppTextStyle.bodySmall,
                    Colors.grey[600]!,
                  ),
                ),
              )),
              if (orderItems.length > 3)
                Padding(
                  padding: const EdgeInsets.only(left: 8, top: 4),
                  child: Text(
                    '... và ${orderItems.length - 3} sản phẩm khác',
                    style: AppTextStyle.withColor(
                      AppTextStyle.bodySmall,
                      Colors.grey[500]!,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    final statusLower = status.toLowerCase();
    if (statusLower.contains('xử lý') || statusLower.contains('chờ') || statusLower.contains('processing')) {
      return Colors.orange;
    } else if (statusLower.contains('hoàn thành') || statusLower.contains('completed') || statusLower.contains('delivered')) {
      return Colors.green;
    } else if (statusLower.contains('hủy') || statusLower.contains('cancelled') || statusLower.contains('canceled')) {
      return Colors.red;
    }
    return Colors.grey;
  }
}