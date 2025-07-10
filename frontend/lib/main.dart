import 'package:client/core/services/auth_controller.dart';
import 'package:client/core/services/theme_controller.dart';
import 'package:client/core/services/product_controller.dart';
import 'package:client/core/services/cart_controller.dart';
import 'package:client/shared/themes/app_themes.dart';
import 'package:client/features/home/splash_screen.dart';
import 'package:client/features/auth/signin_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await Firebase.initializeApp();
  Get.put(ThemeController());
  Get.put(AuthController());
  Get.put(ProductController());
  Get.put(CartController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Burger King Store',
      theme: AppThemes.light,
      darkTheme: AppThemes.dark,
      themeMode: themeController.theme,
      defaultTransition: Transition.fade,
      home: SplashScreen(),
      getPages: [
        GetPage(name: '/signin', page: () => SigninScreen()),
        // Thêm các route khác nếu cần
      ],
    );
  }
}