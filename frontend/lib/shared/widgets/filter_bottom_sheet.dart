import 'package:client/shared/themes/app_textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FilterBottomSheet {
  static void show(
    BuildContext context,
    Function(Map<String, dynamic>) onApplyFilter,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Filter state - moved outside to persist across setState calls
    RangeValues _priceRange = const RangeValues(0, 500000);
    String _selectedCategory = 'all';
    double _selectedRating = 0;
    String _selectedSortBy = 'newest';

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
                                          'fries',
                                          'Đồ uống',
                                        ].map((category) {
                                          final isSelected =
                                              _selectedCategory == category;
                                          return FilterChip(
                                            label: Text(
                                              _getCategoryName(category),
                                            ),
                                            selected: isSelected,
                                            onSelected: (selected) {
                                              setState(() {
                                                _selectedCategory = category;
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
                                    values: _priceRange,
                                    min: 0,
                                    max: 500000,
                                    divisions: 50,
                                    labels: RangeLabels(
                                      '${(_priceRange.start / 1000).round()}k',
                                      '${(_priceRange.end / 1000).round()}k',
                                    ),
                                    onChanged: (values) {
                                      setState(() {
                                        _priceRange = values;
                                      });
                                    },
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${(_priceRange.start / 1000).round()}k',
                                      ),
                                      Text(
                                        '${(_priceRange.end / 1000).round()}k',
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
                                            _selectedRating =
                                                _selectedRating == index + 1
                                                    ? 0
                                                    : index + 1;
                                          });
                                        },
                                        child: Icon(
                                          index < _selectedRating
                                              ? Icons.star
                                              : Icons.star_border,
                                          color:
                                              index < _selectedRating
                                                  ? Colors.amber
                                                  : Colors.grey,
                                          size: 30,
                                        ),
                                      );
                                    }),
                                  ),
                                  if (_selectedRating > 0)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        'Từ ${_selectedRating.toInt()} sao trở lên',
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
                                              _selectedSortBy ==
                                              sortOption['value'];
                                          return FilterChip(
                                            label: Text(sortOption['label']!),
                                            selected: isSelected,
                                            onSelected: (selected) {
                                              setState(() {
                                                _selectedSortBy =
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
                                              _priceRange = const RangeValues(
                                                0,
                                                500000,
                                              );
                                              _selectedCategory = 'all';
                                              _selectedRating = 0;
                                              _selectedSortBy = 'newest';
                                            });
                                            // Force rebuild to ensure UI updates
                                            Future.delayed(
                                              const Duration(milliseconds: 100),
                                              () {
                                                setState(() {});
                                              },
                                            );
                                          },
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                          ),
                                          child: const Text('Đặt lại'),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () {
                                            final filterParams = {
                                              'minPrice':
                                                  _priceRange.start.round(),
                                              'maxPrice':
                                                  _priceRange.end.round(),
                                              'category': _selectedCategory,
                                              'minRating': _selectedRating,
                                              'sortBy': _selectedSortBy,
                                            };
                                            onApplyFilter(filterParams);
                                            Get.back();
                                          },
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                          ),
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
      case 'fries':
        return 'Khoai tây chiên';
      case 'Đồ uống':
        return 'Đồ uống';
      default:
        return category;
    }
  }
}
