import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import 'package:fyp/features/authentication/models/user_model.dart';
import 'package:fyp/features/admin/controllers/user_management/user_management_controller.dart';

class BanUserDialog extends StatelessWidget {
  final UserModel user;

  const BanUserDialog({super.key, required this.user});

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
            'Ban User',
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
            'Are you sure you want to ban this user?',
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
                _buildInfoRow('Username:', user.username, dark),
                const SizedBox(height: FSizes.xs),
                _buildInfoRow('Email:', user.email, dark),
                const SizedBox(height: FSizes.xs),
                _buildInfoRow('User ID:', user.userId, dark),
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
                    'This user will be banned and unable to access the system.',
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
            final controller = UserManagementController.instance;
            await controller.banUser(user);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: dark ? FColors.adminDarkError : FColors.adminLightError,
            padding: const EdgeInsets.symmetric(horizontal: FSizes.lg, vertical: FSizes.md),
          ),
          child: const Text('Ban User', style: TextStyle(color: Colors.white)),
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

class RecoverUserDialog extends StatelessWidget {
  final UserModel user;

  const RecoverUserDialog({super.key, required this.user});

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
            'Recover User',
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
            'Are you sure you want to recover this user?',
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
                _buildInfoRow('Username:', user.username, dark),
                const SizedBox(height: FSizes.xs),
                _buildInfoRow('Email:', user.email, dark),
                const SizedBox(height: FSizes.xs),
                _buildInfoRow('User ID:', user.userId, dark),
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
                    'This user will be recovered and can access the system again.',
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
            final controller = UserManagementController.instance;
            await controller.recoverUser(user);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess,
            padding: const EdgeInsets.symmetric(horizontal: FSizes.lg, vertical: FSizes.md),
          ),
          child: const Text('Recover User', style: TextStyle(color: Colors.white)),
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

class UserFilterDialog extends StatefulWidget {
  final bool dark;
  final Map<String, dynamic> currentFilters;
  final Function(Map<String, dynamic>) onApplyFilters;

  const UserFilterDialog({
    super.key,
    required this.dark,
    required this.currentFilters,
    required this.onApplyFilters,
  });

  @override
  State<UserFilterDialog> createState() => _UserFilterDialogState();
}

class _UserFilterDialogState extends State<UserFilterDialog> {
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
                  'Filter Users',
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
              'Gender',
              DropdownButton<String?>(
                value: filters['gender'],
                isExpanded: true,
                onChanged: (value) => setState(() => filters['gender'] = value),
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
                    value: 'Male',
                    child: Text(
                      'Male',
                      style: TextStyle(
                        color: widget.dark ? FColors.adminDarkText : FColors.adminLightText,
                      ),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'Female',
                    child: Text(
                      'Female',
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
              'Join Date Range',
              DropdownButton<String?>(
                value: filters['joinDateRange'],
                isExpanded: true,
                onChanged: (value) => setState(() => filters['joinDateRange'] = value),
                items: [
                  DropdownMenuItem(
                    value: null,
                    child: Text(
                      'All Time',
                      style: TextStyle(
                        color: widget.dark ? FColors.adminDarkText : FColors.adminLightText,
                      ),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'last7days',
                    child: Text(
                      'Last 7 Days',
                      style: TextStyle(
                        color: widget.dark ? FColors.adminDarkText : FColors.adminLightText,
                      ),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'last30days',
                    child: Text(
                      'Last 30 Days',
                      style: TextStyle(
                        color: widget.dark ? FColors.adminDarkText : FColors.adminLightText,
                      ),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'last90days',
                    child: Text(
                      'Last 90 Days',
                      style: TextStyle(
                        color: widget.dark ? FColors.adminDarkText : FColors.adminLightText,
                      ),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'thisYear',
                    child: Text(
                      'This Year',
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
                          'gender': null,
                          'joinDateRange': null,
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