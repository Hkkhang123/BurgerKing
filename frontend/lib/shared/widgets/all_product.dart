import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:client/shared/themes/app_textstyle.dart';
import 'package:client/shared/widgets/best_seller_product_list.dart';

class AllProduct extends StatelessWidget {
  const AllProduct({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: isDark ? Colors.white : Colors.black,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Tất cả sản phẩm',
          style: AppTextStyle.withColor(
            AppTextStyle.withWeight(AppTextStyle.h2, FontWeight.bold),
            isDark ? Colors.white : Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: const BestSellerProductList(),
    );
  }
}
