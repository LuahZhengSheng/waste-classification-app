import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import 'package:fyp/features/admin/controllers/manager_management/manager_management_controller.dart';

import '../../../../recycling_center/models/recycling_center_staff_model.dart';
import '../../../controllers/center_staff_management/center_staff_management_controller.dart';
import '../../../models/admin_model.dart';

class BanStaffDialog extends StatelessWidget {
  final RecyclingCenterStaff staff;

  const BanStaffDialog({super.key, required this.staff});

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
            'Ban Staff',
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
            'Are you sure you want to ban this staff?',
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
                _buildInfoRow('Username:', staff.username, dark),
                const SizedBox(height: FSizes.xs),
                _buildInfoRow('Email:', staff.email, dark),
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
                    'This staff will be banned and unable to access the system.',
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
            final controller = StaffManagementController.instance;
            await controller.banStaff(staff);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: dark ? FColors.adminDarkError : FColors.adminLightError,
            padding: const EdgeInsets.symmetric(horizontal: FSizes.lg, vertical: FSizes.md),
          ),
          child: const Text('Ban Staff', style: TextStyle(color: Colors.white)),
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
}

class RecoverStaffDialog extends StatelessWidget {
  final RecyclingCenterStaff staff;

  const RecoverStaffDialog({super.key, required this.staff});

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
            'Recover Staff',
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
            'Are you sure you want to recover this staff?',
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
                _buildInfoRow('Username:', staff.username, dark),
                const SizedBox(height: FSizes.xs),
                _buildInfoRow('Email:', staff.email, dark),
                const SizedBox(height: FSizes.xs),
                _buildInfoRow('Role:', _formatRole(staff.role), dark),
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
                    'This staff will be recovered and can access the system again.',
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
            final controller = StaffManagementController.instance;
            await controller.recoverStaff(staff);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess,
            padding: const EdgeInsets.symmetric(horizontal: FSizes.lg, vertical: FSizes.md),
          ),
          child: const Text('Recover Staff', style: TextStyle(color: Colors.white)),
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
        return 'Community Staff';
      case 'event_manager':
        return 'Event Staff';
      case 'reward_manager':
        return 'Reward Staff';
      default:
        return role;
    }
  }
}

class StaffFilterDialog extends StatefulWidget {
  final bool dark;
  final Map<String, dynamic> currentFilters;
  final Function(Map<String, dynamic>) onApplyFilters;

  const StaffFilterDialog({
    super.key,
    required this.dark,
    required this.currentFilters,
    required this.onApplyFilters,
  });

  @override
  State<StaffFilterDialog> createState() => _StaffFilterDialogState();
}

class _StaffFilterDialogState extends State<StaffFilterDialog> {
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
                  'Filter Staffs',
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
                      'Community Staff',
                      style: TextStyle(
                        color: widget.dark ? FColors.adminDarkText : FColors.adminLightText,
                      ),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'event_manager',
                    child: Text(
                      'Event Staff',
                      style: TextStyle(
                        color: widget.dark ? FColors.adminDarkText : FColors.adminLightText,
                      ),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'reward_manager',
                    child: Text(
                      'Reward Staff',
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