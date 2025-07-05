import 'package:client/controller/theme_controller.dart';
import 'package:client/view/widget/category_chip.dart';
import 'package:client/view/widget/all_product.dart';
import 'package:client/view/widget/cart_screen.dart';
import 'package:client/view/widget/custom_searchbar.dart';
import 'package:client/view/widget/product_grid.dart';
import 'package:client/view/widget/sale_banner.dart';
import 'package:flutter/material.dart';
import 'package:client/utils/api_service.dart';
import 'package:client/controller/auth_controller.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late AuthController authController;
  List<String> userFavorites = [];
  String? userToken;
  String selectedCategory = 'Tất cả';
  String searchQuery = '';
  List<dynamic> allProducts = [];
  List<dynamic> filteredProducts = [];
  bool _profileFetched = false;

  @override
  void initState() {
    super.initState();
    authController = Get.put(AuthController());
    _loadUserData();
    _fetchProfileIfNeeded();
  }

  void _fetchProfileIfNeeded() async {
    final user = authController.getCurrentUser();
    final token = authController.getToken();
    if (user == null && token != null && !_profileFetched) {
      _profileFetched = true;
      await authController.fetchAndUpdateProfile();
      if (mounted) setState(() {});
    }
  }

  Future<void> _loadUserData() async {
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
        });
      } catch (e) {
        // Fallback to local storage if server fails
        final localFavorites = user?['favorites'] as List<dynamic>?;
        userFavorites = localFavorites?.map((e) => e.toString()).toList() ?? [];
      }
    } else {
      final localFavorites = user?['favorites'] as List<dynamic>?;
      userFavorites = localFavorites?.map((e) => e.toString()).toList() ?? [];
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

  Future<void> _refreshUserFavorites() async {
    try {
      final result = await authController.fetchAndUpdateProfile();
      setState(() {
        userFavorites = result;
      });
    } catch (e) {
      // Handle error silently
    }
  }

  Future<List<dynamic>> _fetchBestSellers() async {
    final products = await ApiService.fetchBestSellerProducts();
    setState(() {
      allProducts = products;
      _applyFilters();
    });
    return products;
  }

  void _applyFilters() {
    setState(() {
      filteredProducts = allProducts.where((product) {
        final name = (product['name'] ?? '').toString().toLowerCase();
        final category = (product['category'] ?? '').toString();
        final matchesCategory = selectedCategory == 'Tất cả' || category == selectedCategory;
        final matchesSearch = searchQuery.isEmpty || name.contains(searchQuery.toLowerCase());
        return matchesCategory && matchesSearch;
      }).toList();
    });
  }

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'Chào buổi sáng';
    } else if (hour >= 12 && hour < 18) {
      return 'Chào buổi trưa';
    } else if (hour >= 18 && hour < 22) {
      return 'Chào buổi tối';
    } else {
      return 'Chúc ngủ ngon';
    }
  }

  bool isLoggedIn() {
    return authController.getToken() != null;
  }

  String getGuestId() {
    final storage = GetStorage();
    String? guestId = storage.read('guestId');
    if (guestId == null) {
      guestId = 'guest_${DateTime.now().millisecondsSinceEpoch}';
      storage.write('guestId', guestId);
    }
    return guestId;
  }

  @override
  Widget build(BuildContext context) {
    final user = authController.getCurrentUser();
    final token = authController.getToken();
    final String userName = user != null && user['name'] != null ? user['name'] : (isLoggedIn() ? 'Khách' : getGuestId());
    final String? avatarUrl = user != null && user['image'] != null ? user['image'] : null;
    
    // Kiểm tra URL hợp lệ
    bool isValidAvatarUrl = avatarUrl != null && 
                           avatarUrl.isNotEmpty && 
                           (avatarUrl.startsWith('http://') || avatarUrl.startsWith('https://'));
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: isValidAvatarUrl
                        ? NetworkImage(avatarUrl)
                        : AssetImage('assets/images/avatar.jpg') as ImageProvider,
                    onBackgroundImageError: (exception, stackTrace) {
                      // Fallback to default avatar if network image fails
                    },
                    child: isValidAvatarUrl
                        ? null
                        : Icon(Icons.person, color: Colors.grey),
                  ),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      Text(
                        getGreeting(),
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Spacer(),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.notifications_outlined),
                  ),
                  IconButton(
                    onPressed: () => Get.to(() => CartScreen()),
                    icon: const Icon(Icons.shopping_bag_outlined),
                  ),
                  GetBuilder<ThemeController>(
                    builder:
                        (controller) => IconButton(
                          onPressed: () => controller.toggleTheme(),
                          icon: Icon(
                            controller.isDarkMode
                                ? Icons.dark_mode
                                : Icons.light_mode,
                          ),
                        ),
                  ),
                ],
              ),
            ),
            CustomSearchbar(
              onSearchChanged: (query) {
                searchQuery = query;
                _applyFilters();
              },
            ),

            CategoryChip(
              onCategorySelected: (category) {
                selectedCategory = category;
                _applyFilters();
              },
            ),

            const SaleBanner(),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Món ăn bán chạy',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    )
                  ),
                  Row(
                    children: [
                    
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => Get.to(() => AllProduct()),
                        child: Text(
                          'Xem tất cả',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor
                          )
                        ),
                      ),
                    ],
                  ),
                ],
              )
            ),
            Expanded(
              child: allProducts.isEmpty
                  ? FutureBuilder<List<dynamic>>(
                      future: _fetchBestSellers(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(child: Text('Lỗi khi tải sản phẩm.'));
                        } else {
                          return ProductGrid(
                            products: filteredProducts,
                            userFavorites: userFavorites,
                            userToken: userToken,
                            onFavoriteToggle: _handleFavoriteToggle,
                          );
                        }
                      },
                    )
                  : ProductGrid(
                      products: filteredProducts,
                      userFavorites: userFavorites,
                      userToken: userToken,
                      onFavoriteToggle: _handleFavoriteToggle,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
