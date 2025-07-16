import 'package:client/core/services/auth_controller.dart';
import 'package:client/shared/themes/app_textstyle.dart';
import 'package:client/features/auth/signin_screen.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:client/core/services/cart_controller.dart';
import 'package:client/features/cart/checkout_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final currencyFormat = NumberFormat("#,##0", "vi_VN");
  List<dynamic> cartProducts = [];
  double totalPrice = 0;
  bool isLoading = true;
  String? error;
  bool promoCodeMode = false;
  final promoController = TextEditingController();
  String? promoCodeUsed;
  double? discountPercent;
  String baseUrl = 'http://10.0.2.2:5000';
  String? discountType;
  int? discountFixed;

  // Helper function để lấy productId an toàn
  String? _getProductId(dynamic product) {
    if (product == null) return null;

    // Thử nhiều cách để lấy productId
    dynamic rawProductId = product['productId'];
    if (rawProductId != null) {
      return rawProductId.toString();
    }

    // Thử các trường khác
    rawProductId = product['_id'];
    if (rawProductId != null) {
      return rawProductId.toString();
    }

    rawProductId = product['id'];
    if (rawProductId != null) {
      return rawProductId.toString();
    }

    return null;
  }

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    if (!mounted) return;

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
      if (mounted) {
        setState(() {
          error = 'Bạn cần đăng nhập để xem giỏ hàng';
          isLoading = false;
        });
      }
      return;
    }
    final cartController = Get.find<CartController>();
    final result = await cartController.getCart(
      token,
      guestId: token == null ? guestId : null,
    );

    if (!mounted) return;

    if (result['success']) {
      final data = result['data'];
      setState(() {
        cartProducts = (data['products'] ?? []) as List<dynamic>;
        totalPrice =
            data['totalPrice'] is num
                ? data['totalPrice'].toDouble()
                : double.tryParse(data['totalPrice'].toString()) ?? 0.0;
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
    if (!mounted) return;

    final productId = _getProductId(product);

    if (productId == null || productId.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không tìm thấy ID sản phẩm để xóa!')),
        );
      }
      return;
    }
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
    final cartController = Get.find<CartController>();
    final result = await cartController.deleteFromCart(
      token,
      productId!,
      guestId: token == null ? guestId : null,
    );

    if (!mounted) return;

    if (result['success'] == true || result['statusCode'] == 200) {
      await _loadCart();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa sản phẩm khỏi giỏ hàng!')),
        );
      }
    } else {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['error'] ?? 'Lỗi khi xóa sản phẩm')),
        );
      }
    }
  }

  Future<void> _changeProductQuantity(dynamic product, int delta) async {
    if (!mounted) return;

    int oldQuantity = product['quantity'] ?? 1;
    int newQuantity = oldQuantity + delta;
    if (newQuantity < 1) return;
    setState(() {
      product['quantity'] = newQuantity;
      // Cập nhật lại tổng tiền tạm thời trên UI
      totalPrice = cartProducts.fold(0.0, (sum, p) {
        final price =
            p['price'] is num
                ? p['price'].toDouble()
                : double.tryParse(p['price'].toString()) ?? 0.0;
        final quantity =
            p['quantity'] is num
                ? p['quantity'].toInt()
                : int.tryParse(p['quantity'].toString()) ?? 0;
        return sum + (price * quantity);
      });
    });
    final authController = Get.find<AuthController>();
    final token = authController.getToken();
    String? guestId;
    if (token == null) {
      final storage = GetStorage();
      guestId = storage.read('guestId');
    }
    // Lấy productId an toàn
    final productId = _getProductId(product) ?? '';

    final cartController = Get.find<CartController>();
    final result = await cartController.updateCart(
      token,
      productId,
      newQuantity,
      guestId: token == null ? guestId : null,
    );

    if (!mounted) return;

    if (result['success'] == true || result['statusCode'] == 200) {
      // Không cần reload lại toàn bộ cart, đã cập nhật UI rồi
    } else {
      // Rollback số lượng nếu lỗi
      setState(() {
        product['quantity'] = oldQuantity;
        totalPrice = cartProducts.fold(0.0, (sum, p) {
          final price =
              p['price'] is num
                  ? p['price'].toDouble()
                  : double.tryParse(p['price'].toString()) ?? 0.0;
          final quantity =
              p['quantity'] is num
                  ? p['quantity'].toInt()
                  : int.tryParse(p['quantity'].toString()) ?? 0;
          return sum + (price * quantity);
        });
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Lỗi khi cập nhật số lượng'),
          ),
        );
      }
    }
  }

  Widget _buildCartSummary(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    int totalQuantity = 0;
    double rawTotal = 0;

    for (var p in cartProducts) {
      final quantity = num.tryParse(p['quantity'].toString())?.toInt() ?? 0;
      final price = num.tryParse(p['price'].toString())?.toInt() ?? 0;
      totalQuantity += quantity;
      rawTotal += price * quantity;
    }

    final double discount =
        (discountType == 'percent' && discountPercent != null)
            ? (discountPercent! / 100) * rawTotal
            : (discountFixed ?? 0).toDouble();

    final double totalPrice = rawTotal - discount;

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.06),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(screenWidth * 0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(50),
            blurRadius: screenWidth * 0.025,
            offset: Offset(0, -screenHeight * 0.005),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPromoCodeWidget(totalPrice),
          if (discount > 0)
            Padding(
              padding: EdgeInsets.only(
                top: screenHeight * 0.005,
                bottom: screenHeight * 0.01,
              ),
              child: Text(
                'Bạn đã tiết kiệm: ${currencyFormat.format(discount)} đ',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: screenWidth * 0.038,
                ),
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tổng số lượng: $totalQuantity',
                style: AppTextStyle.bodyMedium.copyWith(
                  fontSize: screenWidth * 0.038,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (discount > 0)
                    Text(
                      '${currencyFormat.format(rawTotal)} đ',
                      style: AppTextStyle.bodyMedium.copyWith(
                        fontSize: screenWidth * 0.035,
                        decoration: TextDecoration.lineThrough,
                        color: Colors.grey,
                      ),
                    ),
                  Text(
                    '${currencyFormat.format(totalPrice)} đ',
                    style: AppTextStyle.h2.copyWith(
                      fontSize: screenWidth * 0.05,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.02),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _handleCheckout(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding: EdgeInsets.symmetric(vertical: screenHeight * 0.018),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(screenWidth * 0.03),
                ),
              ),
              child: Text(
                'Thanh toán',
                style: AppTextStyle.buttonMedium.copyWith(
                  fontSize: screenWidth * 0.045,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleCheckout(BuildContext context) async {
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
      // Log dữ liệu giỏ hàng và tổng tiền trước khi chuyển sang màn hình Checkout
      print('Checkout pressed! cartProducts: ' + cartProducts.toString());
      print('Checkout pressed! totalPrice: ' + totalPrice.toString());
      // Chuyển sang màn hình Checkout
      final result = await Navigator.of(context).push(
        MaterialPageRoute(
          builder:
              (_) => CheckoutScreen(
                cartProducts: cartProducts,
                totalPrice: totalPrice,
                promoCode: promoCodeUsed,
                discountType: discountType,
                discountValue: discountPercent ?? discountFixed,
              ),
        ),
      );
      // Nếu đặt hàng thành công, reload lại giỏ hàng
      if (result == true) {
        _loadCart();
      }
    }
  }

  Widget _buildPromoCodeWidget(double totalPrice) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (promoCodeMode) {
      return Row(
        children: [
          Expanded(
            child: TextField(
              controller: promoController,
              decoration: const InputDecoration(
                hintText: 'Nhập mã giảm giá',
                border: OutlineInputBorder(),
              ),
              style: TextStyle(fontSize: screenWidth * 0.038),
            ),
          ),
          SizedBox(width: screenWidth * 0.02),
          ElevatedButton(
            onPressed: () async {
              final code = promoController.text.trim();
              if (code.isEmpty) return;
              try {
                final total = totalPrice.toInt();
                final response = await http.get(
                  Uri.parse('$baseUrl/api/coupons/$code?total=$total'),
                );
                final data = jsonDecode(response.body);

                if (!context.mounted) return;

                if (response.statusCode == 200) {
                  setState(() {
                    promoCodeUsed = data['code'];
                    discountType = data['discountType'];

                    if (discountType == 'percent') {
                      discountPercent = (data['value'] as num).toDouble();
                      discountFixed = null;
                    } else if (discountType == 'fixed') {
                      discountFixed = (data['value'] as num).toInt();
                      discountPercent = null;
                    }

                    promoCodeMode = false;
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('✅ Mã ${data['code']} đã áp dụng')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('❌ ${data['message']}')),
                  );
                }
              } catch (_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('❌ Lỗi kết nối server')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04,
                vertical: screenWidth * 0.02,
              ),
            ),
            child: Text(
              'Áp dụng',
              style: TextStyle(fontSize: screenWidth * 0.036),
            ),
          ),
        ],
      );
    } else if (promoCodeUsed != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              'Mã: $promoCodeUsed ${discountPercent != null ? '(-$discountPercent%)' : ''}',
              style: TextStyle(
                color: Colors.green,
                fontSize: screenWidth * 0.038,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                promoCodeMode = true;
                promoController.text = promoCodeUsed!;
              });
            },
            child: Text(
              'Thay đổi',
              style: TextStyle(fontSize: screenWidth * 0.036),
            ),
          ),
        ],
      );
    } else {
      return GestureDetector(
        onTap: () => setState(() => promoCodeMode = true),
        child: Row(
          children: [
            Icon(
              Icons.radio_button_off,
              color: Colors.orange,
              size: screenWidth * 0.045,
            ),
            SizedBox(width: screenWidth * 0.015),
            Text(
              'Áp dụng mã giảm giá',
              style: TextStyle(fontSize: screenWidth * 0.038),
            ),
          ],
        ),
      );
    }
  }
}
