import 'package:client/controller/theme_controller.dart';
import 'package:client/view/widget/Category_chip.dart';
import 'package:client/view/widget/custom_searchbar.dart';
import 'package:client/view/widget/product_grid.dart';
import 'package:client/view/widget/sale_banner.dart';
import 'package:flutter/material.dart';
import 'package:client/utils/api_service.dart';
import 'package:client/controller/auth_controller.dart';
import 'package:get/get.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late AuthController authController;
  List<String> userFavorites = [];
  String? userToken;

  @override
  void initState() {
    super.initState();
    authController = Get.put(AuthController());
    final user = authController.getCurrentUser();
    userFavorites = user?['favorites']?.cast<String>() ?? [];
    userToken = authController.getToken();
  }

  Future<void> _handleFavoriteToggle(String productId, bool isFavorite) async {
    // Optimistic update: cập nhật UI ngay
    setState(() {
      if (isFavorite) {
        userFavorites.add(productId);
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
          userFavorites.add(productId);
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['error'] ?? 'Lỗi cập nhật yêu thích')),
      );
    }
  }

  Future<List<dynamic>> _fetchBestSellers() async {
    return await ApiService.fetchBestSellerProducts();
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

  @override
  Widget build(BuildContext context) {
    final user = authController.getCurrentUser();
    final String userName = user != null && user['name'] != null ? user['name'] : 'Khách';
    final String? avatarUrl = user != null && user['avatar'] != null ? user['avatar'] : null;
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
                    backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                        ? NetworkImage(avatarUrl)
                        : AssetImage('assets/images/avatar.jpg') as ImageProvider,
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
                    onPressed: () {},
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
            const CustomSearchbar(),

            const CategoryChip(),

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
                  GestureDetector(
                    onTap: () {},
                    child: Text(
                      'Xem tất cả',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor
                      )
                    ),
                  )
                ],
              )
            ),
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: _fetchBestSellers(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Lỗi khi tải sản phẩm.'));
                  } else {
                    final products = snapshot.data ?? [];
                    return ProductGrid(
                      products: products,
                      userFavorites: userFavorites,
                      userToken: userToken,
                      onFavoriteToggle: _handleFavoriteToggle,
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
