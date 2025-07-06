import 'package:client/core/services/auth_controller.dart';
import 'package:client/shared/themes/app_textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:client/features/home/main_screen.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authController = Get.find<AuthController>();
    final user = authController.getCurrentUser();
    final bool isLoggedIn = authController.isLoggedIn;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tài khoản',
          style: AppTextStyle.withColor(
            AppTextStyle.h3,
            isDark ? Colors.white : Colors.black,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.settings_outlined,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (!isLoggedIn)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Vui lòng đăng nhập để xem thông tin tài khoản',
                      style: AppTextStyle.withColor(
                        AppTextStyle.bodyLarge,
                        isDark ? Colors.white : Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
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
              )
            else ...[
              _buildProfileSection(context),
              const SizedBox(height: 24),
              _buildMenuSection(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authController = Get.find<AuthController>();
    final user = authController.getCurrentUser();
    final String name = user?['name'] ?? 'Chưa đăng nhập';
    final String email = user?['email'] ?? '';
    String? avatarUrl;
    if (user != null &&
        user['image'] != null &&
        user['image'].toString().isNotEmpty) {
      avatarUrl = user['image'];
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.grey[100],
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage:
                avatarUrl != null
                    ? NetworkImage(avatarUrl)
                    : const AssetImage('assets/images/avatar.jpg')
                        as ImageProvider,
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: AppTextStyle.withColor(
              AppTextStyle.h2,
              Theme.of(context).textTheme.bodyLarge!.color!,
            ),
          ),

          const SizedBox(height: 4),
          Text(
            email,
            style: AppTextStyle.withColor(
              AppTextStyle.bodyMedium,
              isDark ? Colors.grey[400]! : Colors.grey[600]!,
            ),
          ),

          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              side: BorderSide(color: isDark ? Colors.white70 : Colors.black12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Chỉnh sửa Profile',
              style: AppTextStyle.withColor(
                AppTextStyle.buttonMedium,
                Theme.of(context).textTheme.bodyLarge!.color!,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final menuItems = [
      {'icon': Icons.shopping_bag_outlined, 'title': 'Đơn hàng'},
      {'icon': Icons.location_on_outlined, 'title': 'Địa chỉ giao hàng'},
      {'icon': Icons.help_outline, 'title': 'Trung tâm trợ giúp'},
      {'icon': Icons.logout_outlined, 'title': 'Đăng xuất'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children:
            menuItems.map((item) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
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
                child: ListTile(
                  leading: Icon(
                    item['icon'] as IconData,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: Text(
                    item['title'] as String,
                    style: AppTextStyle.withColor(
                      AppTextStyle.bodyMedium,
                      Theme.of(context).textTheme.bodyLarge!.color!,
                    ),
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                  onTap: () {
                    if (item['title'] == 'Đăng xuất') {
                      _showLogOutDialog(context);
                    } else if (item['title'] == 'Đơn hàng') {
                    } else if (item['title'] == 'Địa chỉ giao hàng') {
                    } else if (item['title'] == 'Trung tâm trợ giúp') {}
                  },
                ),
              );
            }).toList(),
      ),
    );
  }

  void _showLogOutDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Get.dialog(
      AlertDialog(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 20,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withAlpha(100),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.logout_rounded,
                color: Theme.of(context).primaryColor,
                size: 32,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Bạn có chắc muốn đăng xuất ?',
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
                    onPressed: () {
                      Get.back();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(
                        color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Hủy',
                      style: AppTextStyle.withColor(
                        AppTextStyle.buttonMedium,
                        Theme.of(context).textTheme.bodyLarge!.color!,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final authController = Get.find<AuthController>();
                      authController.logout();
                      Get.offAll(() => const MainScreen());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(
                        color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Đăng xuất',
                      style: AppTextStyle.withColor(
                        AppTextStyle.buttonMedium,
                        Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
