import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import 'package:fyp/features/admin/controllers/manager_management/manager_management_controller.dart';

import '../../../models/admin_model.dart';

class BanManagerDialog extends StatelessWidget {
  final AdminModel manager;

  const BanManagerDialog({super.key, required this.manager});

  @override
  Widget build(BuildContext context) {
    final dark = FHelperFunctions.isDarkMode(context);

    return AlertDialog(
      backgroundColor: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(FSizes.sm),
            decoration: BoxDecoration(
              color: (dark ? FColors.adminDarkError : FColors.adminLightError).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Iconsax.slash,
              color: dark ? FColors.adminDarkError : FColors.adminLightError,
              size: 24,
            ),
          ),
          const SizedBox(width: FSizes.md),
          Text(
            'Ban Manager',
            style: TextStyle(
              color: dark ? FColors.adminDarkText : FColors.adminLightText,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Are you sure you want to ban this manager?',
            style: TextStyle(
              color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
            ),
          ),
          const SizedBox(height: FSizes.md),
          Container(
            padding: const EdgeInsets.all(FSizes.md),
            decoration: BoxDecoration(
              color: dark ? FColors.adminDarkBackground : FColors.adminLightBackground,
              borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
              border: Border.all(
                color: dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Username:', manager.username, dark),
                const SizedBox(height: FSizes.xs),
                _buildInfoRow('Email:', manager.email, dark),
                const SizedBox(height: FSizes.xs),
                _buildInfoRow('Role:', _formatRole(manager.role), dark),
              ],
            ),
          ),
          const SizedBox(height: FSizes.md),
          Container(
            padding: const EdgeInsets.all(FSizes.md),
            decoration: BoxDecoration(
              color: (dark ? FColors.adminDarkError : FColors.adminLightError).withOpacity(0.1),
              borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
              border: Border.all(
                color: dark ? FColors.adminDarkError : FColors.adminLightError,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Iconsax.warning_2,
                  color: dark ? FColors.adminDarkError : FColors.adminLightError,
                  size: 20,
                ),
                const SizedBox(width: FSizes.sm),
                Expanded(
                  child: Text(
                    'This manager will be banned and unable to access the system.',
                    style: TextStyle(
                      color: dark ? FColors.adminDarkError : FColors.adminLightError,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text(
            'Cancel',
            style: TextStyle(
              color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            Get.back();
            final controller = ManagerManagementController.instance;
            await controller.banManager(manager);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: dark ? FColors.adminDarkError : FColors.adminLightError,
            padding: const EdgeInsets.symmetric(horizontal: FSizes.lg, vertical: FSizes.md),
          ),
          child: const Text('Ban Manager', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, bool dark) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: dark ? FColors.adminDarkText : FColors.adminLightText,
            fontSize: 13,
          ),
        ),
        const SizedBox(width: FSizes.xs),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
              fontSize: 13,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _formatRole(String role) {
    switch (role) {
      case 'community_manager':
        return 'Community Manager';
      case 'event_manager':
        return 'Event Manager';
      case 'reward_manager':
        return 'Reward Manager';
      default:
        return role;
    }
  }
}

class RecoverManagerDialog extends StatelessWidget {
  final AdminModel manager;

  const RecoverManagerDialog({super.key, required this.manager});

  @override
  Widget build(BuildContext context) {
    final dark = FHelperFunctions.isDarkMode(context);

    return AlertDialog(
      backgroundColor: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(FSizes.sm),
            decoration: BoxDecoration(
              color: (dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Iconsax.refresh,
              color: dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess,
              size: 24,
            ),
          ),
          const SizedBox(width: FSizes.md),
          Text(
            'Recover Manager',
            style: TextStyle(
              color: dark ? FColors.adminDarkText : FColors.adminLightText,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Are you sure you want to recover this manager?',
            style: TextStyle(
              color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
            ),
          ),
          const SizedBox(height: FSizes.md),
          Container(
            padding: const EdgeInsets.all(FSizes.md),
            decoration: BoxDecoration(
              color: dark ? FColors.adminDarkBackground : FColors.adminLightBackground,
              borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
              border: Border.all(
                color: dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Username:', manager.username, dark),
                const SizedBox(height: FSizes.xs),
                _buildInfoRow('Email:', manager.email, dark),
                const SizedBox(height: FSizes.xs),
                _buildInfoRow('Role:', _formatRole(manager.role), dark),
              ],
            ),
          ),
          const SizedBox(height: FSizes.md),
          Container(
            padding: const EdgeInsets.all(FSizes.md),
            decoration: BoxDecoration(
              color: (dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess).withOpacity(0.1),
              borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
              border: Border.all(
                color: dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Iconsax.tick_circle,
                  color: dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess,
                  size: 20,
                ),
                const SizedBox(width: FSizes.sm),
                Expanded(
                  child: Text(
                    'This manager will be recovered and can access the system again.',
                    style: TextStyle(
                      color: dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text(
            'Cancel',
            style: TextStyle(
              color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            Get.back();
            final controller = ManagerManagementController.instance;
            await controller.recoverManager(manager);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess,
            padding: const EdgeInsets.symmetric(horizontal: FSizes.lg, vertical: FSizes.md),
          ),
          child: const Text('Recover Manager', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, bool dark) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: dark ? FColors.adminDarkText : FColors.adminLightText,
            fontSize: 13,
          ),
        ),
        const SizedBox(width: FSizes.xs),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
              fontSize: 13,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _formatRole(String role) {
    switch (role) {
      case 'community_manager':
        return 'Community Manager';
      case 'event_manager':
        return 'Event Manager';
      case 'reward_manager':
        return 'Reward Manager';
      default:
        return role;
    }
  }
}

class ManagerFilterDialog extends StatefulWidget {
  final bool dark;
  final Map<String, dynamic> currentFilters;
  final Function(Map<String, dynamic>) onApplyFilters;

  const ManagerFilterDialog({
    super.key,
    required this.dark,
    required this.currentFilters,
    required this.onApplyFilters,
  });

  @override
  State<ManagerFilterDialog> createState() => _ManagerFilterDialogState();
}

class _ManagerFilterDialogState extends State<ManagerFilterDialog> {
  late Map<String, dynamic> filters;

  @override
  void initState() {
    super.initState();
    filters = Map.from(widget.currentFilters);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: widget.dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
      ),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(FSizes.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter Managers',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: widget.dark ? FColors.adminDarkText : FColors.adminLightText,
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(
                    Iconsax.close_circle,
                    color: widget.dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: FSizes.spaceBtwItems),

            _buildFilterSection(
              'Role',
              DropdownButton<String?>(
                value: filters['role'],
                isExpanded: true,
                onChanged: (value) => setState(() => filters['role'] = value),
                items: [
                  DropdownMenuItem(
                    value: null,
                    child: Text(
                      'All',
                      style: TextStyle(
                        color: widget.dark ? FColors.adminDarkText : FColors.adminLightText,
                      ),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'community_manager',
                    child: Text(
                      'Community Manager',
                      style: TextStyle(
                        color: widget.dark ? FColors.adminDarkText : FColors.adminLightText,
                      ),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'event_manager',
                    child: Text(
                      'Event Manager',
                      style: TextStyle(
                        color: widget.dark ? FColors.adminDarkText : FColors.adminLightText,
                      ),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'reward_manager',
                    child: Text(
                      'Reward Manager',
                      style: TextStyle(
                        color: widget.dark ? FColors.adminDarkText : FColors.adminLightText,
                      ),
                    ),
                  ),
                ],
                underline: const SizedBox(),
                dropdownColor: widget.dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
              ),
            ),

            _buildFilterSection(
              'Verification Status',
              DropdownButton<bool?>(
                value: filters['isVerified'],
                isExpanded: true,
                onChanged: (value) => setState(() => filters['isVerified'] = value),
                items: [
                  DropdownMenuItem(
                    value: null,
                    child: Text(
                      'All',
                      style: TextStyle(
                        color: widget.dark ? FColors.adminDarkText : FColors.adminLightText,
                      ),
                    ),
                  ),
                  DropdownMenuItem(
                    value: true,
                    child: Text(
                      'Verified',
                      style: TextStyle(
                        color: widget.dark ? FColors.adminDarkText : FColors.adminLightText,
                      ),
                    ),
                  ),
                  DropdownMenuItem(
                    value: false,
                    child: Text(
                      'Unverified',
                      style: TextStyle(
                        color: widget.dark ? FColors.adminDarkText : FColors.adminLightText,
                      ),
                    ),
                  ),
                ],
                underline: const SizedBox(),
                dropdownColor: widget.dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
              ),
            ),

            const SizedBox(height: FSizes.spaceBtwSections),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        filters = {
                          'role': null,
                          'isVerified': null,
                        };
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: widget.dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: FSizes.md),
                    ),
                    child: Text(
                      'Clear All',
                      style: TextStyle(
                        color: widget.dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: FSizes.md),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onApplyFilters(filters);
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
                      padding: const EdgeInsets.symmetric(vertical: FSizes.md),
                    ),
                    child: const Text(
                      'Apply Filters',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: widget.dark ? FColors.adminDarkText : FColors.adminLightText,
          ),
        ),
        const SizedBox(height: FSizes.sm),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: FSizes.md, vertical: FSizes.sm),
          decoration: BoxDecoration(
            border: Border.all(
              color: widget.dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
            ),
            borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
          ),
          child: content,
        ),
        const SizedBox(height: FSizes.spaceBtwItems),
      ],
    );
  }
}