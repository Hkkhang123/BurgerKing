import 'package:client/utils/app_textstyle.dart';
import 'package:client/utils/api_service.dart';
import 'package:client/view/signin_screen.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:client/controller/auth_controller.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<dynamic> cartProducts = [];
  double totalPrice = 0;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    final authController = Get.find<AuthController>();
    final token = authController.getToken();
    String? guestId;
    if (token == null) {
      final storage = GetStorage();
      guestId = storage.read('guestId');
      if (guestId == null) {
        guestId = 'guest_${DateTime.now().millisecondsSinceEpoch}';
        storage.write('guestId', guestId);
      }
    }
    if (token == null && guestId == null) {
      print('Không có token và guestId, không thể load giỏ hàng');
      setState(() {
        error = 'Bạn cần đăng nhập để xem giỏ hàng';
        isLoading = false;
      });
      return;
    }
    final result = await ApiService.getCart(
      token,
      guestId: token == null ? guestId : null,
    );

    if (result['success']) {
      final data = result['data'];
      setState(() {
        cartProducts = (data['products'] ?? []) as List<dynamic>;
        totalPrice = (data['totalPrice'] ?? 0).toDouble();
        isLoading = false;
        error = null;
      });
    } else {
      String errorMessage =
          (result['data'] != null && result['data']['message'] != null)
              ? result['data']['message']
              : (result['error'] ?? 'Lỗi khi tải giỏ hàng');

      setState(() {
        error = errorMessage;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Icons.arrow_back_ios,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        title: Text(
          'Giỏ hàng',
          style: AppTextStyle.withColor(
            AppTextStyle.h3,
            isDark ? Colors.white : Colors.black,
          ),
        ),
      ),
      body: Builder(
        builder: (context) {
          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (error != null) {
            return Center(
              child: Text(error!, style: TextStyle(color: Colors.red)),
            );
          }
          if (cartProducts.isEmpty) {
            return const Center(child: Text('Giỏ hàng của bạn đang trống'));
          }
          // Có sản phẩm
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cartProducts.length,
                  itemBuilder:
                      (context, index) =>
                          _buildCartItem(context, cartProducts[index]),
                ),
              ),
              _buildCartSummary(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, dynamic product) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:
                isDark
                    ? Colors.black.withAlpha(200)
                    : Colors.grey.withAlpha(100),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(16),
            ),
            child:
                product['image'] != null
                    ? Image.network(
                      product['image'],
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    )
                    : Container(
                      width: 100,
                      height: 100,
                      color: Colors.grey[300],
                    ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          product['name'] ?? '',
                          style: AppTextStyle.withColor(
                            AppTextStyle.bodyLarge,
                            Theme.of(context).textTheme.bodyLarge!.color!,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        onPressed:
                            () =>
                                _showDeleteConfirmationDialog(context, product),
                        icon: Icon(
                          Icons.delete_outline,
                          color: Colors.red[400],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${product['price']} đ',
                        style: AppTextStyle.withColor(
                          AppTextStyle.h3,
                          Theme.of(context).primaryColor,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed:
                                  () => _changeProductQuantity(product, -1),
                              icon: Icon(
                                Icons.remove,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            Text(
                              '${product['quantity']}',
                              style: AppTextStyle.bodyLarge,
                            ),
                            IconButton(
                              onPressed:
                                  () => _changeProductQuantity(product, 1),
                              icon: Icon(
                                Icons.add,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, dynamic product) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Get.dialog(
      AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[400]!.withValues(alpha: 100),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.delete_outline,
                color: Colors.red[400],
                size: 32,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Xóa khỏi giỏ hàng',
              style: AppTextStyle.withColor(
                AppTextStyle.h3,
                Theme.of(context).textTheme.bodyLarge!.color!,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Bạn có chắc là muốn xóa khỏi giỏ hàng?',
              style: AppTextStyle.withColor(
                AppTextStyle.bodyMedium,
                isDark ? Colors.grey[400]! : Colors.grey[600]!,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(
                        color: isDark ? Colors.white70 : Colors.black12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Hủy',
                      style: AppTextStyle.withColor(
                        AppTextStyle.bodyMedium,
                        Theme.of(context).textTheme.bodyLarge!.color!,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Get.back();
                      await _deleteProductFromCart(product);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(
                        color: isDark ? Colors.white70 : Colors.black12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Xóa',
                      style: AppTextStyle.withColor(
                        AppTextStyle.bodyMedium,
                        Theme.of(context).textTheme.bodyLarge!.color!,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      barrierColor: Colors.black54,
    );
  }

  Future<void> _deleteProductFromCart(dynamic product) async {
    setState(() {
      isLoading = true;
    });
    final authController = Get.find<AuthController>();
    final token = authController.getToken();
    String? guestId;
    if (token == null) {
      final storage = GetStorage();
      guestId = storage.read('guestId');
    }
    final result = await ApiService.deleteFromCart(
      token,
      product['productId'] ?? product['_id'],
      guestId: token == null ? guestId : null,
    );
    print('Delete from cart result: $result');
    if (result['success'] == true || result['statusCode'] == 200) {
      await _loadCart();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xóa sản phẩm khỏi giỏ hàng!')),
      );
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['error'] ?? 'Lỗi khi xóa sản phẩm')),
      );
    }
  }

  Future<void> _changeProductQuantity(dynamic product, int delta) async {
    int oldQuantity = product['quantity'] ?? 1;
    int newQuantity = oldQuantity + delta;
    if (newQuantity < 1) return;
    setState(() {
      product['quantity'] = newQuantity;
      // Cập nhật lại tổng tiền tạm thời trên UI
      totalPrice = cartProducts.fold(0, (sum, p) {
        final price =
            p['price'] is num
                ? p['price']
                : num.tryParse(p['price'].toString()) ?? 0;
        final quantity =
            p['quantity'] is num
                ? p['quantity']
                : num.tryParse(p['quantity'].toString()) ?? 0;
        return sum + price * quantity;
      });
    });
    final authController = Get.find<AuthController>();
    final token = authController.getToken();
    String? guestId;
    if (token == null) {
      final storage = GetStorage();
      guestId = storage.read('guestId');
    }
    final result = await ApiService.updateCart(
      token,
      product['productId'] ?? product['_id'],
      newQuantity,
      guestId: token == null ? guestId : null,
    );
    print('Update cart result: $result');
    if (result['success'] == true || result['statusCode'] == 200) {
      // Không cần reload lại toàn bộ cart, đã cập nhật UI rồi
    } else {
      // Rollback số lượng nếu lỗi
      setState(() {
        product['quantity'] = oldQuantity;
        totalPrice = cartProducts.fold(0, (sum, p) {
          final price =
              p['price'] is num
                  ? p['price']
                  : num.tryParse(p['price'].toString()) ?? 0;
          final quantity =
              p['quantity'] is num
                  ? p['quantity']
                  : num.tryParse(p['quantity'].toString()) ?? 0;
          return sum + price * quantity;
        });
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['error'] ?? 'Lỗi khi cập nhật số lượng')),
      );
    }
  }

  Widget _buildCartSummary(BuildContext context) {
    int totalQuantity = 0;
    for (var p in cartProducts) {
      totalQuantity += (p['quantity'] ?? 0) as int;
    }
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(50),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tổng số lượng: $totalQuantity',
                style: AppTextStyle.withColor(
                  AppTextStyle.bodyMedium,
                  Theme.of(context).textTheme.bodyLarge!.color!,
                ),
              ),
              Text(
                '${totalPrice.toStringAsFixed(0)} đ',
                style: AppTextStyle.withColor(
                  AppTextStyle.h2,
                  Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _handleCheckout(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Thanh toán',
                style: AppTextStyle.withColor(
                  AppTextStyle.buttonMedium,
                  Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleCheckout(BuildContext context) {
    final authController = Get.find<AuthController>();
    final token = authController.getToken();
    if (token == null) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Bạn chưa đăng nhập'),
              content: const Text('Vui lòng đăng nhập để tiếp tục thanh toán.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Get.to(() => SigninScreen());
                  },
                  child: const Text('Đăng nhập'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Hủy'),
                ),
              ],
            ),
      );
    } else {
      // TODO: Thực hiện logic thanh toán khi đã đăng nhập
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chức năng thanh toán đang phát triển!')),
      );
    }
  }
}
