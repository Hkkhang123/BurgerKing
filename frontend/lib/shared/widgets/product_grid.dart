import 'package:client/shared/widgets/product_card.dart';
import 'package:client/shared/widgets/product_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ProductGrid extends StatelessWidget {
  final List<dynamic> products;
  final List<String>? userFavorites;
  final String? userToken;
  final Function(String, bool)? onFavoriteToggle;

  const ProductGrid({
    super.key,
    required this.products,
    this.userFavorites,
    this.userToken,
    this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return Center(child: Text('Không có sản phẩm nào.'));
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        mainAxisSpacing: 28,
        crossAxisSpacing: 24,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetail(
                product: products[index],
                userFavorites: userFavorites,
              ),
            ),
          ),
          child: ProductCard(
            product: products[index],
            userFavorites: userFavorites,
            userToken: userToken,
            onFavoriteToggle: onFavoriteToggle,
          ),
        );
      },
    );
  }
}
