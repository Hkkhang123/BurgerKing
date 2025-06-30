import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:client/controller/filter_controller.dart';
import 'package:client/controller/auth_controller.dart';
import 'package:client/view/widget/filter_bottom_sheet.dart';
import 'package:client/view/widget/product_card.dart';
import 'package:client/view/widget/product_detail.dart';
import 'package:client/utils/app_textstyle.dart';
import 'package:client/utils/api_service.dart';

class ShoppingScreen extends StatefulWidget {
  const ShoppingScreen({super.key});

  @override
  State<ShoppingScreen> createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends State<ShoppingScreen> {
  late AuthController authController;
  late FilterController filterController;
  List<String> userFavorites = [];
  String? userToken;
  bool _isLoadingFavorites = false;

  @override
  void initState() {
    super.initState();
    authController = Get.find<AuthController>();
    filterController = Get.put(FilterController());
    _loadUserData();
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Search and Filter Header
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Search Bar with onChanged
                  TextField(
                    style: AppTextStyle.withColor(
                      AppTextStyle.buttonMedium,
                      Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
                    ),
                    onChanged: (query) {
                      filterController.searchProducts(query);
                    },
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm món ăn...',
                      hintStyle: AppTextStyle.withColor(
                        AppTextStyle.buttonMedium,
                        isDark ? Colors.grey[400]! : Colors.grey[600]!,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                      filled: true,
                      fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark ? Colors.grey[400]! : Colors.grey[600]!,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Theme.of(context).primaryColor,
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Filter Summary and Filter Button
                  Row(
                    children: [
                      Expanded(
                        child: Obx(() => Text(
                          filterController.getFilterSummary(),
                          style: AppTextStyle.withColor(
                            AppTextStyle.bodyMedium,
                            (isDark ? Colors.grey[300] : Colors.grey[600])!,
                          ),
                        )),
                      ),
                      Row(
                        children: [
                          // Clear Filters Button
                          Obx(() => filterController.hasActiveFilters
                            ? TextButton.icon(
                                onPressed: () => filterController.resetFilters(),
                                icon: const Icon(Icons.clear, size: 16),
                                label: const Text('Xóa bộ lọc'),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                              )
                            : const SizedBox.shrink(),
                          ),
                          
                          const SizedBox(width: 8),
                          
                          // Filter Button
                          ElevatedButton.icon(
                            onPressed: () {
                              FilterBottomSheet.show(context, (filterParams) {
                                filterController.applyFilter(filterParams);
                              });
                            },
                            icon: const Icon(Icons.filter_list, size: 16),
                            label: const Text('Bộ lọc'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Products List
            Expanded(
              child: Obx(() {
                if (filterController.isLoading.value && filterController.products.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (filterController.hasError.value) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          filterController.errorMessage.value,
                          style: AppTextStyle.withColor(
                            AppTextStyle.bodyLarge,
                            Colors.grey[600]!,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => filterController.loadProducts(),
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  );
                }

                if (filterController.products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Không tìm thấy sản phẩm nào',
                          style: AppTextStyle.withColor(
                            AppTextStyle.bodyLarge,
                            Colors.grey[600]!,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Hãy thử thay đổi bộ lọc hoặc từ khóa tìm kiếm',
                          style: AppTextStyle.withColor(
                            AppTextStyle.bodyMedium,
                            Colors.grey[500]!,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification scrollInfo) {
                    if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
                      filterController.loadMoreProducts();
                    }
                    return true;
                  },
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: filterController.products.length + 
                               (filterController.isLoading.value ? 2 : 0),
                    itemBuilder: (context, index) {
                      if (index >= filterController.products.length) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      
                      final product = filterController.products[index];
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
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}