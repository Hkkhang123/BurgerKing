import 'package:client/core/services/auth_controller.dart';
import 'package:client/shared/themes/app_textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:client/core/utils/api_service.dart';
import 'package:get_storage/get_storage.dart';
import 'package:client/core/services/product_controller.dart';
import 'package:client/core/services/cart_controller.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  List<dynamic> favoriteProducts = [];
  bool isLoading = true;
  String? guestId;

  @override
  void initState() {
    super.initState();
    final authController = Get.find<AuthController>();
    if (!authController.isLoggedIn) {
      // Không fetch favorites nếu chưa đăng nhập
      setState(() {
        isLoading = false;
      });
    } else {
      fetchFavorites();
    }
  }

  Future<void> fetchFavorites() async {
    final authController = Get.find<AuthController>();
    await authController.fetchAndUpdateProfile();
    final user = authController.getCurrentUser();
    final List<String> favoriteIds = (user?['favorites'] ?? [])
        .whereType<String>()
        .toList();

    if (favoriteIds.isEmpty) {
      setState(() {
        favoriteProducts = [];
        isLoading = false;
      });
      return;
    }

    // Gọi API lấy chi tiết sản phẩm
    final productController = Get.find<ProductController>();
    final products = await productController.getProductsByIds(favoriteIds);
    setState(() {
      favoriteProducts = products;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Yêu thích',
          style: AppTextStyle.withColor(
            AppTextStyle.h3,
            isDark ? Colors.white : Colors.black,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.search,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
            body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(),
    );
  }

  Widget _buildBody() {
    final authController = Get.find<AuthController>();
    if (!authController.isLoggedIn) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.favorite_border,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Bạn chưa đăng nhập',
                style: AppTextStyle.withColor(
                  AppTextStyle.h2,
                  Theme.of(context).textTheme.bodyLarge!.color!,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Vui lòng đăng nhập để xem danh sách sản phẩm yêu thích của bạn.',
                style: AppTextStyle.withColor(
                  AppTextStyle.bodyMedium,
                  Colors.grey[600]!,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Get.toNamed('/signin'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                child: Text(
                  'Đăng nhập ngay',
                  style: AppTextStyle.withColor(
                    AppTextStyle.buttonMedium,
                    Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (favoriteProducts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.favorite_border,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Chưa có sản phẩm yêu thích',
                style: AppTextStyle.withColor(
                  AppTextStyle.h2,
                  Theme.of(context).textTheme.bodyLarge!.color!,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Hãy thêm sản phẩm vào danh sách yêu thích để xem chúng ở đây.',
                style: AppTextStyle.withColor(
                  AppTextStyle.bodyMedium,
                  Colors.grey[600]!,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _buildSummarySection(context, favoriteProducts),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildFavoriteItem(
                context,
                product: favoriteProducts[index],
              ),
              childCount: favoriteProducts.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummarySection(
    BuildContext context,
    List<dynamic> favoriteProducts,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[100],
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${favoriteProducts.length} sản phẩm',
                  style: AppTextStyle.withColor(
                    AppTextStyle.h2,
                    Theme.of(context).textTheme.bodyLarge!.color!,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'trong danh sách',
                  style: AppTextStyle.withColor(
                    AppTextStyle.bodyMedium,
                    isDark ? Colors.grey[400]! : Colors.grey[600]!,
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: ElevatedButton(
              onPressed: () async {
                final authController = Get.find<AuthController>();
                final token = authController.getToken();
                if (token == null) {
                  Get.toNamed('/signin');
                  return;
                }
                bool allSuccess = true;
                final cartController = Get.find<CartController>();
                for (final product in favoriteProducts) {
                  final result = await cartController.addToCart(token, product['_id'], guestId: token == null ? guestId : null);
                  if (!result['success']) {
                    allSuccess = false;
                  }
                }
                if (allSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã thêm tất cả vào giỏ hàng!')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Có sản phẩm thêm vào giỏ hàng bị lỗi!')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              child: Text(
                'Thêm tất cả vào giỏ hàng',
                style: AppTextStyle.withColor(
                  AppTextStyle.buttonMedium.copyWith(fontSize: 12),
                  Colors.white,
                ),
                maxLines: 2,
                softWrap: true,
                //textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteItem(
    BuildContext context, {
    required Map<String, dynamic> product,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Lấy URL ảnh đầu tiên nếu image là mảng
    String? imageUrl;
    if (product['image'] is List && product['image'].isNotEmpty) {
      final firstImage = product['image'][0];
      if (firstImage is Map && firstImage['url'] != null) {
        imageUrl = firstImage['url'];
      }
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withAlpha(30)
                : Colors.grey.withAlpha(30),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(12),
            ),
            child: imageUrl != null
                ? Image.network(
                    imageUrl,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  )
                : Image.asset(
                    'assets/images/avatar.jpg', // fallback image
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'] ?? '',
                    style: AppTextStyle.withColor(
                      AppTextStyle.bodyLarge,
                      Theme.of(context).textTheme.bodyLarge!.color!,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product['category'] ?? '',
                    style: AppTextStyle.withColor(
                      AppTextStyle.bodySmall,
                      isDark ? Colors.grey[400]! : Colors.grey[600]!,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        product['price'] != null ? '${product['price']} đ' : '',
                        style: AppTextStyle.withColor(
                          AppTextStyle.h3,
                          Theme.of(context).textTheme.bodyLarge!.color!,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () async {
                              final authController = Get.find<AuthController>();
                              final token = authController.getToken();
                              if (token == null) {
                                Get.toNamed('/signin');
                                return;
                              }
                              final cartController = Get.find<CartController>();
                              final result = await cartController.addToCart(token, product['_id'], guestId: token == null ? guestId : null);
                              if (result['success']) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Đã thêm vào giỏ hàng!')),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(result['error'] ?? 'Lỗi khi thêm vào giỏ hàng')),
                                );
                              }
                            },
                            icon: Icon(
                              Icons.shopping_bag_outlined,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          IconButton(
                            onPressed: () async {
                              final authController = Get.find<AuthController>();
                              final token = authController.getToken();
                              if (token == null) {
                                Get.toNamed('/signin');
                                return;
                              }
                              final productController = Get.find<ProductController>();
                              final result = await productController.toggleFavoriteProduct(token, product['_id']);
                              if (result['success']) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Đã xóa khỏi yêu thích!')),
                                );
                                fetchFavorites();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(result['error'] ?? 'Lỗi khi xóa khỏi yêu thích')),
                                );
                              }
                            },
                            icon: Icon(
                              Icons.delete_outline,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ],
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
}
