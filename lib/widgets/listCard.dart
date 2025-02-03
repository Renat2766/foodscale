import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:food_scale/design/colors.dart';
import 'package:food_scale/design/fonts.dart';

class ListCard extends StatefulWidget {
  final List<dynamic>? data;
  final List<dynamic> rootRatings;

  const ListCard({super.key, required this.data, required this.rootRatings});

  @override
  _ListCardState createState() => _ListCardState();
}

class _ListCardState extends State<ListCard> {
  double _offset = 0.0;

  @override
  Widget build(BuildContext context) {
    if (widget.data == null || widget.data!.isEmpty) {
      return const Center(
        child: Text(
          'Нет данных для отображения',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.data!.length,
      itemBuilder: (context, index) {
        final item = widget.data![index];
        final String title = (item['name'] ?? 'Без названия') as String;
        final String description =
            (item['description'] ?? 'Нет описания') as String;
        final String imageUrl =
            (item['imagePath'] ?? 'assets/images/default_image.png') as String;
        final String price = '${item['price'] ?? 'Цена не указана'} ₸';
        final String rating =
            getProductRatings(item['ratings'] as List<dynamic>?, widget.rootRatings);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: GestureDetector(
            onHorizontalDragUpdate: (details) {
              setState(() {
                _offset += details.delta.dx;
                if (_offset > 70) _offset = 70;
                if (_offset < -70) _offset = -70;
              });
            },
            onHorizontalDragEnd: (details) {
              setState(() {
                _offset = 0.0;
              });
            },
            child: Stack(
              children: [
                if (_offset > 0)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(12.0),
                        bottomRight: Radius.circular(12.0),
                      ),
                      child: Container(
                        width: 70,
                        height: 104,
                        color: primaryColor,
                        child: const Icon(
                          Icons.add_shopping_cart,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                if (_offset < 0)
                  Align(
                    alignment: Alignment.centerRight,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12.0),
                        bottomLeft: Radius.circular(12.0),
                      ),
                      child: Container(
                        width: 70,
                        height: 104,
                        color: errorColor,
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                Transform.translate(
                  offset: Offset(_offset, 0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: whiteColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 17),
                      child: Stack(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 100,
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (rating.isNotEmpty)
                                      Row(
                                        children: [
                                          SvgPicture.asset(
                                            'assets/images/icon_star.svg',
                                            height: 10,
                                            width: 10,
                                            colorFilter: const ColorFilter.mode(
                                              primaryColor,
                                              BlendMode.srcIn,
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                          Flexible(
                                            child: Text(
                                              rating,
                                              style: const TextStyle(
                                                fontSize: 10,
                                                fontFamily: russianFont,
                                                fontWeight: FontWeight.w500,
                                                color: primaryColor,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    const SizedBox(height: 8),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12), // Добавлен borderRadius 12px
                                      child: Container(
                                        width: 84,
                                        height: 84,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: imageUrl.startsWith('http')
                                            ? CachedNetworkImage(
                                                imageUrl: imageUrl,
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) => const CircularProgressIndicator(),
                                                errorWidget: (context, url, error) => const Icon(Icons.error),
                                              )
                                            : Image.asset(
                                                imageUrl,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontFamily: russianFont,
                                        fontWeight: FontWeight.w700,
                                        color: titleColor,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      description,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontFamily: russianFont,
                                        fontWeight: FontWeight.w500,
                                        color: textColor,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEDEDED),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        price,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontFamily: kazakhFont,
                                          fontWeight: FontWeight.w700,
                                          color: titleColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Positioned(
                            right: 8,
                            bottom: -5,
                            child: ElevatedButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Кнопка Add нажата для $title'),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.zero,
                                shape: const CircleBorder(),
                                backgroundColor: primaryColor,
                                minimumSize: const Size(24, 24),
                              ),
                              child: const Icon(
                                Icons.add,
                                size: 20,
                                color: whiteColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String getProductRatings(
      List<dynamic>? productRatings, List<dynamic> rootRatings) {
    if (productRatings == null || productRatings.isEmpty) {
      return '';
    }

    List<String> ratingsList = [];
    for (var productRatingId in productRatings) {
      final rootRating = rootRatings.firstWhere(
        (r) => r is Map<String, dynamic> && r['id'] == productRatingId,
        orElse: () => null,
      );

      if (rootRating != null) {
        final ratingName = rootRating['name'] ?? '';
        if (ratingName.isNotEmpty) {
          ratingsList.add(ratingName);
        }
      }
    }
    return ratingsList.join(', ');
  }
}