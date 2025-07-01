import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:client/controller/auth_controller.dart';
import 'package:client/view/widget/product_card.dart';
import 'package:client/view/widget/product_detail.dart';
import 'package:client/utils/app_textstyle.dart';
import 'package:client/utils/api_service.dart';

class BestSellerProductList extends StatefulWidget {
  const BestSellerProductList({Key? key}) : super(key: key);

  @override
  State<BestSellerProductList> createState() => _BestSellerProductListState();
}

class _BestSellerProductListState extends State<BestSellerProductList> {
  late AuthController authController;
  List<String> userFavorites = [];
  String? userToken;
  bool _isLoadingFavorites = false;
  List<dynamic> bestSellerProducts = [];
  bool _isLoadingProducts = false;

  @override
  void initState() {
    super.initState();
    authController = Get.find<AuthController>();
    _loadUserData();
    _loadBestSellerProducts();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoadingFavorites = true;
    });

    final user = authController.getCurrentUser();
    userToken = authController.getToken();
    
    // Set default avatar if needed
    await authController.setDefaultAvatar();
    
    // Load favorites từ server thay vì local storage
    if (userToken != null) {
      try {
        final favorites = await authController.fetchAndUpdateProfile();
        setState(() {
          userFavorites = favorites;
          _isLoadingFavorites = false;
        });
      } catch (e) {
        // Fallback to local storage if server fails
        final localFavorites = user?['favorites'] as List<dynamic>?;
        setState(() {
          userFavorites = localFavorites?.map((e) => e.toString()).toList() ?? [];
          _isLoadingFavorites = false;
        });
      }
    } else {
      final localFavorites = user?['favorites'] as List<dynamic>?;
      setState(() {
        userFavorites = localFavorites?.map((e) => e.toString()).toList() ?? [];
        _isLoadingFavorites = false;
      });
    }
  }

  Future<void> _loadBestSellerProducts() async {
    setState(() {
      _isLoadingProducts = true;
    });

    try {
      final products = await ApiService.fetchBestSellerProducts();
      setState(() {
        bestSellerProducts = products;
        _isLoadingProducts = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingProducts = false;
      });
    }
  }

  Future<void> _handleFavoriteToggle(String productId, bool isFavorite) async {
    // Optimistic update: cập nhật UI ngay
    setState(() {
      if (isFavorite) {
        if (!userFavorites.contains(productId)) {
          userFavorites.add(productId);
        }
      } else {
        userFavorites.remove(productId);
      }
    });

    // Gọi API, nếu lỗi thì revert lại
    final result = await ApiService.toggleFavoriteProduct(userToken!, productId);
    if (!result['success']) {
      setState(() {
        if (isFavorite) {
          userFavorites.remove(productId);
        } else {
          if (!userFavorites.contains(productId)) {
            userFavorites.add(productId);
          }
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['error'] ?? 'Lỗi cập nhật yêu thích')),
      );
    } else {
      // Nếu thành công, cập nhật favorites từ response của server
      final serverFavorites = result['data']['favorites'] as List<dynamic>?;
      if (serverFavorites != null) {
        setState(() {
          userFavorites = serverFavorites.map((e) => e.toString()).toList();
        });
        
        // Hiển thị thông báo thành công
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isFavorite ? 'Đã thêm vào yêu thích' : 'Đã xóa khỏi yêu thích'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    }
  }

  // Method để refresh favorites từ server
  Future<void> refreshFavorites() async {
    if (userToken != null) {
      setState(() {
        _isLoadingFavorites = true;
      });
      
      try {
        final favorites = await authController.fetchAndUpdateProfile();
        setState(() {
          userFavorites = favorites;
          _isLoadingFavorites = false;
        });
      } catch (e) {
        setState(() {
          _isLoadingFavorites = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // Header với tiêu đề "Sản phẩm bán chạy"
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                Icons.trending_up,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Sản phẩm bán chạy',
                style: AppTextStyle.withColor(
                  AppTextStyle.withWeight(AppTextStyle.h2, FontWeight.bold),
                  Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
                ),
              ),
              const Spacer(),
              if (_isLoadingProducts)
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor,
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Products List
        Expanded(
          child: _isLoadingProducts
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : bestSellerProducts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.trending_down,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Không có sản phẩm bán chạy',
                            style: AppTextStyle.withColor(
                              AppTextStyle.bodyLarge,
                              Colors.grey[600]!,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Hãy thử lại sau',
                            style: AppTextStyle.withColor(
                              AppTextStyle.bodyMedium,
                              Colors.grey[500]!,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadBestSellerProducts,
                            child: const Text('Tải lại'),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.68,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: bestSellerProducts.length,
                      itemBuilder: (context, index) {
                        final product = bestSellerProducts[index];
                        return GestureDetector(
                          onTap: () {
                            Get.to(() => ProductDetail(
                              product: product,
                              userFavorites: userFavorites,
                            ));
                          },
                          child: ProductCard(
                            product: product,
                            userFavorites: userFavorites,
                            userToken: userToken,
                            onFavoriteToggle: _handleFavoriteToggle,
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
} 