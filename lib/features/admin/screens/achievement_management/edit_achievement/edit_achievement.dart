import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';

import '../../../../leaderboard_achievement/models/achievement_level_model.dart';
import '../../../controllers/achievement_management/edit_achievement_controller.dart';

class EditAchievementDialog extends StatelessWidget {
  final bool dark;

  const EditAchievementDialog({
    super.key,
    required this.dark,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EditAchievementController());
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.1,
        vertical: screenHeight * 0.05,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 900,
          maxHeight: screenHeight * 0.9,
        ),
        decoration: BoxDecoration(
          color: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
          borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            _buildHeader(controller, dark),

            // Content
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
                    ),
                  );
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(FSizes.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Achievement Basic Info
                      _buildBasicInfo(controller, dark),
                      const SizedBox(height: FSizes.spaceBtwSections),

                      // Levels Section
                      _buildLevelsSection(controller, dark),
                    ],
                  ),
                );
              }),
            ),

            // Footer Actions
            _buildFooter(controller, dark),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(EditAchievementController controller, bool dark) {
    return Container(
      padding: const EdgeInsets.all(FSizes.lg),
      decoration: BoxDecoration(
        color: dark
            ? FColors.adminDarkSurfaceVariant
            : FColors.adminLightSurfaceVariant,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(FSizes.cardRadiusLg),
          topRight: Radius.circular(FSizes.cardRadiusLg),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(FSizes.sm),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
                  (dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary)
                      .withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
            ),
            child: const Icon(
              Iconsax.edit,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: FSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit Achievement',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: dark ? FColors.adminDarkText : FColors.adminLightText,
                  ),
                ),
                Text(
                  'Modify achievement levels and criteria',
                  style: TextStyle(
                    fontSize: 12,
                    color: dark
                        ? FColors.adminDarkTextSecondary
                        : FColors.adminLightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Get.back(),
            icon: Icon(
              Iconsax.close_circle,
              color: dark
                  ? FColors.adminDarkTextSecondary
                  : FColors.adminLightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfo(EditAchievementController controller, bool dark) {
    return Container(
      padding: const EdgeInsets.all(FSizes.lg),
      decoration: BoxDecoration(
        color: dark
            ? FColors.adminDarkSurfaceVariant
            : FColors.adminLightSurfaceVariant,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
        border: Border.all(
          color: dark
              ? FColors.adminDarkBorder.withOpacity(0.3)
              : FColors.adminLightBorder.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Achievement Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: dark ? FColors.adminDarkText : FColors.adminLightText,
            ),
          ),
          const SizedBox(height: FSizes.md),
          _buildInfoRow('Title', controller.achievement.value.title, dark),
          _buildInfoRow('Category', controller.achievement.value.category, dark),
          Obx(() => _buildInfoRow(
            'Max Level',
            '${controller.editedLevels.length} levels',
            dark,
          )),
          _buildInfoRow(
            'ID',
            controller.achievement.value.achievementId,
            dark,
            isMonospace: true,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool dark,
      {bool isMonospace = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: FSizes.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                color: dark
                    ? FColors.adminDarkTextSecondary
                    : FColors.adminLightTextSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: dark ? FColors.adminDarkText : FColors.adminLightText,
                fontFamily: isMonospace ? 'monospace' : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelsSection(EditAchievementController controller, bool dark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Achievement Levels',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: dark ? FColors.adminDarkText : FColors.adminLightText,
              ),
            ),
            Obx(() {
              final canAddLevel = controller.editedLevels.length < 7;
              return ElevatedButton.icon(
                onPressed: canAddLevel ? controller.addLevel : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: canAddLevel
                      ? (dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess)
                      : (dark ? FColors.adminDarkBorder : FColors.adminLightBorder),
                  foregroundColor: canAddLevel
                      ? Colors.white
                      : (dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted),
                  disabledBackgroundColor: dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
                  disabledForegroundColor: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
                  padding: const EdgeInsets.symmetric(
                    horizontal: FSizes.md,
                    vertical: FSizes.sm,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
                  ),
                ),
                icon: const Icon(Iconsax.add, size: 18),
                label: Text(
                  'Add Level (${controller.editedLevels.length}/7)',
                  style: const TextStyle(fontSize: 14),
                ),
              );
            }),
          ],
        ),
        const SizedBox(height: FSizes.md),
        Text(
          'Minimum 3 levels required. Unlock criteria must increase by at least 25% per level.',
          style: TextStyle(
            fontSize: 12,
            color: dark
                ? FColors.adminDarkTextSecondary
                : FColors.adminLightTextSecondary,
          ),
        ),
        const SizedBox(height: FSizes.lg),
        Obx(() => ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.editedLevels.length,
          separatorBuilder: (context, index) => const SizedBox(height: FSizes.md),
          itemBuilder: (context, index) {
            final level = controller.editedLevels[index];
            return _buildLevelCard(controller, level, index, dark);
          },
        )),
      ],
    );
  }

  Widget _buildLevelCard(
      EditAchievementController controller,
      AchievementLevel level,
      int index,
      bool dark,
      ) {
    // 只有 Level 4 及后面的等级可以删除 (index >= 3 对应 Level 4)
    final canDelete = index >= 3;
    final minUnlockCriteria = controller.getMinimumUnlockCriteria(index);

    return Container(
      padding: const EdgeInsets.all(FSizes.lg),
      decoration: BoxDecoration(
        color: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
        border: Border.all(
          color: dark
              ? FColors.adminDarkBorder.withOpacity(0.3)
              : FColors.adminLightBorder.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Level Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: FSizes.md,
                  vertical: FSizes.xs,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getLevelColor(level.level, dark),
                      _getLevelColor(level.level, dark).withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(FSizes.cardRadiusXs),
                ),
                child: Text(
                  'Level ${level.level}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              const Spacer(),
              if (canDelete)
                IconButton(
                  onPressed: () => controller.removeLevel(index),
                  icon: Icon(
                    Iconsax.trash,
                    color: dark ? FColors.adminDarkError : FColors.adminLightError,
                    size: 20,
                  ),
                  tooltip: 'Remove Level',
                ),
            ],
          ),
          const SizedBox(height: FSizes.md),

          // Badge Emoji
          Text(
            'Badge Emoji',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: dark ? FColors.adminDarkText : FColors.adminLightText,
            ),
          ),
          const SizedBox(height: FSizes.sm),
          TextFormField(
            initialValue: level.badgeImage,
            onChanged: (value) => controller.updateLevelField(
              index,
              'badgeImage',
              value,
            ),
            decoration: InputDecoration(
              hintText: 'Enter emoji (e.g., 🏆)',
              prefixIcon: Icon(
                Iconsax.emoji_happy,
                color: dark
                    ? FColors.adminDarkTextSecondary
                    : FColors.adminLightTextSecondary,
              ),
              filled: true,
              fillColor: dark
                  ? FColors.adminDarkSurfaceVariant
                  : FColors.adminLightSurfaceVariant,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(FSizes.md),
            ),
            style: TextStyle(
              fontSize: 24,
              color: dark ? FColors.adminDarkText : FColors.adminLightText,
            ),
          ),
          const SizedBox(height: FSizes.md),

          // Title
          Text(
            'Title',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: dark ? FColors.adminDarkText : FColors.adminLightText,
            ),
          ),
          const SizedBox(height: FSizes.sm),
          TextFormField(
            initialValue: level.title,
            onChanged: (value) => controller.updateLevelField(
              index,
              'title',
              value,
            ),
            decoration: InputDecoration(
              hintText: 'Enter level title',
              prefixIcon: Icon(
                Iconsax.text,
                color: dark
                    ? FColors.adminDarkTextSecondary
                    : FColors.adminLightTextSecondary,
              ),
              filled: true,
              fillColor: dark
                  ? FColors.adminDarkSurfaceVariant
                  : FColors.adminLightSurfaceVariant,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(FSizes.md),
            ),
            style: TextStyle(
              color: dark ? FColors.adminDarkText : FColors.adminLightText,
            ),
          ),
          const SizedBox(height: FSizes.md),

          // Description
          Text(
            'Description',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: dark ? FColors.adminDarkText : FColors.adminLightText,
            ),
          ),
          const SizedBox(height: FSizes.sm),
          TextFormField(
            initialValue: level.description,
            onChanged: (value) => controller.updateLevelField(
              index,
              'description',
              value,
            ),
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Enter level description',
              prefixIcon: Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: Icon(
                  Iconsax.document_text,
                  color: dark
                      ? FColors.adminDarkTextSecondary
                      : FColors.adminLightTextSecondary,
                ),
              ),
              filled: true,
              fillColor: dark
                  ? FColors.adminDarkSurfaceVariant
                  : FColors.adminLightSurfaceVariant,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(FSizes.md),
            ),
            style: TextStyle(
              color: dark ? FColors.adminDarkText : FColors.adminLightText,
            ),
          ),
          const SizedBox(height: FSizes.md),

          // Unlock Criteria
          Text(
            'Unlock Criteria',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: dark ? FColors.adminDarkText : FColors.adminLightText,
            ),
          ),
          const SizedBox(height: FSizes.sm),
          TextFormField(
            initialValue: level.unlockCriteria.toString(),
            onChanged: (value) {
              final intValue = int.tryParse(value) ?? 0;
              controller.updateLevelField(index, 'unlockCriteria', intValue);
            },
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              hintText: 'Enter unlock criteria (min: $minUnlockCriteria)',
              prefixIcon: Icon(
                Iconsax.chart,
                color: dark
                    ? FColors.adminDarkTextSecondary
                    : FColors.adminLightTextSecondary,
              ),
              filled: true,
              fillColor: dark
                  ? FColors.adminDarkSurfaceVariant
                  : FColors.adminLightSurfaceVariant,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(FSizes.md),
              helperText: index > 0
                  ? 'Must be at least ${minUnlockCriteria} (25% more than previous level)'
                  : null,
              helperStyle: TextStyle(
                color: dark
                    ? FColors.adminDarkTextSecondary
                    : FColors.adminLightTextSecondary,
                fontSize: 11,
              ),
            ),
            style: TextStyle(
              color: dark ? FColors.adminDarkText : FColors.adminLightText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(EditAchievementController controller, bool dark) {
    return Container(
      padding: const EdgeInsets.all(FSizes.lg),
      decoration: BoxDecoration(
        color: dark
            ? FColors.adminDarkSurfaceVariant
            : FColors.adminLightSurfaceVariant,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(FSizes.cardRadiusLg),
          bottomRight: Radius.circular(FSizes.cardRadiusLg),
        ),
        border: Border(
          top: BorderSide(
            color: dark
                ? FColors.adminDarkDivider
                : FColors.adminLightDivider,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: FSizes.lg,
                vertical: FSizes.md,
              ),
            ),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: dark
                    ? FColors.adminDarkTextSecondary
                    : FColors.adminLightTextSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: FSizes.md),
          Obx(() => ElevatedButton(
            onPressed: controller.canSave.value
                ? controller.saveChanges
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: controller.canSave.value
                  ? (dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary)
                  : (dark ? FColors.adminDarkBorder : FColors.adminLightBorder),
              foregroundColor: controller.canSave.value
                  ? Colors.white
                  : (dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted),
              disabledBackgroundColor: dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
              disabledForegroundColor: dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted,
              padding: const EdgeInsets.symmetric(
                horizontal: FSizes.xl,
                vertical: FSizes.md,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
              ),
              elevation: 0,
            ),
            child: Row(
              children: [
                const Icon(Iconsax.tick_circle, size: 18),
                const SizedBox(width: FSizes.sm),
                const Text(
                  'Save Changes',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Color _getLevelColor(int level, bool dark) {
    final colors = [
      dark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
      dark ? const Color(0xFF10B981) : const Color(0xFF059669),
      dark ? const Color(0xFF3B82F6) : const Color(0xFF2563EB),
      dark ? const Color(0xFF8B5CF6) : const Color(0xFF7C3AED),
      dark ? const Color(0xFFF59E0B) : const Color(0xFFD97706),
      dark ? const Color(0xFFEF4444) : const Color(0xFFDC2626),
      dark ? const Color(0xFFEC4899) : const Color(0xFFDB2777),
    ];

    if (level <= 0) return colors[0];
    if (level > colors.length) return colors.last;
    return colors[level - 1];
  }
}