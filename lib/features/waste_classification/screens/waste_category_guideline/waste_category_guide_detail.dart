import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../../carbon_footprint_calculator/utils/emission_info_dialog.dart';
import '../../controllers/waste_category_detail_controller.dart';

class WasteCategoryDetailScreen extends StatelessWidget {
  final dynamic category;

  const WasteCategoryDetailScreen({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    final dark = FHelperFunctions.isDarkMode(context);
    final controller =
    Get.put(WasteCategoryDetailController(category)); // 新增 controller

    return Scaffold(
      backgroundColor: dark ? FColors.dark : FColors.light,
      body: CustomScrollView(
        slivers: [
          // Hero App Bar
          SliverAppBar(
            expandedHeight: 250,
            floating: false,
            pinned: true,
            backgroundColor: category.color,
            leading: IconButton(
              icon: const Icon(Iconsax.arrow_left_2, color: FColors.white),
              onPressed: () => Get.back(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      category.color,
                      category.color.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      // Large Category Icon
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: FColors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          category.icon,
                          size: 50,
                          color: FColors.white,
                        ),
                      ),
                      const SizedBox(height: FSizes.spaceBtwItems),
                      Text(
                        category.name,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: FColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(FSizes.defaultSpace),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick Info Cards Row
                  _buildQuickInfoCards(context, dark, controller),

                  const SizedBox(height: FSizes.spaceBtwSections),

                  // Description Section
                  _SectionHeader(
                    title: 'Description',
                    icon: Iconsax.info_circle,
                    dark: dark,
                  ),
                  const SizedBox(height: FSizes.spaceBtwItems),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(FSizes.md),
                    decoration: BoxDecoration(
                      color: dark ? FColors.darkContainer : FColors.white,
                      borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
                      boxShadow: [
                        BoxShadow(
                          color: dark
                              ? Colors.black26
                              : Colors.grey.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      category.description,
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: dark ? FColors.white : FColors.textPrimary,
                      ),
                    ),
                  ),

                  const SizedBox(height: FSizes.spaceBtwSections),

                  // Disposal Method Section
                  _SectionHeader(
                    title: 'How to Dispose',
                    icon: Iconsax.trash,
                    dark: dark,
                  ),
                  const SizedBox(height: FSizes.spaceBtwItems),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(FSizes.md),
                    decoration: BoxDecoration(
                      color: dark ? FColors.darkContainer : FColors.white,
                      borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
                      border: Border.all(
                        color: category.color.withOpacity(0.3),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: dark
                              ? Colors.black26
                              : Colors.grey.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      category.disposalMethod,
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: dark ? FColors.white : FColors.textPrimary,
                      ),
                    ),
                  ),

                  const SizedBox(height: FSizes.spaceBtwSections),

                  // Examples Section
                  _SectionHeader(
                    title: 'Examples',
                    icon: Iconsax.category,
                    dark: dark,
                  ),
                  const SizedBox(height: FSizes.spaceBtwItems),
                  _ExamplesGrid(
                    examples: category.examples,
                    categoryColor: category.color,
                    dark: dark,
                  ),

                  // Bottom spacing
                  const SizedBox(height: FSizes.spaceBtwSections),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickInfoCards(
      BuildContext context,
      bool dark,
      WasteCategoryDetailController controller,
      ) {
    final hasEmission = controller.hasEmission;
    final efPerKg = controller.efPerKg;
    final metadata = controller.emissionMetadata;

    // 计算需要显示的卡片数量
    int cardCount = 1; // Recyclable status always shown
    if (category.basePoints != null) cardCount++;
    if (hasEmission) cardCount++;

    // 如果有三个卡片，使用 Column 布局
    if (cardCount == 3) {
      return Column(
        children: [
          // First row with two cards
          Row(
            children: [
              // Recyclable card
              Expanded(
                child: _InfoCard(
                  icon: category.isRecyclable
                      ? Iconsax.tick_circle
                      : Iconsax.close_circle,
                  title: category.isRecyclable ? 'Recyclable' : 'Not Recyclable',
                  subtitle: category.isRecyclable
                      ? 'Can be recycled'
                      : 'Cannot be recycled',
                  color: category.isRecyclable ? FColors.success : FColors.error,
                  dark: dark,
                ),
              ),
              const SizedBox(width: FSizes.spaceBtwItems),
              // Base Points card
              Expanded(
                child: _InfoCard(
                  icon: Iconsax.medal_star5,
                  title: '${category.basePoints} Points',
                  subtitle: 'Per kilogram',
                  color: FColors.warning,
                  dark: dark,
                ),
              ),
            ],
          ),
          const SizedBox(height: FSizes.spaceBtwItems),
          // Second row - Emission Factor card 占据整行
          if (hasEmission && efPerKg != null && metadata != null)
            SizedBox(
              width: double.infinity,
              child: _EmissionInfoCard(
                efPerKg: efPerKg,
                metadata: metadata,
                categoryColor: category.color,
                dark: dark,
                context: context,
              ),
            ),
        ],
      );
    }

    // 对于 1-2 个卡片
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Recyclable status card
        Expanded(
          child: _InfoCard(
            icon: category.isRecyclable
                ? Iconsax.tick_circle
                : Iconsax.close_circle,
            title: category.isRecyclable ? 'Recyclable' : 'Not Recyclable',
            subtitle: category.isRecyclable
                ? 'Can be recycled'
                : 'Cannot be recycled',
            color: category.isRecyclable ? FColors.success : FColors.error,
            dark: dark,
          ),
        ),

        if (category.basePoints != null || hasEmission)
          const SizedBox(width: FSizes.spaceBtwItems),

        // Base Points card (if available)
        if (category.basePoints != null)
          Expanded(
            child: _InfoCard(
              icon: Iconsax.medal_star5,
              title: '${category.basePoints} Points',
              subtitle: 'Per kilogram',
              color: FColors.warning,
              dark: dark,
            ),
          ),

        // Emission Factor card (if available 且没有 basePoints 占第二格)
        if (hasEmission &&
            category.basePoints == null &&
            efPerKg != null &&
            metadata != null)
          Expanded(
            child: _EmissionInfoCard(
              efPerKg: efPerKg,
              metadata: metadata,
              categoryColor: category.color,
              dark: dark,
              context: context,
            ),
          ),
      ],
    );
  }
}

class _EmissionInfoCard extends StatelessWidget {
  final num efPerKg;
  final Map<String, dynamic> metadata;
  final Color categoryColor;
  final bool dark;
  final BuildContext context;

  const _EmissionInfoCard({
    required this.efPerKg,
    required this.metadata,
    required this.categoryColor,
    required this.dark,
    required this.context,
  });

  @override
  Widget build(BuildContext _) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(FSizes.md),
          decoration: BoxDecoration(
            color: dark ? FColors.darkContainer : FColors.white,
            borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
            boxShadow: [
              BoxShadow(
                color: dark ? Colors.black26 : Colors.grey.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: FColors.info.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Iconsax.cloud,
                  color: FColors.info,
                  size: 24,
                ),
              ),
              const SizedBox(height: FSizes.sm),
              Text(
                '${efPerKg.toStringAsFixed(2)} kg',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: dark ? FColors.white : FColors.textPrimary,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: FSizes.xs),
              Text(
                'CO₂e / kg recycled',
                style: TextStyle(
                  fontSize: 12,
                  color: dark ? FColors.darkGrey : FColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        Positioned(
          top: FSizes.xs,
          left: FSizes.xs,
          child: EmissionInfoDialog.buildInfoIcon(
            context: context,
            metadata: metadata,
            dark: dark,
            color: FColors.info,
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool dark;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.dark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(FSizes.md),
      decoration: BoxDecoration(
        color: dark ? FColors.darkContainer : FColors.white,
        borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
        boxShadow: [
          BoxShadow(
            color: dark ? Colors.black26 : Colors.grey.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: FSizes.sm),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: dark ? FColors.white : FColors.textPrimary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: FSizes.xs),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: dark ? FColors.darkGrey : FColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool dark;

  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.dark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 24,
          color: dark ? FColors.white : FColors.textPrimary,
        ),
        const SizedBox(width: FSizes.sm),
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: dark ? FColors.white : FColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _ExamplesGrid extends StatelessWidget {
  final List examples;
  final Color categoryColor;
  final bool dark;

  const _ExamplesGrid({
    required this.examples,
    required this.categoryColor,
    required this.dark,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: FSizes.sm,
      runSpacing: FSizes.sm,
      children: examples
          .map(
            (example) => Container(
          padding: const EdgeInsets.symmetric(
            horizontal: FSizes.md,
            vertical: FSizes.sm,
          ),
          decoration: BoxDecoration(
            color: dark ? FColors.darkContainer : FColors.white,
            borderRadius: BorderRadius.circular(FSizes.borderRadiusLg),
            border: Border.all(
              color: categoryColor.withOpacity(0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color:
                dark ? Colors.black12 : Colors.grey.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Iconsax.tick_circle,
                size: 16,
                color: categoryColor,
              ),
              const SizedBox(width: FSizes.xs),
              Text(
                example,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color:
                  dark ? FColors.white : FColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      )
          .toList(),
    );
  }
}