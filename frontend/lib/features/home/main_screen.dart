import 'package:client/core/services/navigation_controller.dart';
import 'package:client/core/services/theme_controller.dart';
import 'package:client/features/auth/account_screen.dart';
import 'package:client/features/home/home_screen.dart';
import 'package:client/features/product/shopping_screen.dart';
import 'package:client/shared/widgets/custom_bottom_navbar.dart';
import 'package:client/shared/widgets/favorite_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final NavigationController navigationController = Get.put(
      NavigationController(),
    );
    return GetBuilder<ThemeController>(
      builder:
          (ThemeController) => Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Obx(
                () => IndexedStack(
                  key: ValueKey(navigationController.currentIndex.value),
                  index: navigationController.currentIndex.value,
                  children: [HomeScreen(), ShoppingScreen(),FavoriteScreen(), AccountScreen() ],
                ),
              ),
            ),
            bottomNavigationBar: const CustomBottomNavbar(),
          ),
    );
  }
}
