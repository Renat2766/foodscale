import 'package:flutter/material.dart';
import 'package:food_scale/design/colors.dart';
import 'package:food_scale/design/fonts.dart';

class ButtonMenuWidget extends StatefulWidget {
  final List<Map<String, dynamic>> categories;
  final Function(String) onCategorySelected;

  const ButtonMenuWidget({
    super.key,
    required this.categories,
    required this.onCategorySelected,
  });

  @override
  ButtonMenuWidgetState createState() => ButtonMenuWidgetState();
}

class ButtonMenuWidgetState extends State<ButtonMenuWidget> {
  String selectedItem = '';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: widget.categories.map((category) {
          final categoryName = category['name']?.toString() ?? '';

          if (categoryName.isEmpty) {
            return Container();
          }

          final isSelected = selectedItem == categoryName;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedItem = categoryName;
                });
                widget.onCategorySelected(categoryName);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.grey[300] : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  categoryName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: russianFont,
                    fontWeight: FontWeight.w600,
                    color: titleColor,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}