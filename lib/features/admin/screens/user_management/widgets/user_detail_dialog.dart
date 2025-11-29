import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../common/widgets/admin/profile_image_handler.dart';
import '../../../../../data/repositories/user/user_repository.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/formatters/formatter.dart';
import '../../../../../utils/helpers/helper_functions.dart';
import '../../../../../utils/popups/loaders.dart';
import '../../../../../utils/validators/validation.dart';
import '../../../../authentication/models/user_model.dart';
import '../../../controllers/user_management/user_management_controller.dart';

class UserDetailDialog extends StatefulWidget {
  final UserModel user;
  final bool isEditMode;

  const UserDetailDialog({
    super.key,
    required this.user,
    this.isEditMode = false,
  });

  @override
  State<UserDetailDialog> createState() => _UserDetailDialogState();
}

class _UserDetailDialogState extends State<UserDetailDialog> {
  late bool _isEditMode;
  late TextEditingController _usernameController;
  final _formKey = GlobalKey<FormState>();
  Uint8List? _pendingImageBytes; // 改为 pending
  bool _pendingDeleteImage = false; // 改为 pending
  bool _hasChanges = false;
  final UserRepository _userRepo = UserRepository.instance;
  late ProfileImageHandler _profileImageHandler; // 引用组件

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.isEditMode;
    _usernameController = TextEditingController(text: widget.user.username);
    _usernameController.addListener(_updateHasChanges);
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
                  _isEditMode ? 'Edit User' : 'User Details',
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

                      // User ID (Read-only)
                      _buildInfoRow('User ID', widget.user.userId, dark),
                      const SizedBox(height: FSizes.spaceBtwItems),

                      // Username (Editable)
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
                            _buildInfoRow('Username', widget.user.username, dark),
                            const SizedBox(height: FSizes.spaceBtwItems),
                          ],
                        ),

                      // Email (Read-only)
                      _buildInfoRow('Email', widget.user.email, dark),
                      const SizedBox(height: FSizes.spaceBtwItems),

                      // Phone Number (Read-only)
                      _buildInfoRow('Phone Number', widget.user.phoneNo ?? 'N/A', dark),
                      const SizedBox(height: FSizes.spaceBtwItems),

                      // Gender (Read-only)
                      _buildInfoRow('Gender', widget.user.gender ?? 'N/A', dark),
                      const SizedBox(height: FSizes.spaceBtwItems),

                      // Date of Birth (Read-only)
                      _buildInfoRow(
                        'Date of Birth',
                        widget.user.dob != null ? FFormatter.formatDate(widget.user.dob!) : 'N/A',
                        dark,
                      ),
                      const SizedBox(height: FSizes.spaceBtwItems),

                      // Reward Points
                      _buildInfoRow('Current Points', widget.user.rewardPoint.toString(), dark),
                      const SizedBox(height: FSizes.spaceBtwItems),

                      _buildInfoRow('Monthly Points', widget.user.monthlyRewardPoint.toString(), dark),
                      const SizedBox(height: FSizes.spaceBtwItems),

                      _buildInfoRow('Total Points', widget.user.totalRewardPoint.toString(), dark),
                      const SizedBox(height: FSizes.spaceBtwItems),

                      // Join Date (Read-only)
                      _buildInfoRow('Join Date', FFormatter.formatDate(widget.user.joinDate), dark),
                      const SizedBox(height: FSizes.spaceBtwItems),

                      // Status badges
                      Row(
                        children: [
                          _buildStatusBadge(
                            'Verified',
                            widget.user.isVerified,
                            dark,
                          ),
                          const SizedBox(width: FSizes.sm),
                          _buildStatusBadge(
                            'Active',
                            widget.user.isActive,
                            dark,
                          ),
                          const SizedBox(width: FSizes.sm),
                          _buildStatusBadge(
                            'Banned',
                            widget.user.isBanned,
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
    print('   - Current profileImg: ${widget.user.profileImg}');
    print('   - Pending image bytes: ${_pendingImageBytes != null}');
    print('   - Pending delete: $_pendingDeleteImage');
    print('   - Has changes: $_hasChanges');

    return ProfileImageHandler(
      profileImg: widget.user.profileImg,
      username: widget.user.username,
      userId: widget.user.userId,
      dark: dark,
      radius: 60,
      isEditMode: _isEditMode,
      onImageChanged: (Uint8List? newImageBytes) {
        print('🖼️ onImageChanged called with new image: ${newImageBytes != null}');
        setState(() {
          _pendingImageBytes = newImageBytes; // 这里可以接受 null
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

  void _updateHasChanges() {
    setState(() {
      _hasChanges = _usernameController.text.trim() != widget.user.username ||
          _pendingImageBytes != null ||
          _pendingDeleteImage;
    });
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
              // 重置所有待确认的操作
              setState(() {
                _pendingImageBytes = null;
                _pendingDeleteImage = false;
                _hasChanges = false;
                _usernameController.text = widget.user.username;
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
      if (_usernameController.text.trim() != widget.user.username) {
        final isUsernameUnique = await _userRepo.isUsernameUnique(
          _usernameController.text.trim(),
          widget.user.userId,
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
            'Update User Profile',
            style: TextStyle(
              color: dark ? FColors.adminDarkText : FColors.adminLightText,
            ),
          ),
          content: Text(
            'Are you sure you want to update this user profile?',
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
        // 准备更新用户数据
        UserModel updatedUser = widget.user.copyWith(
          username: _usernameController.text.trim(),
        );

        final controller = UserManagementController.instance;

        // 只有在确认更新时才处理图片
        await controller.updateUser(
            updatedUser,
            _pendingImageBytes,
            _pendingDeleteImage
        );

        Get.back();
      }
    }
  }
}