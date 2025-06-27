import 'package:client/utils/app_textstyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CategoryChip extends StatefulWidget {
  const CategoryChip({super.key});

  @override
  State<CategoryChip> createState() => _CategoryChipState();
}

class _CategoryChipState extends State<CategoryChip> {
  int selectedIndex = 0;
  final categories = [
    'Tất cả',
    'Hamburger',
    'Khoai tây chiên',
    'Gà',
    'Đồ ăn vặt',
  ];
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(
          categories.length,
          (index) => Padding(
            padding: EdgeInsets.only(right: 12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: ChoiceChip(
                label: Text(
                  categories[index],
                  overflow: TextOverflow.visible,
                  softWrap: true,
                  style: AppTextStyle.withColor(
                    selectedIndex == index
                        ? AppTextStyle.withWeight(
                          AppTextStyle.bodySmall,
                          FontWeight.w600,
                        )
                        : AppTextStyle.bodySmall,
                    selectedIndex == index
                        ? Colors.grey[300]!
                        : Colors.grey[600]!,
                  ),
                ),

                selected: selectedIndex == index,
                onSelected: (bool selected) {
                  setState(() {
                    selectedIndex = selected ? index : selectedIndex;
                  });
                },
                selectedColor: Theme.of(context).primaryColor,
                backgroundColor: isDark ? Colors.grey[800] : Colors.grey[100],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: selectedIndex == index ? 2 : 0,
                pressElevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                labelPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 1,
                ),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                side: BorderSide(
                  color:
                      selectedIndex == index
                          ? Colors.transparent
                          : isDark
                          ? Colors.grey[700]!
                          : Colors.grey[300]!,
                  width: 1,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
