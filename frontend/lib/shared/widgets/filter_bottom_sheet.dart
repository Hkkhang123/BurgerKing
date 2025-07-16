import 'package:client/shared/themes/app_textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FilterBottomSheet {
  static void show(
    BuildContext context,
    Function(Map<String, dynamic>) onApplyFilter,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Filter state
    RangeValues priceRange = const RangeValues(0, 500000);
    String selectedCategory = 'all';
    double selectedRating = 0;
    String selectedSortBy = 'newest';

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => Container(
                  height: MediaQuery.of(context).size.height * 0.8,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: LayoutBuilder(
                    builder:
                        (context, constraints) => SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: IntrinsicHeight(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Header
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Bộ lọc',
                                        style: AppTextStyle.withColor(
                                          AppTextStyle.h3,
                                          Theme.of(
                                            context,
                                          ).textTheme.bodyLarge!.color!,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () => Get.back(),
                                        icon: Icon(
                                          Icons.close,
                                          color:
                                              isDark
                                                  ? Colors.white
                                                  : Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 24),

                                  // Category Filter
                                  Text(
                                    'Danh mục',
                                    style: AppTextStyle.withColor(
                                      AppTextStyle.bodyLarge,
                                      Theme.of(
                                        context,
                                      ).textTheme.bodyLarge!.color!,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 8,
                                    children:
                                        [
                                          'all',
                                          'pizza',
                                          'burger',
                                          'sushi',
                                          'vietnamese',
                                          'asian',
                                          'western',
                                          'dessert',
                                          'drink',
                                        ].map((category) {
                                          final isSelected =
                                              selectedCategory == category;
                                          return FilterChip(
                                            label: Text(
                                              _getCategoryName(category),
                                            ),
                                            selected: isSelected,
                                            onSelected: (selected) {
                                              setState(() {
                                                selectedCategory = category;
                                              });
                                            },
                                            backgroundColor:
                                                isDark
                                                    ? Colors.grey[800]
                                                    : Colors.grey[200],
                                            selectedColor: Theme.of(
                                              context,
                                            ).primaryColor.withOpacity(0.2),
                                            checkmarkColor:
                                                Theme.of(context).primaryColor,
                                          );
                                        }).toList(),
                                  ),

                                  const SizedBox(height: 24),

                                  // Price Range Filter
                                  Text(
                                    'Khoảng giá',
                                    style: AppTextStyle.withColor(
                                      AppTextStyle.bodyLarge,
                                      Theme.of(
                                        context,
                                      ).textTheme.bodyLarge!.color!,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  RangeSlider(
                                    values: priceRange,
                                    min: 0,
                                    max: 500000,
                                    divisions: 50,
                                    labels: RangeLabels(
                                      '${(priceRange.start / 1000).round()}k',
                                      '${(priceRange.end / 1000).round()}k',
                                    ),
                                    onChanged: (values) {
                                      setState(() {
                                        priceRange = values;
                                      });
                                    },
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${(priceRange.start / 1000).round()}k',
                                      ),
                                      Text(
                                        '${(priceRange.end / 1000).round()}k',
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 24),

                                  // Rating Filter
                                  Text(
                                    'Đánh giá tối thiểu',
                                    style: AppTextStyle.withColor(
                                      AppTextStyle.bodyLarge,
                                      Theme.of(
                                        context,
                                      ).textTheme.bodyLarge!.color!,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: List.generate(5, (index) {
                                      return GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            selectedRating =
                                                selectedRating == index + 1
                                                    ? 0
                                                    : index + 1;
                                          });
                                        },
                                        child: Icon(
                                          index < selectedRating
                                              ? Icons.star
                                              : Icons.star_border,
                                          color:
                                              index < selectedRating
                                                  ? Colors.amber
                                                  : Colors.grey,
                                          size: 30,
                                        ),
                                      );
                                    }),
                                  ),
                                  if (selectedRating > 0)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        'Từ ${selectedRating.toInt()} sao trở lên',
                                        style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),

                                  const SizedBox(height: 24),

                                  // Sort Options
                                  Text(
                                    'Sắp xếp theo',
                                    style: AppTextStyle.withColor(
                                      AppTextStyle.bodyLarge,
                                      Theme.of(
                                        context,
                                      ).textTheme.bodyLarge!.color!,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 8,
                                    children:
                                        [
                                          {
                                            'value': 'newest',
                                            'label': 'Mới nhất',
                                          },
                                          {
                                            'value': 'priceAsc',
                                            'label': 'Giá tăng dần',
                                          },
                                          {
                                            'value': 'priceDesc',
                                            'label': 'Giá giảm dần',
                                          },
                                          {
                                            'value': 'ratingDesc',
                                            'label': 'Đánh giá cao',
                                          },
                                          {
                                            'value': 'popularity',
                                            'label': 'Phổ biến',
                                          },
                                        ].map((sortOption) {
                                          final isSelected =
                                              selectedSortBy ==
                                              sortOption['value'];
                                          return FilterChip(
                                            label: Text(sortOption['label']!),
                                            selected: isSelected,
                                            onSelected: (selected) {
                                              setState(() {
                                                selectedSortBy =
                                                    sortOption['value']!;
                                              });
                                            },
                                            backgroundColor:
                                                isDark
                                                    ? Colors.grey[800]
                                                    : Colors.grey[200],
                                            selectedColor: Theme.of(
                                              context,
                                            ).primaryColor.withOpacity(0.2),
                                            checkmarkColor:
                                                Theme.of(context).primaryColor,
                                          );
                                        }).toList(),
                                  ),

                                  const Spacer(),

                                  // Action Buttons
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton(
                                          onPressed: () {
                                            setState(() {
                                              priceRange = const RangeValues(
                                                0,
                                                500000,
                                              );
                                              selectedCategory = 'all';
                                              selectedRating = 0;
                                              selectedSortBy = 'newest';
                                            });
                                          },
                                          child: const Text('Đặt lại'),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () {
                                            final filterParams = {
                                              'minPrice':
                                                  priceRange.start.round(),
                                              'maxPrice':
                                                  priceRange.end.round(),
                                              'category': selectedCategory,
                                              'minRating': selectedRating,
                                              'sortBy': selectedSortBy,
                                            };
                                            onApplyFilter(filterParams);
                                            Get.back();
                                          },
                                          child: const Text('Áp dụng'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                  ),
                ),
          ),
    );
  }

  static String _getCategoryName(String category) {
    switch (category) {
      case 'all':
        return 'Tất cả';
      case 'pizza':
        return 'Pizza';
      case 'burger':
        return 'Burger';
      case 'sushi':
        return 'Sushi';
      case 'vietnamese':
        return 'Món Việt';
      case 'asian':
        return 'Món Á';
      case 'western':
        return 'Món Âu';
      case 'dessert':
        return 'Tráng miệng';
      case 'drink':
        return 'Đồ uống';
      default:
        return category;
    }
  }
}
