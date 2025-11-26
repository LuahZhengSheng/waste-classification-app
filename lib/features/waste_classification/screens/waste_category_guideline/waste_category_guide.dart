import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import '../../../../common/widgets/appbar/appbar.dart';
import '../../../recycling_center/models/waste_category_model.dart';
import '../../controllers/waste_category_guide_controller.dart';
import 'waste_category_guide_detail.dart';

class WasteCategoryGuideScreen extends StatelessWidget {
  const WasteCategoryGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(WasteCategoryController());
    final dark = FHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: dark ? FColors.dark : FColors.light,
      appBar: FAppBar(
        showBackArrow: true,
        title: const Text("Waste Guide"),
      ),
      body: Column(
        children: [
          // Filter Tabs
          _buildFilterTabs(context, controller, dark),

          // Search Bar
          Padding(
            padding: const EdgeInsets.all(FSizes.defaultSpace),
            child: Container(
              decoration: BoxDecoration(
                color: dark ? FColors.darkContainer : FColors.white,
                borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
                boxShadow: [
                  BoxShadow(
                    color: dark ? Colors.black26 : Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Obx(() => TextField(
                controller: controller.searchController,
                onChanged: controller.searchCategories,
                decoration: InputDecoration(
                  hintText: 'Search by name or examples...',
                  hintStyle: TextStyle(
                    color: dark ? FColors.darkGrey : FColors.textSecondary,
                  ),
                  prefixIcon: Icon(
                    Iconsax.search_normal,
                    color: dark ? FColors.darkGrey : FColors.textSecondary,
                  ),
                  suffixIcon: controller.searchText.value.isNotEmpty
                      ? IconButton(
                    icon: Icon(
                      Iconsax.close_circle,
                      color: dark ? FColors.darkGrey : FColors.textSecondary,
                    ),
                    onPressed: controller.clearSearch,
                  )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: FSizes.md,
                    vertical: FSizes.md,
                  ),
                ),
              )),
            ),
          ),

          // PageView for swipe gesture
          Expanded(
            child: PageView(
              controller: controller.pageController,
              onPageChanged: (index) {
                // Update filter when page changes
                if (index == 0) {
                  controller.selectedFilter.value = 'recyclable';
                } else {
                  controller.selectedFilter.value = 'not_recyclable';
                }
                controller.applyFilters();
              },
              children: [
                // Recyclable Page
                _buildCategoriesGrid(controller, dark),
                // Not Recyclable Page
                _buildCategoriesGrid(controller, dark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesGrid(WasteCategoryController controller, bool dark) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(
            color: FColors.primary,
          ),
        );
      }

      final currentCategories = controller.selectedFilter.value == 'recyclable'
          ? controller.getRecyclableCategories()
          : controller.getNonRecyclableCategories();

      if (currentCategories.isEmpty) {
        return _buildEmptyState(dark);
      }

      return RefreshIndicator(
        onRefresh: controller.refreshCategories,
        color: FColors.primary,
        child: GridView.builder(
          padding: const EdgeInsets.symmetric(
            horizontal: FSizes.defaultSpace,
            vertical: FSizes.sm,
          ),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.1,
            crossAxisSpacing: FSizes.gridViewSpacing,
            mainAxisSpacing: FSizes.gridViewSpacing,
          ),
          itemCount: currentCategories.length,
          itemBuilder: (context, index) {
            final category = currentCategories[index];
            return _CategoryCard(category: category, dark: dark);
          },
        ),
      );
    });
  }

  Widget _buildFilterTabs(BuildContext context, WasteCategoryController controller, bool dark) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: FSizes.defaultSpace,
        vertical: FSizes.md,
      ),
      decoration: BoxDecoration(
        color: dark ? FColors.darkContainer : FColors.white,
        borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
      ),
      child: Obx(() => Row(
        children: [
          Expanded(
            child: _buildTabButton(
              context,
              'Recyclable',
              controller.selectedFilter.value == 'recyclable',
                  () {
                controller.switchFilter('recyclable');
                controller.pageController.animateToPage(
                  0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              dark,
            ),
          ),
          Expanded(
            child: _buildTabButton(
              context,
              'Not Recyclable',
              controller.selectedFilter.value == 'not_recyclable',
                  () {
                controller.switchFilter('not_recyclable');
                controller.pageController.animateToPage(
                  1,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              dark,
            ),
          ),
        ],
      )),
    );
  }

  Widget _buildTabButton(
      BuildContext context,
      String label,
      bool isSelected,
      VoidCallback onTap,
      bool dark,
      ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: FSizes.md),
        decoration: BoxDecoration(
          color: isSelected ? FColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: isSelected
                ? FColors.white
                : (dark ? FColors.textSecondary : FColors.darkGrey),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool dark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.search_normal,
            size: 64,
            color: dark ? FColors.darkGrey : FColors.textSecondary,
          ),
          const SizedBox(height: FSizes.spaceBtwItems),
          Text(
            'No categories found',
            style: TextStyle(
              color: dark ? FColors.darkGrey : FColors.textSecondary,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: FSizes.sm),
          Text(
            'Try adjusting your search or filter',
            style: TextStyle(
              color: dark ? FColors.darkGrey : FColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final WasteCategory category;
  final bool dark;

  const _CategoryCard({
    required this.category,
    required this.dark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => WasteCategoryDetailScreen(category: category)),
      child: Container(
        decoration: BoxDecoration(
          color: dark ? FColors.darkContainer : FColors.white,
          borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
          boxShadow: [
            BoxShadow(
              color: dark ? Colors.black26 : Colors.grey.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(FSizes.md),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Category Icon with background
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: category.color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  category.icon,
                  size: 35,
                  color: category.color,
                ),
              ),

              const SizedBox(height: FSizes.spaceBtwItems),

              // Category Name with adaptive font size
              _buildAdaptiveCategoryName(context, dark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdaptiveCategoryName(BuildContext context, bool dark) {
    // 计算名称长度来决定字体大小
    final bool isLongName = category.name.length > 12;

    return LayoutBuilder(
      builder: (context, constraints) {
        // 使用 TextPainter 来测量文本是否需要换行
        final TextPainter textPainter = TextPainter(
          text: TextSpan(
            text: category.name,
            style: TextStyle(
              fontSize: isLongName ? 14 : 16,
              fontWeight: FontWeight.bold,
              color: dark ? FColors.white : FColors.textPrimary,
            ),
          ),
          maxLines: 2,
          textDirection: TextDirection.ltr,
        );

        textPainter.layout(maxWidth: constraints.maxWidth);

        final bool needsSmallerFont = textPainter.didExceedMaxLines ||
            textPainter.width > constraints.maxWidth;

        // 最终字体大小决策
        final double fontSize = (isLongName || needsSmallerFont) ? 13 : 16;

        return Text(
          category.name,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: dark ? FColors.white : FColors.textPrimary,
            height: 1.2, // 调整行高
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        );
      },
    );
  }
}