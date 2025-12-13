import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fyp/utils/constants/colors.dart';
import 'package:fyp/utils/constants/sizes.dart';
import 'package:fyp/utils/helpers/helper_functions.dart';
import 'package:fyp/utils/validators/validation.dart';
import 'package:fyp/utils/popups/loaders.dart';
import 'package:fyp/utils/formatters/formatter.dart';
import 'package:fyp/features/recycling_center/models/recycling_center_staff_model.dart';
import 'package:fyp/data/repositories/user/user_repository.dart';

import '../../../../../data/repositories/user/center_staff_repository.dart';
import '../../../../../common/widgets/admin/admin_lightbox.dart';
import '../../../../../common/widgets/admin/profile_image_handler.dart';
import '../../../controllers/center_staff_management/center_staff_management_controller.dart';

class StaffDetailDialog extends StatefulWidget {
  final RecyclingCenterStaff staff;
  final bool isEditMode;
  final String? centerName;

  const StaffDetailDialog({
    super.key,
    required this.staff,
    this.isEditMode = false,
    this.centerName,
  });

  @override
  State<StaffDetailDialog> createState() => _StaffDetailDialogState();
}

class _StaffDetailDialogState extends State<StaffDetailDialog> {
  late bool _isEditMode;
  late TextEditingController _usernameController;
  final _formKey = GlobalKey<FormState>();
  Uint8List? _pendingImageBytes;
  bool _pendingDeleteImage = false;
  bool _hasChanges = false;
  final UserRepository _userRepo = UserRepository.instance;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.isEditMode;
    _usernameController = TextEditingController(text: widget.staff.username);
    _usernameController.addListener(_updateHasChanges);
  }

  void _updateHasChanges() {
    final usernameChanged = _usernameController.text.trim() != widget.staff.username;
    final imageChanged = _pendingImageBytes != null;
    final deleteRequested = _pendingDeleteImage;

    final hasChanges = usernameChanged || imageChanged || deleteRequested;

    print('🔄 Updating hasChanges: $hasChanges');
    print('   - Username changed: $usernameChanged');
    print('   - Has pending image: $imageChanged');
    print('   - Pending delete: $deleteRequested');

    setState(() {
      _hasChanges = hasChanges;
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = FHelperFunctions.isDarkMode(context);

    return Dialog(
      backgroundColor: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(FSizes.cardRadiusLg),
      ),
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 700),
        padding: const EdgeInsets.all(FSizes.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _isEditMode ? 'Edit Staff' : 'Staff Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: dark ? FColors.adminDarkText : FColors.adminLightText,
                  ),
                ),
                Row(
                  children: [
                    if (!_isEditMode)
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _isEditMode = true;
                          });
                        },
                        icon: Icon(
                          Iconsax.edit,
                          color: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
                        ),
                        tooltip: 'Edit',
                      ),
                    IconButton(
                      onPressed: () {
                        if (_isEditMode && _hasChanges) {
                          _showDiscardDialog(context, dark);
                        } else {
                          Get.back();
                        }
                      },
                      icon: Icon(
                        Iconsax.close_circle,
                        color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: FSizes.spaceBtwItems),
            Divider(color: dark ? FColors.adminDarkDivider : FColors.adminLightDivider),
            const SizedBox(height: FSizes.spaceBtwItems),

            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Image
                      Center(
                        child: _buildProfileImage(dark),
                      ),
                      const SizedBox(height: FSizes.spaceBtwSections),

                      // Staff ID
                      _buildInfoRow('Staff ID', widget.staff.userId, dark),
                      const SizedBox(height: FSizes.spaceBtwItems),

                      // Username
                      if (_isEditMode)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Username',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: dark ? FColors.adminDarkText : FColors.adminLightText,
                              ),
                            ),
                            const SizedBox(height: FSizes.xs),
                            TextFormField(
                              controller: _usernameController,
                              decoration: InputDecoration(
                                hintText: 'Enter username',
                                hintStyle: TextStyle(
                                  color: dark
                                      ? FColors.adminDarkTextSecondary
                                      : FColors.adminLightTextSecondary,
                                ),
                                prefixIcon: Icon(
                                  Iconsax.user,
                                  color: dark
                                      ? FColors.adminDarkTextSecondary
                                      : FColors.adminLightTextSecondary,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
                                ),
                              ),
                              validator: (value) => FValidator.validateEmptyText('Username', value),
                            ),
                            const SizedBox(height: FSizes.spaceBtwItems),
                          ],
                        )
                      else
                        Column(
                          children: [
                            _buildInfoRow('Username', widget.staff.username, dark),
                            const SizedBox(height: FSizes.spaceBtwItems),
                          ],
                        ),

                      // Center ID
                      _buildInfoRow('Center ID', widget.staff.centerId, dark),
                      const SizedBox(height: FSizes.spaceBtwItems),

                      // Center Name
                      if (widget.centerName != null)
                        Column(
                          children: [
                            _buildInfoRow('Center Name', widget.centerName!, dark),
                            const SizedBox(height: FSizes.spaceBtwItems),
                          ],
                        ),

                      // Email
                      _buildInfoRow('Email', widget.staff.email, dark),
                      const SizedBox(height: FSizes.spaceBtwItems),

                      // Phone Number
                      _buildInfoRow('Phone Number', widget.staff.phoneNo ?? 'N/A', dark),
                      const SizedBox(height: FSizes.spaceBtwItems),

                      // Gender
                      _buildInfoRow('Gender', widget.staff.gender ?? 'N/A', dark),
                      const SizedBox(height: FSizes.spaceBtwItems),

                      // Join Date
                      _buildInfoRow(
                        'Join Date',
                        FFormatter.formatDate(widget.staff.joinDate),
                        dark,
                      ),
                      const SizedBox(height: FSizes.spaceBtwItems),

                      // Status badges
                      Row(
                        children: [
                          _buildStatusBadge('Verified', widget.staff.isVerified, dark),
                          const SizedBox(width: FSizes.sm),
                          _buildStatusBadge('Active', widget.staff.isActive, dark),
                          const SizedBox(width: FSizes.sm),
                          _buildStatusBadge(
                            'Banned',
                            widget.staff.isBanned,
                            dark,
                            isNegative: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Action Buttons
            if (_isEditMode) ...[
              const SizedBox(height: FSizes.spaceBtwSections),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        if (_hasChanges) {
                          _showDiscardDialog(context, dark);
                        } else {
                          setState(() {
                            _isEditMode = false;
                            // 重置所有状态
                            _pendingImageBytes = null;
                            _pendingDeleteImage = false;
                            _usernameController.text = widget.staff.username;
                          });
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: FSizes.md),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: FSizes.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _hasChanges ? () => _showUpdateDialog(context, dark) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
                        padding: const EdgeInsets.symmetric(vertical: FSizes.md),
                        disabledBackgroundColor: dark
                            ? FColors.adminDarkTextMuted
                            : FColors.adminLightTextMuted,
                      ),
                      child: const Text(
                        'Update Profile',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage(bool dark) {
    print('🔍 Building ProfileImageHandler with:');
    print('   - Current profileImg: ${widget.staff.profileImg}');
    print('   - Pending image bytes: ${_pendingImageBytes != null}');
    print('   - Pending delete: $_pendingDeleteImage');
    print('   - Has changes: $_hasChanges');

    return ProfileImageHandler(
      profileImg: widget.staff.profileImg,
      username: widget.staff.username,
      userId: widget.staff.userId,
      dark: dark,
      radius: 60,
      isEditMode: _isEditMode,
      onImageChanged: (Uint8List? newImageBytes) {
        print('🖼️ onImageChanged called with new image: ${newImageBytes != null}');
        setState(() {
          _pendingImageBytes = newImageBytes;
          if (newImageBytes != null) {
            _pendingDeleteImage = false; // 只有选择新图片时才取消删除标记
          }
          _updateHasChanges();
        });
      },
      onDeleteRequested: (bool isDeleteRequested) {
        print('🗑️ onDeleteRequested called: $isDeleteRequested');
        setState(() {
          _pendingDeleteImage = isDeleteRequested;
          if (isDeleteRequested) {
            _pendingImageBytes = null; // 请求删除时清除新图片
          }
          _updateHasChanges();
        });
      },
    );
  }

  Widget _buildInfoRow(String label, String value, bool dark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: dark ? FColors.adminDarkText : FColors.adminLightText,
          ),
        ),
        const SizedBox(height: FSizes.xs),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(FSizes.md),
          decoration: BoxDecoration(
            color: dark ? FColors.adminDarkBackground : FColors.adminLightBackground,
            borderRadius: BorderRadius.circular(FSizes.cardRadiusMd),
            border: Border.all(
              color: dark ? FColors.adminDarkBorder : FColors.adminLightBorder,
            ),
          ),
          child: Text(
            value,
            style: TextStyle(
              color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String label, bool isActive, bool dark, {bool isNegative = false}) {
    Color backgroundColor;
    if (isNegative) {
      backgroundColor = isActive
          ? (dark ? FColors.adminDarkError : FColors.adminLightError)
          : (dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted);
    } else {
      backgroundColor = isActive
          ? (dark ? FColors.adminDarkSuccess : FColors.adminLightSuccess)
          : (dark ? FColors.adminDarkTextMuted : FColors.adminLightTextMuted);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: FSizes.md, vertical: FSizes.sm),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(FSizes.cardRadiusXs),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }

  void _showDiscardDialog(BuildContext context, bool dark) {
    Get.dialog(
      AlertDialog(
        backgroundColor: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
        title: Text(
          'Discard Changes?',
          style: TextStyle(
            color: dark ? FColors.adminDarkText : FColors.adminLightText,
          ),
        ),
        content: Text(
          'Are you sure you want to discard your changes?',
          style: TextStyle(
            color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
          ),
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
            onPressed: () {
              // 完全重置所有状态到初始值
              setState(() {
                _pendingImageBytes = null;
                _pendingDeleteImage = false;
                _hasChanges = false;
                _usernameController.text = widget.staff.username; // 重置用户名
              });
              Get.back();
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: dark ? FColors.adminDarkError : FColors.adminLightError,
            ),
            child: const Text('Discard', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showUpdateDialog(BuildContext context, bool dark) async {
    if (_formKey.currentState!.validate()) {
      // Check username uniqueness (only if username changed)
      if (_usernameController.text.trim() != widget.staff.username) {
        final repo = RecyclingCenterStaffRepository.instance;
        final isUsernameUnique = await repo.isUsernameUnique(
          _usernameController.text.trim(),
          widget.staff.userId,
        );

        if (!isUsernameUnique) {
          FLoaders.errorSnackBar(
            title: 'Error',
            message: 'Username is already taken',
          );
          return;
        }
      }

      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          backgroundColor: dark ? FColors.adminDarkSurface : FColors.adminLightSurface,
          title: Text(
            'Update Staff Profile',
            style: TextStyle(
              color: dark ? FColors.adminDarkText : FColors.adminLightText,
            ),
          ),
          content: Text(
            'Are you sure you want to update this staff profile?',
            style: TextStyle(
              color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: dark ? FColors.adminDarkTextSecondary : FColors.adminLightTextSecondary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: dark ? FColors.adminDarkPrimary : FColors.adminLightPrimary,
              ),
              child: const Text('Update', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        final updatedStaff = widget.staff.copyWith(
          username: _usernameController.text.trim(),
        );

        final controller = StaffManagementController.instance;

        // 只有在确认更新时才处理图片
        await controller.updateStaff(
            updatedStaff,
            _pendingImageBytes,
            _pendingDeleteImage
        );

        Get.back();
      }
    }
  }
}