import 'package:flutter/material.dart';
import 'package:food_scale/design/colors.dart'; // Цвета
import 'package:food_scale/design/fonts.dart'; // Шрифты
import 'package:food_scale/widgets/product_card.dart'; // Правильный импорт и имя виджета

class BestOfferWidget extends StatelessWidget {
  final Map<String, dynamic> productData;
  final List<dynamic> rootRatings;

  const BestOfferWidget({
    super.key,
    required this.productData,
    required this.rootRatings,
  });

  @override
  Widget build(BuildContext context) {
    // Задаем рейтинг на основе rootRatings и соответствующих данных
    String productRating = getProductRatings(
      productData['ratings'] as List<dynamic>?,
      rootRatings,
    );

    return Padding(
      padding: const EdgeInsets.only(
           top: 10), // Внешние отступы
      child: Column(
        mainAxisSize: MainAxisSize.min, // Ограничение по высоте
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Лучшее предложение',
            style: TextStyle(
              fontSize: 16,
              fontFamily: russianFont,
              fontWeight: FontWeight.w600,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 10), // Отступ между заголовком и карточкой

          // Оборачиваем ProductCard в SizedBox для задания фиксированной ширины
          SizedBox(
            width: 375, // Устанавливаем ширину карточки
            child: ProductCard(
              title: productData['name'] as String,
              description: productData['description'] as String,
              imageUrl: productData['imagePath'] as String,
              price: '${productData['price']} ₸',
              rating: productRating.isEmpty
                  ? 'Нет рейтинга'
                  : productRating, // Передаем корректный рейтинг
            ),
          ),
          const SizedBox(height: 10), // Отступ после карточки
        ],
      ),
    );
  }

  // Для получения рейтинга продукта
  String getProductRatings(List<dynamic>? productRatings, List<dynamic> rootRatings) {
    if (productRatings == null || productRatings.isEmpty) {
      return ''; // Возвращаем пустую строку, если рейтинг отсутствует
    }

    List<String> ratingsList = [];
    for (var productRatingId in productRatings) {
      // Найдем рейтинг, используя ID
      final rootRating = rootRatings.firstWhere(
        (r) =>
            r is Map<String, dynamic> && r['id'] == productRatingId, // Проверяем на совпадение ID
        orElse: () => null, // Если нет совпадений, возвращаем null
      );

      if (rootRating != null) {
        // Используем name из rootRating
        final ratingName = rootRating['name'] ?? '';
        if (ratingName.isNotEmpty) {
          ratingsList.add(ratingName); // Добавляем найденный рейтинг
        }
      }
    }
    return ratingsList.join(', '); // Возвращаем объединённые рейтинги через запятую
  }
}
