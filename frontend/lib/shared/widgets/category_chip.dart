import 'package:client/shared/themes/app_textstyle.dart';
import 'package:flutter/material.dart';

class CategoryChip extends StatefulWidget {
  final Function(String category)? onCategorySelected;
  const CategoryChip({super.key, this.onCategorySelected});

  @override
  State<CategoryChip> createState() => _CategoryChipState();
}

class _CategoryChipState extends State<CategoryChip> {
  int selectedIndex = 0;
  final categories = [
    {'label': 'Tất cả', 'value': 'all'},
    {'label': 'Hamburger', 'value': 'burger'},
    {'label': 'Khoai tây chiên', 'value': 'fries'},
    {'label': 'Pizza', 'value': 'pizza'},
    {'label': 'Đồ uống', 'value': 'drink'},
    {'label': 'Việt Nam', 'value': 'vietnamese'},
    {'label': 'Sushi', 'value': 'sushi'},
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
                  categories[index]['label']!,
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
                  if (widget.onCategorySelected != null) {
                    widget.onCategorySelected!(
                      categories[selectedIndex]['value']!,
                    );
                  }
                },
                selectedColor: Theme.of(context).primaryColor,
                backgroundColor: isDark ? Colors.grey[800] : Colors.grey[100],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: selectedIndex == index ? 2 : 0,
                pressElevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                labelPadding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 0,
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
