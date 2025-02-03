import 'package:flutter/material.dart';
import 'package:food_scale/design/colors.dart';
import 'package:food_scale/design/fonts.dart';
import 'package:food_scale/widgets/listCard.dart';
import 'package:food_scale/widgets/promokodBanner.dart';
import 'package:food_scale/widgets/buttonMenuWidget.dart';
import 'package:food_scale/widgets/bestOfferWidget.dart';
import 'package:food_scale/widgets/customSliverAppBar.dart';
import 'package:food_scale/widgets/imageSlider.dart';
import 'package:food_scale/services/data_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _categoryKeys = {};

  static const String jsonPath = 'assets/data.json';

  void _scrollToCategory(String category) {
    if (_categoryKeys.containsKey(category)) {
      final key = _categoryKeys[category];
      if (key != null && key.currentContext != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final context = key.currentContext!;
          final box = context.findRenderObject() as RenderBox;
          final position = box.localToGlobal(Offset.zero).dy;
          final offset = position - MediaQuery.of(context).padding.top - 60; // Учитываем высоту заголовка
          _scrollController.animateTo(
            offset,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        });
      } else {
        print('Контекст для категории "$category" отсутствует.');
      }
    } else {
      print('Категория "$category" не найдена в _categoryKeys.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: DataService.loadJsonData(jsonPath),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                  'Произошла ошибка при загрузке данных: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Данные отсутствуют.'));
          }

          final jsonData = snapshot.data!;
          final sliderData = jsonData['slider'] as List<dynamic>? ?? [];
          final sliderList = sliderData.map((data) {
            return {
              "imagePath": data["imagePath"]?.toString() ?? '',
              "title": data["title"]?.toString() ?? '',
              "description": data["description"]?.toString() ?? '',
            };
          }).toList();

          final categoriesData = jsonData['categories'] as List<dynamic>? ?? [];
          final bestProduct = DataService.findBestProduct(jsonData, 1);
          final ratings = jsonData['ratings'] as List<dynamic>? ?? [];
          final products = jsonData['products'] as List<dynamic>? ?? [];

          final Map<int, String> categoryMap = {};
          for (var category in categoriesData) {
            final id = category['id'] as int?;
            final name = category['name'] as String?;
            if (id != null && name != null) {
              categoryMap[id] = name;
            }
          }

          final Map<String, List<dynamic>> groupedProducts = {};
          for (var product in products) {
            final categoryId = product['categoryId'] as int?;
            if (categoryId != null && categoryMap.containsKey(categoryId)) {
              final categoryName = categoryMap[categoryId]!;
              if (!groupedProducts.containsKey(categoryName)) {
                groupedProducts[categoryName] = [];
              }
              groupedProducts[categoryName]!.add(product);
            }
          }

          _categoryKeys.clear();

          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              const CustomSliverAppBar(),
              if (sliderList.isNotEmpty)
                SliverToBoxAdapter(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(24),
                    ),
                    child: Container(
                      color: backgroundColor,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ImageSlider(imageTextList: sliderList),
                          const SizedBox(height: 10),
                          const PromokodBanner(),
                          const SizedBox(height: 11),
                          if (bestProduct != null)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: BestOfferWidget(
                                productData: bestProduct,
                                rootRatings: ratings,
                              ),
                            ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
                  minHeight: 60.0,
                  maxHeight: 60.0,
                  child: Container(
                    color: whiteColor,
                    child: ButtonMenuWidget(
                      categories: categoriesData.cast<Map<String, dynamic>>(),
                      onCategorySelected: _scrollToCategory,
                    ),
                  ),
                ),
              ),
              if (groupedProducts.isNotEmpty)
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final category = groupedProducts.keys.elementAt(index);
                      _categoryKeys[category] = GlobalKey();
                      return Container(
                        color: whiteColor,
                        child: Column(
                          key: _categoryKeys[category],
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: Text(
                                category,
                                style: const TextStyle(
                                  fontFamily: russianFont,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: titleColor,
                                ),
                              ),
                            ),
                            ...groupedProducts[category]!.map((product) {
                              return Container(
                                color: whiteColor,
                                child: ListCard(
                                  data: [product],
                                  rootRatings: ratings,
                                ),
                              );
                            }),
                          ],
                        ),
                      );
                    },
                    childCount: groupedProducts.length,
                  ),
                ),
              if (groupedProducts.isEmpty)
                SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Нет категорий',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  final double minHeight;
  final double maxHeight;
  final Widget child;

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}